---
name: wechatpay-patterns
description: 微信支付集成模式 - JSAPI、Native、APP、H5 支付以及退款、退款查询、订单查询等最佳实践
---

# 微信支付集成模式

> 微信支付 JSAPI、Native、APP、H5 支付以及退款、退款查询、订单查询等最佳实践

## 何时激活

- 实现微信支付功能
- JSAPI 公众号/小程序支付
- Native PC 网站支付
- APP 移动端支付
- H5 移动网页支付
- 支付退款处理
- 订单查询与管理

## 技术栈版本

| 技术               | 最低版本 | 推荐版本 |
| ------------------ | -------- | -------- |
| wechatpay-node-sdk | 3.1.0+   | 最新     |
| Node.js            | 16.0+    | 20.0+    |
| Redis              | 6.0+     | 7.0+     |

## 核心概念

```
┌─────────────────────────────────────────────────────────────┐
│                    微信支付流程                              │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │   商户订单   │────>│  统一下单    │────>│   预支付    │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│         │                                        │           │
│         │                                        ▼           │
│         │                               ┌─────────────┐       │
│         │                               │  调起支付    │       │
│         │                               └─────────────┘       │
│         │                                        │           │
│         ▼                                        ▼           │
│   ┌─────────────┐                         ┌─────────────┐     │
│   │   支付结果  │<────────────────────────│   支付回调   │     │
│   └─────────────┘                         └─────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 初始化

```typescript
import { WeChatPay, PlatformCertificateManager } from 'wechatpay-node-sdk';
import { Redis } from 'ioredis';

const wechatPay = new WeChatPay({
  mchid: process.env.WEIXIN_MCHID!,
  serial: process.env.WEIXIN_SERIAL!,
  privateKey: process.env.WEIXIN_PRIVATE_KEY!,
  certificates: {
    // 平台证书将被缓存
  },
  secretKey: process.env.WEIXIN_API_KEY!, // V2 API V3版本不需要
});

// Redis 用于缓存平台证书和 token
const redis = new Redis(process.env.REDIS_URL!);
```

## Native 支付 (PC 网站)

### 统一下单

```typescript
async function createNativeOrder(orderId: string, amount: number, description: string) {
  const result = await wechatPay.v3.pay.pay.transactions.native({
    amount: {
      total: amount,
      currency: 'CNY',
    },
    appid: process.env.WEIXIN_APPID!,
    description,
    out_trade_no: orderId,
    notify_url: `${process.env.BASE_URL}/api/payment/wechatpay/callback`,
  });

  return {
    codeUrl: result.code_url, // 二维码链接
    tradeNo: result.trade_no,
  };
}
```

### 支付结果通知

```typescript
import crypto from 'crypto';

async function handleNativeCallback(ctx) {
  const { body, headers } = ctx.request;
  const signature = headers['wechatpay-signature'];
  const timestamp = headers['wechatpay-timestamp'];
  const nonce = headers['wechatpay-nonce'];
  const serial = headers['wechatpay-serial'];

  // 验证签名
  const verified = verifySignature(timestamp, nonce, body, signature, serial);
  if (!verified) {
    ctx.status = 403;
    ctx.body = { code: 'FAIL', message: '签名验证失败' };
    return;
  }

  const paymentResult = JSON.parse(body);
  const { trade_state, transaction_id, out_trade_no } = paymentResult;

  if (trade_state === 'SUCCESS') {
    // 更新订单状态
    await updateOrderByTradeNo(out_trade_no, {
      status: 'PAID',
      transactionId: transaction_id,
      paidAt: new Date(),
    });
  }

  ctx.status = 200;
  ctx.body = { code: 'SUCCESS', message: '成功' };
}

function verifySignature(
  timestamp: string,
  nonce: string,
  body: string,
  signature: string,
  serial: string
): boolean {
  const message = `${timestamp}\n${nonce}\n${body}\n`;
  const certificate = await getCertificate(serial);

  const verified = crypto
    .createVerify('SHA256')
    .update(message)
    .verify(certificate, signature, 'base64');

  return verified;
}
```

## JSAPI 支付 (公众号)

### 获取用户openid

```typescript
async function getOpenid(code: string) {
  const result = await fetch(
    `https://api.weixin.qq.com/sns/oauth2/access_token?appid=${process.env.WEIXIN_APPID}&secret=${process.env.WEIXIN_SECRET}&code=${code}&grant_type=authorization_code`
  );
  const data = await result.json();
  return data.openid;
}
```

### JSAPI 统一下单

```typescript
async function createJsapiOrder(
  openid: string,
  orderId: string,
  amount: number,
  description: string
) {
  const result = await wechatPay.v3.pay.pay.transactions.jsapi({
    amount: {
      total: amount,
      currency: 'CNY',
    },
    appid: process.env.WEIXIN_APPID!,
    description,
    out_trade_no: orderId,
    notify_url: `${process.env.BASE_URL}/api/payment/wechatpay/callback`,
    payer: {
      openid,
    },
  });

  return {
    prepayId: result.prepay_id,
  };
}

// 获取调起支付的签名
function getJsapiSign(prepayId: string) {
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const nonceStr = crypto.randomUUID().replace(/-/g, '');
  const packageStr = `prepay_id=${prepayId}`;

  const signStr = [process.env.WEIXIN_APPID!, timestamp, nonceStr, packageStr].join('\n');
  const sign = crypto
    .createSign('SHA256withRSA')
    .update(signStr)
    .sign(process.env.WEIXIN_PRIVATE_KEY!, 'base64');

  return { timestamp, nonceStr, package: packageStr, sign };
}
```

## APP 支付

```typescript
async function createAppOrder(orderId: string, amount: number, description: string) {
  const result = await wechatPay.v3.pay.pay.transactions.app({
    amount: {
      total: amount,
      currency: 'CNY',
    },
    appid: process.env.WEIXIN_APPID!,
    description,
    out_trade_no: orderId,
    notify_url: `${process.env.BASE_URL}/api/payment/wechatpay/callback`,
  });

  // APP 调起支付的签名
  const timestamp = Math.floor(Date.now() / 1000).toString();
  const nonceStr = crypto.randomUUID().replace(/-/g, '');

  const signStr = [
    process.env.WEIXIN_APPID!,
    timestamp,
    nonceStr,
    `prepay_id=${result.prepay_id}`,
  ].join('\n');

  return {
    prepayId: result.prepay_id,
    sign: crypto
      .createSign('SHA256withRSA')
      .update(signStr)
      .sign(process.env.WEIXIN_PRIVATE_KEY!, 'base64'),
    timestamp,
    nonceStr,
    partnerId: process.env.WEIXIN_MCHID!,
  };
}
```

## H5 支付

```typescript
async function createH5Order(orderId: string, amount: number, description: string) {
  const result = await wechatPay.v3.pay.pay.transactions.h5({
    amount: {
      total: amount,
      currency: 'CNY',
    },
    appid: process.env.WEIXIN_APPID!,
    description,
    out_trade_no: orderId,
    notify_url: `${process.env.BASE_URL}/api/payment/wechatpay/callback`,
    scene_info: {
      payer_client_ip: '客户端IP',
      device_info: '可选',
      h5_info: {
        type: 'Wap',
      },
    },
  });

  return {
    h5Url: result.h5_url, // 跳转支付链接
  };
}
```

## 订单查询

```typescript
async function queryOrderByTradeNo(transactionId: string) {
  const result = await wechatPay.v3.pay.pay.transactions.id(transactionId);
  return {
    tradeState: result.trade_state,
    amount: result.amount,
    transactionId: result.transaction_id,
    outTradeNo: result.out_trade_no,
    timeEnd: result.success_time,
  };
}

async function queryOrderByOutTradeNo(outTradeNo: string) {
  const result =
    (await wechatPay.v3.pay.pay.transactions.out) -
    trade -
    no(outTradeNo, {
      mchid: process.env.WEIXIN_MCHID!,
    });
  return {
    tradeState: result.trade_state,
    amount: result.amount,
    transactionId: result.transaction_id,
  };
}
```

## 退款

```typescript
async function refundOrder(transactionId: string, refundAmount: number, reason?: string) {
  const result =
    (await wechatPay.v3.secikit.pay.transactions.out) -
    trade -
    no(transactionId, 'POST', {
      out_refund_no: `REFUND_${Date.now()}`,
      amount: {
        refund: refundAmount,
        total: 100, // 原订单金额 (分)
        currency: 'CNY',
      },
      reason,
    });

  return {
    refundId: result.refund_id,
    status: result.status,
  };
}

async function queryRefund(refundId: string) {
  const result = await wechatPay.v3.secikit.pay.refunds.id(refundId);
  return {
    status: result.status,
    refundAmount: result.amount.refund,
    settlementRefundAmount: result.amount.settlement_refund,
  };
}
```

## 快速参考

```typescript
// 初始化
const wp = new WeChatPay({ mchid: '商户号', serial: '证书序列号', privateKey: '私钥' });

// Native 支付
await wp.v3.pay.pay.transactions.native({
  amount: { total: 100 },
  description: 'test',
  out_trade_no: '订单号',
});

// JSAPI 支付
await wp.v3.pay.pay.transactions.jsapi({
  amount: { total: 100 },
  description: 'test',
  out_trade_no: '订单号',
  payer: { openid: '用户openid' },
});

// 查询订单
await wp.v3.pay.pay.transactions.id('微信订单号');

// 退款
(await wp.v3.secikit.pay.transactions.out) -
  trade -
  no('订单号', 'POST', {
    out_refund_no: '退款号',
    amount: { refund: 100, total: 100, currency: 'CNY' },
  });
```

## 参考

- [微信支付开发文档](https://pay.weixin.qq.com/docs/)
- [wechatpay-node-sdk](https://github.com/TheNorthMemory/wechatpay-axios-plugin)
