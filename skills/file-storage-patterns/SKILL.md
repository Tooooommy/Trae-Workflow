---
name: file-storage-patterns
description: 文件上传存储模式 - 对象存储、CDN、文件处理最佳实践。**必须激活当**：用户要求实现文件上传、配置对象存储或处理文件处理时。即使用户没有明确说"文件存储"，当涉及对象存储、CDN 或文件上传时也应使用。
---

# 文件存储模式

> 对象存储、CDN 分发、文件处理的最佳实践

## 何时激活

- 实现文件上传功能
- 配置对象存储
- 处理图片/视频
- 设计 CDN 分发
- 实现文件安全访问

## 技术栈版本

| 技术       | 最低版本         | 推荐版本 |
| ---------- | ---------------- | -------- |
| AWS S3     | -                | 最新     |
| 阿里云 OSS | -                | 最新     |
| MinIO      | RELEASE.2024-01+ | 最新     |
| Sharp      | 0.33+            | 最新     |
| Multer     | 1.4+             | 最新     |

## 存储方案对比

| 方案                 | 特点            | 适用场景   |
| -------------------- | --------------- | ---------- |
| AWS S3               | 云原生、高可用  | 生产环境   |
| 阿里云 OSS           | 国内加速、成熟  | 国内业务   |
| MinIO                | 自托管、S3 兼容 | 私有部署   |
| Cloudflare R2        | 零出口费        | CDN 场景   |
| Google Cloud Storage | GCP 集成        | GCP 用户   |
| Azure Blob Storage   | Azure 集成      | Azure 用户 |

## S3 客户端配置

```typescript
import {
  S3Client,
  PutObjectCommand,
  GetObjectCommand,
  DeleteObjectCommand,
} from '@aws-sdk/client-s3';
import { getSignedUrl } from '@aws-sdk/s3-request-presigner';

const s3Client = new S3Client({
  region: process.env.AWS_REGION,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
});

const BUCKET_NAME = process.env.S3_BUCKET_NAME!;
```

## 阿里云 OSS 客户端配置

```typescript
import OSS from 'ali-oss';

const ossClient = new OSS({
  region: process.env.OSS_REGION!,
  accessKeyId: process.env.OSS_ACCESS_KEY_ID!,
  accessKeySecret: process.env.OSS_ACCESS_KEY_SECRET!,
  bucket: process.env.OSS_BUCKET!,
});

const BUCKET_NAME = process.env.OSS_BUCKET!;
```

## 文件上传

### Multer 内存上传 (S3)

```typescript
import multer from 'multer';
import { Request } from 'express';

const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
  },
  fileFilter: (req, file, cb) => {
    const allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];
    if (allowedTypes.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Invalid file type'));
    }
  },
});

app.post('/upload', upload.single('file'), async (req: Request, res) => {
  const file = req.file;

  if (!file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const key = `uploads/${Date.now()}-${file.originalname}`;

  await s3Client.send(
    new PutObjectCommand({
      Bucket: BUCKET_NAME,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
    })
  );

  res.json({ key, url: `https://${BUCKET_NAME}.s3.amazonaws.com/${key}` });
});
```

### 阿里云 OSS 上传

```typescript
import multer from 'multer';
import OSS from 'ali-oss';

const storage = multer.diskStorage({
  destination: async (req, file, cb) => {
    cb(null, '/tmp/uploads');
  },
  filename: (req, file, cb) => {
    cb(null, `${Date.now()}-${file.originalname}`);
  },
});

const upload = multer({ storage });

async function uploadToOss(file: Express.Multer.File): Promise<string> {
  const key = `uploads/${Date.now()}-${file.originalname}`;

  const result = await ossClient.put(key, file.path);

  return result.url;
}

app.post('/upload', upload.single('file'), async (req, res) => {
  const file = req.file;

  if (!file) {
    return res.status(400).json({ error: 'No file uploaded' });
  }

  const url = await uploadToOss(file);

  res.json({ url });
});
```

### 分片上传 (大文件)

```typescript
import {
  CreateMultipartUploadCommand,
  UploadPartCommand,
  CompleteMultipartUploadCommand,
} from '@aws-sdk/client-s3';

async function uploadLargeFile(file: File, key: string) {
  const CHUNK_SIZE = 5 * 1024 * 1024; // 5MB

  const { UploadId } = await s3Client.send(
    new CreateMultipartUploadCommand({
      Bucket: BUCKET_NAME,
      Key: key,
    })
  );

  const parts: { PartNumber: number; ETag: string }[] = [];
  const totalParts = Math.ceil(file.size / CHUNK_SIZE);

  for (let i = 0; i < totalParts; i++) {
    const start = i * CHUNK_SIZE;
    const end = Math.min(start + CHUNK_SIZE, file.size);
    const chunk = file.slice(start, end);

    const { ETag } = await s3Client.send(
      new UploadPartCommand({
        Bucket: BUCKET_NAME,
        Key: key,
        UploadId,
        PartNumber: i + 1,
        Body: chunk,
      })
    );

    parts.push({ PartNumber: i + 1, ETag: ETag! });
  }

  await s3Client.send(
    new CompleteMultipartUploadCommand({
      Bucket: BUCKET_NAME,
      Key: key,
      UploadId,
      MultipartUpload: { Parts: parts },
    })
  );
}
```

### 阿里云 OSS 分片上传

```typescript
async function uploadLargeFileToOss(filePath: string, key: string) {
  const CHUNK_SIZE = 5 * 1024 * 1024; // 5MB

  const progress = (p: number) => {
    console.log(`Upload progress: ${p * 100}%`);
  };

  const result = await ossClient.multipartUpload(key, filePath, {
    progress,
    partSize: CHUNK_SIZE,
  });

  return result;
}
```

## 预签名 URL

### S3 预签名 URL

```typescript
async function getUploadUrl(key: string, expiresIn = 3600): Promise<string> {
  const command = new PutObjectCommand({
    Bucket: BUCKET_NAME,
    Key: key,
  });

  return getSignedUrl(s3Client, command, { expiresIn });
}

async function getDownloadUrl(key: string, expiresIn = 3600): Promise<string> {
  const command = new GetObjectCommand({
    Bucket: BUCKET_NAME,
    Key: key,
  });

  return getSignedUrl(s3Client, command, { expiresIn });
}

app.post('/presigned-url', async (req, res) => {
  const { filename, contentType } = req.body;
  const key = `uploads/${Date.now()}-${filename}`;

  const uploadUrl = await getUploadUrl(key);

  res.json({
    uploadUrl,
    key,
    expiresIn: 3600,
  });
});
```

### 阿里云 OSS 签名 URL

```typescript
async function getOssUploadUrl(key: string, expiresIn = 3600): Promise<string> {
  return ossClient.signatureUrl(key, {
    expires: expiresIn,
    method: 'PUT',
  });
}

async function getOssDownloadUrl(key: string, expiresIn = 3600): Promise<string> {
  return ossClient.signatureUrl(key, {
    expires: expiresIn,
    method: 'GET',
  });
}

app.post('/presigned-url', async (req, res) => {
  const { filename } = req.body;
  const key = `uploads/${Date.now()}-${filename}`;

  const uploadUrl = await getOssUploadUrl(key);

  res.json({
    uploadUrl,
    key,
    expiresIn: 3600,
  });
});
```

## 图片处理

```typescript
import sharp from 'sharp';

interface ImageOptions {
  width?: number;
  height?: number;
  quality?: number;
  format?: 'jpeg' | 'png' | 'webp';
}

async function processImage(input: Buffer, options: ImageOptions = {}): Promise<Buffer> {
  const { width, height, quality = 80, format = 'webp' } = options;

  let pipeline = sharp(input);

  if (width || height) {
    pipeline = pipeline.resize(width, height, {
      fit: 'inside',
      withoutEnlargement: true,
    });
  }

  switch (format) {
    case 'jpeg':
      pipeline = pipeline.jpeg({ quality });
      break;
    case 'png':
      pipeline = pipeline.png({ compressionLevel: 9 });
      break;
    case 'webp':
      pipeline = pipeline.webp({ quality });
      break;
  }

  return pipeline.toBuffer();
}

async function generateThumbnails(
  input: Buffer
): Promise<{ small: Buffer; medium: Buffer; large: Buffer }> {
  const [small, medium, large] = await Promise.all([
    processImage(input, { width: 150, height: 150 }),
    processImage(input, { width: 400, height: 400 }),
    processImage(input, { width: 800, height: 800 }),
  ]);

  return { small, medium, large };
}
```

## CDN 配置

### CloudFront 签名 URL

```typescript
import { CloudFrontSigner } from '@aws-sdk/cloudfront-signer';

const cloudFrontSigner = new CloudFrontSigner(
  process.env.CLOUDFRONT_KEY_PAIR_ID!,
  process.env.CLOUDFRONT_PRIVATE_KEY!
);

function getSignedCdnUrl(key: string, expiresIn = 3600): string {
  const url = `https://${process.env.CLOUDFRONT_DOMAIN}/${key}`;
  return cloudFrontSigner.getSignedUrl({
    url,
    expires: Math.floor(Date.now() / 1000) + expiresIn,
  });
}
```

### 阿里云 OSS CDN 签名 URL

```typescript
async function getOssCdnUrl(key: string, cdnDomain: string, expiresIn = 3600): Promise<string> {
  const signedUrl = await ossClient.signatureUrl(key, {
    expires: expiresIn,
  });

  return signedUrl.replace(ossClient['options'].endpoint, `https://${cdnDomain}`);
}
```

## 安全最佳实践

| 措施         | 实现                        |
| ------------ | --------------------------- |
| 文件类型验证 | MIME 类型 + 魔数检查        |
| 大小限制     | Multer 配置 + 服务端验证    |
| 病毒扫描     | ClamAV 集成                 |
| 访问控制     | 预签名 URL + 过期时间       |
| 加密         | 服务端加密 (SSE-S3/SSE-KMS) |
| 私有读写     | 阿里云 OSS Bucket 权限控制  |

## 文件组织结构

```
bucket/
├── uploads/
│   ├── images/
│   │   ├── original/
│   │   ├── thumbnails/
│   │   └── optimized/
│   ├── documents/
│   └── videos/
├── private/
│   └── user-data/
└── temp/
    └── uploads/
```

## 快速参考

### S3 操作

```typescript
// 上传文件
await s3Client.send(
  new PutObjectCommand({
    Bucket: BUCKET_NAME,
    Key: key,
    Body: buffer,
    ContentType: mimetype,
  })
);

// 获取预签名 URL
const url = await getSignedUrl(
  s3Client,
  new GetObjectCommand({
    Bucket: BUCKET_NAME,
    Key: key,
  }),
  { expiresIn: 3600 }
);

// 删除文件
await s3Client.send(
  new DeleteObjectCommand({
    Bucket: BUCKET_NAME,
    Key: key,
  })
);

// 图片处理
const optimized = await sharp(input).resize(800, 600).webp().toBuffer();
```

### 阿里云 OSS 操作

```typescript
// 上传文件
await ossClient.put(key, buffer, {
  headers: {
    'Content-Type': mimetype,
  },
});

// 获取签名 URL
const url = await ossClient.signatureUrl(key, { expires: 3600 });

// 删除文件
await ossClient.delete(key);

// 列出文件
const result = await ossClient.list({
  prefix: 'uploads/',
});

result.objects.forEach((obj) => {
  console.log(obj.name, obj.url);
});
```

## 参考

- [AWS S3 SDK v3](https://docs.aws.amazon.com/AWSJavaScriptSDK/v3/latest/clients/client-s3/)
- [阿里云 OSS Node.js SDK](https://help.aliyun.com/document_detail/32099.html)
- [Sharp Docs](https://sharp.pixelplumbing.com/)
- [Multer Docs](https://github.com/expressjs/multer)
- [CloudFront Signed URLs](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-signed-urls.html)
- [阿里云 OSS 权限控制](https://help.aliyun.com/document_detail/108704.html)
