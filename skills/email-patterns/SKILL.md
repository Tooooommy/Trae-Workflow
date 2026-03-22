---
name: email-patterns
description: 邮件服务模式 - 事务邮件、批量邮件、模板最佳实践
---

# 邮件服务模式

> 事务邮件、批量邮件、模板渲染的最佳实践

## 何时激活

- 发送事务邮件
- 批量邮件营销
- 邮件模板设计
- 邮件追踪分析
- 邮件队列管理

## 技术栈版本

| 技术       | 最低版本 | 推荐版本 |
| ---------- | -------- | -------- |
| Nodemailer | 6.0+     | 最新     |
| SendGrid   | 7.0+     | 最新     |
| Resend     | 3.0+     | 最新     |
| MJML       | 4.0+     | 最新     |

## 邮件服务对比

| 服务       | 特点       | 适用场景   |
| ---------- | ---------- | ---------- |
| SendGrid   | 功能全面   | 企业级应用 |
| Resend     | 开发者友好 | 现代应用   |
| Amazon SES | 成本低     | 大批量邮件 |
| Mailgun    | API 丰富   | 开发者工具 |
| Postmark   | 事务邮件   | 高送达率   |

## Nodemailer 实现

```typescript
import nodemailer from 'nodemailer';

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

interface EmailOptions {
  to: string | string[];
  subject: string;
  text?: string;
  html?: string;
  attachments?: Array<{
    filename: string;
    content: Buffer | string;
    contentType?: string;
  }>;
}

async function sendEmail(options: EmailOptions) {
  const info = await transporter.sendMail({
    from: `"${process.env.EMAIL_FROM_NAME}" <${process.env.EMAIL_FROM_ADDRESS}>`,
    to: Array.isArray(options.to) ? options.to.join(',') : options.to,
    subject: options.subject,
    text: options.text,
    html: options.html,
    attachments: options.attachments,
  });

  return info.messageId;
}
```

## SendGrid 实现

```typescript
import sgMail from '@sendgrid/mail';

sgMail.setApiKey(process.env.SENDGRID_API_KEY!);

interface SendGridEmail {
  to: string | string[];
  templateId?: string;
  dynamicTemplateData?: Record<string, any>;
  subject?: string;
  html?: string;
  text?: string;
}

async function sendSendGridEmail(email: SendGridEmail) {
  const msg = {
    to: email.to,
    from: {
      email: process.env.EMAIL_FROM_ADDRESS!,
      name: process.env.EMAIL_FROM_NAME,
    },
    templateId: email.templateId,
    dynamicTemplateData: email.dynamicTemplateData,
    subject: email.subject,
    html: email.html,
    text: email.text,
  };

  await sgMail.send(msg);
}
```

## Resend 实现

```typescript
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

async function sendResendEmail(to: string, subject: string, html: string) {
  const { data, error } = await resend.emails.send({
    from: `${process.env.EMAIL_FROM_NAME} <${process.env.EMAIL_FROM_ADDRESS}>`,
    to,
    subject,
    html,
  });

  if (error) {
    throw error;
  }

  return data?.id;
}
```

## 邮件模板

### MJML 模板

```typescript
import mjml2html from 'mjml';

const template = `
<mjml>
  <mj-head>
    <mj-title>Welcome Email</mj-title>
  </mj-head>
  <mj-body>
    <mj-section>
      <mj-column>
        <mj-text font-size="20px">Welcome, {{name}}!</mj-text>
        <mj-text>Thank you for joining us.</mj-text>
        <mj-button href="{{ctaUrl}}">Get Started</mj-button>
      </mj-column>
    </mj-section>
  </mj-body>
</mjml>
`;

function renderTemplate(template: string, data: Record<string, string>): string {
  let html = template;
  for (const [key, value] of Object.entries(data)) {
    html = html.replace(new RegExp(`{{${key}}}`, 'g'), value);
  }
  return mjml2html(html).html;
}
```

### React Email

```typescript
import { render } from '@react-email/render';
import { Html, Head, Body, Container, Text, Button } from '@react-email/components';

function WelcomeEmail({ name, ctaUrl }: { name: string; ctaUrl: string }) {
  return (
    <Html>
      <Head />
      <Body style={{ backgroundColor: '#f6f9fc' }}>
        <Container>
          <Text>Welcome, {name}!</Text>
          <Text>Thank you for joining us.</Text>
          <Button href={ctaUrl}>Get Started</Button>
        </Container>
      </Body>
    </Html>
  );
}

const html = render(<WelcomeEmail name="John" ctaUrl="https://example.com" />);
```

## 邮件队列

```typescript
import { Queue, Worker } from 'bullmq';

const emailQueue = new Queue('emails', { connection: redis });

async function queueEmail(email: EmailOptions) {
  await emailQueue.add('send', email, {
    attempts: 3,
    backoff: {
      type: 'exponential',
      delay: 1000,
    },
  });
}

const emailWorker = new Worker(
  'emails',
  async (job) => {
    await sendEmail(job.data);
  },
  { connection: redis }
);
```

## 常见邮件类型

```typescript
class EmailService {
  async sendWelcomeEmail(user: User) {
    await sendEmail({
      to: user.email,
      subject: 'Welcome to Our Platform',
      html: renderTemplate(welcomeTemplate, {
        name: user.name,
        ctaUrl: `${process.env.APP_URL}/dashboard`,
      }),
    });
  }

  async sendPasswordResetEmail(user: User, token: string) {
    const resetUrl = `${process.env.APP_URL}/reset-password?token=${token}`;

    await sendEmail({
      to: user.email,
      subject: 'Reset Your Password',
      html: renderTemplate(passwordResetTemplate, {
        name: user.name,
        resetUrl,
      }),
    });
  }

  async sendVerificationEmail(user: User, token: string) {
    const verifyUrl = `${process.env.APP_URL}/verify?token=${token}`;

    await sendEmail({
      to: user.email,
      subject: 'Verify Your Email',
      html: renderTemplate(verificationTemplate, {
        name: user.name,
        verifyUrl,
      }),
    });
  }

  async sendInvoiceEmail(user: User, invoice: Invoice) {
    await sendEmail({
      to: user.email,
      subject: `Invoice #${invoice.number}`,
      html: renderTemplate(invoiceTemplate, {
        name: user.name,
        invoiceNumber: invoice.number,
        amount: invoice.amount,
      }),
      attachments: [
        {
          filename: `invoice-${invoice.number}.pdf`,
          content: invoice.pdf,
          contentType: 'application/pdf',
        },
      ],
    });
  }
}
```

## 快速参考

```typescript
// 发送邮件
await sendEmail({ to, subject, html });

// 使用模板
const html = renderTemplate(template, { name, url });

// 队列发送
await queueEmail({ to, subject, html });

// 发送带附件
await sendEmail({ to, subject, html, attachments });
```

## 参考

- [Nodemailer](https://nodemailer.com/)
- [SendGrid](https://docs.sendgrid.com/)
- [Resend](https://resend.com/docs)
- [React Email](https://react.email/)
- [MJML](https://mjml.io/)
