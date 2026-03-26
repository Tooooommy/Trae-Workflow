---
name: payment-patterns
description: 支付集成模式 - 微信支付、支付宝、抖音支付、Stripe、PayPal 最佳实践。**必须激活当**：用户要求集成支付、处理订单、退款或订阅时。即使用户没有明确说"支付"，当涉及支付流程、资金流转或订单处理时也应使用。
---

# 支付集成模式

> 聚合多种支付渠道的统一支付模式

## 何时激活

- 实现支付功能
- 处理订单和退款
- 订阅管理
- 跨境支付
- 支付安全

## 技术栈版本

| 技术          | 最低版本 | 推荐版本 |
| ------------- | -------- | -------- |
| Stripe SDK    | 14.0+    | 最新     |
| Alipay SDK    | 4.35.0+  | 最新     |
| WeChatPay SDK | 3.1.0+   | 最新     |
| PayPal SDK    | 1.0.0+   | 最新     |
| Node.js       | 18.0+    | 20.0+    |

## 支付方案对比

| 方案     | 类型     | 适用场景           | 特点                 |
| -------- | -------- | ------------------ | -------------------- |
| Stripe   | 国际支付 | 跨境电商、SaaS     | 订阅强大、全球覆盖   |
| PayPal   | 国际支付 | 跨境电商、外贸     | 用户基数大、覆盖广   |
| 支付宝   | 国内支付 | 国内电商、移动支付 | 成熟稳定、用户广泛   |
| 微信支付 | 国内支付 | 国内电商、社交电商 | 微信生态、小程序集成 |
| 抖音支付 | 国内支付 | 抖音电商、直播带货 | 流量入口、场景丰富   |

## 统一支付接口

```typescript
interface PaymentProvider {
  createPayment(params: PaymentParams): Promise<PaymentResult>;
  refundPayment(params: RefundParams): Promise<RefundResult>;
  queryPayment(paymentId: string): Promise<PaymentStatus>;
  handleWebhook(payload: unknown): Promise<void>;
}

interface PaymentParams {
  amount: number;
  currency: string;
  orderId: string;
  description?: string;
  metadata?: Record<string, string>;
  returnUrl?: string;
  payer?: {
    openid?: string;
    email?: string;
  };
}

interface PaymentResult {
  paymentId: string;
  status: 'pending' | 'completed' | 'failed';
  paymentUrl?: string;
  qrCode?: string;
  expiresAt?: Date;
}

interface RefundParams {
  paymentId: string;
  refundId: string;
  amount: number;
  reason?: string;
}

interface RefundResult {
  success: boolean;
  refundId: string;
  status: string;
}

interface PaymentStatus {
  paymentId: string;
  status: 'pending' | 'paid' | 'closed' | 'refunded';
  amount: number;
  paidAt?: Date;
}
```

## 统一支付工厂

```typescript
function createPaymentProvider(type: string): PaymentProvider {
  switch (type) {
    case 'stripe':
      return new StripeProvider();
    case 'paypal':
      return new PayPalProvider();
    case 'alipay':
      return new AlipayProvider();
    case 'wechatpay':
      return new WeChatPayProvider();
    case 'douyinpay':
      return new DouyinPayProvider();
    default:
      throw new Error(`Unsupported payment provider: ${type}`);
  }
}

async function unifiedPayment(providerType: string, params: PaymentParams) {
  const provider = createPaymentProvider(providerType);
  return provider.createPayment(params);
}
```

## Stripe 集成

### 初始化

```typescript
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-01-01',
});
```

### 支付意图

```typescript
async function createStripePayment(params: PaymentParams): Promise<PaymentResult> {
  const paymentIntent = await stripe.paymentIntents.create({
    amount: Math.round(params.amount * 100),
    currency: params.currency.toLowerCase(),
    metadata: {
      orderId: params.orderId,
      ...params.metadata,
    },
    automatic_payment_methods: {
      enabled: true,
    },
  });

  return {
    paymentId: paymentIntent.id,
    status: 'pending',
    paymentUrl: `https://pay.stripe.com/${paymentIntent.id}`,
  };
}
```

### 订阅管理

```typescript
async function createStripeSubscription(
  customerId: string,
  priceId: string
): Promise<PaymentResult> {
  const subscription = await stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
    payment_behavior: 'default_incomplete',
    expand: ['latest_invoice.payment_intent'],
  });

  const invoice = subscription.latest_invoice as Stripe.Invoice;
  const paymentIntent = invoice.payment_intent as Stripe.PaymentIntent;

  return {
    paymentId: subscription.id,
    status: 'pending',
    paymentUrl: paymentIntent.hosted_payment_page!,
  };
}
```

### Webhook 处理

```typescript
async function handleStripeWebhook(payload: Buffer, signature: string): Promise<void> {
  const event = stripe.webhooks.constructEvent(
    payload,
    signature,
    process.env.STRIPE_WEBHOOK_SECRET!
  );

  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentSuccess(event.data.object as Stripe.PaymentIntent);
      break;
    case 'payment_intent.payment_failed':
      await handlePaymentFailed(event.data.object as Stripe.PaymentIntent);
      break;
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
      break;
  }
}
```

## PayPal 集成

### 初始化

```typescript
import checkout from '@paypal/checkout-server-sdk';

const paypalClient = new checkout.PayPalHttpClient({
  clientId: process.env.PAYPAL_CLIENT_ID!,
  clientSecret: process.env.PAYPAL_CLIENT_SECRET!,
  environment:
    process.env.NODE_ENV === 'production'
      ? checkout.CoreEnvironments.Live
      : checkout.CoreEnvironments.Sandbox,
});
```

### 创建订单

```typescript
async function createPayPalOrder(params: PaymentParams): Promise<PaymentResult> {
  const request = new checkout.orders.OrdersCreateRequest();
  request.requestBody({
    intent: 'CAPTURE',
    purchase_units: [
      {
        reference_id: params.orderId,
        amount: {
          currency_code: params.currency,
          value: params.amount.toFixed(2),
        },
        description: params.description,
      },
    ],
    application_context: {
      return_url: params.returnUrl,
      cancel_url: `${params.returnUrl}/cancel`,
    },
  });

  const response = await paypalClient.execute(request);

  return {
    paymentId: response.result.id,
    status: 'pending',
    paymentUrl: response.result.links.find((l) => l.rel === 'approve')?.href,
  };
}
```

### 确认支付

```typescript
async function capturePayPalOrder(orderId: string): Promise<PaymentResult> {
  const request = new checkout.orders.OrdersCaptureRequest(orderId);
  request.requestBody({});

  const response = await paypalClient.execute(request);

  return {
    paymentId: response.result.id,
    status: response.result.status === 'COMPLETED' ? 'completed' : 'pending',
  };
}
```

## 支付宝集成

### 初始化

```typescript
import AlipaySdk from 'alipay-sdk';

const alipay = new AlipaySdk({
  appId: process.env.ALIPAY_APP_ID!,
  privateKey: process.env.ALIPAY_PRIVATE_KEY!,
  alipayPublicKey: process.env.ALIPAY_PUBLIC_KEY!,
  signType: 'RSA2',
  gateway: 'https://openapi.alipay.com/gateway.do',
});
```

### 支付请求

```typescript
async function createAlipayPayment(params: PaymentParams): Promise<PaymentResult> {
  const result = await alipay.exec('alipay.trade.page.pay', {
    outTradeNo: params.orderId,
    totalAmount: params.amount.toFixed(2),
    subject: params.description || 'Payment',
    productCode: 'FAST_INSTANT_TRADE_PAY',
    returnUrl: params.returnUrl,
    notifyUrl: `${process.env.API_URL}/webhooks/alipay`,
  });

  return {
    paymentId: params.orderId,
    status: 'pending',
    paymentUrl: result,
  };
}
```

### 退款

```typescript
async function refundAlipayPayment(refundParams: RefundParams): Promise<RefundResult> {
  const result = await alipay.exec('alipay.trade.refund', {
    outTradeNo: refundParams.paymentId,
    refundAmount: refundParams.amount.toFixed(2),
    refundReason: refundParams.reason,
    outRequestNo: refundParams.refundId,
  });

  return {
    success: result.code === '10000',
    refundId: result.trade_no,
    status: result.msg,
  };
}
```

## 微信支付集成

### 初始化

```typescript
import { WeChatPay } from 'wechatpay-node-sdk';

const wxpay = new WeChatPay({
  mchid: process.env.WX_MCHID!,
  serial: process.env.WX_SERIAL_NO!,
  privateKey: process.env.WX_PRIVATE_KEY!,
  certificates: {},
});
```

### Native 支付

```typescript
async function createWeChatPayment(params: PaymentParams): Promise<PaymentResult> {
  const result = await wxpay.v3.pay.pay.transactions.native({
    amount: {
      total: Math.round(params.amount * 100),
      currency: params.currency,
    },
    appid: process.env.WX_APPID!,
    description: params.description,
    out_trade_no: params.orderId,
    notify_url: `${process.env.API_URL}/webhooks/wechatpay`,
  });

  return {
    paymentId: params.orderId,
    status: 'pending',
    qrCode: result.code_url,
  };
}
```

### JSAPI 支付

```typescript
async function createWeChatJSAPIPayment(
  params: PaymentParams,
  openid: string
): Promise<PaymentResult> {
  const result = await wxpay.v3.pay.pay.transactions.jsapi({
    amount: {
      total: Math.round(params.amount * 100),
      currency: params.currency,
    },
    appid: process.env.WX_APPID!,
    description: params.description,
    out_trade_no: params.orderId,
    payer: { openid },
    notify_url: `${process.env.API_URL}/webhooks/wechatpay`,
  });

  return {
    paymentId: params.orderId,
    status: 'pending',
    paymentUrl: result.h5_url,
  };
}
```

## 抖音支付集成

### 初始化

```typescript
import DouyinPay from '@douyin/pay';

const dyPay = new DouyinPay({
  appId: process.env.DY_APP_ID!,
  appSecret: process.env.DY_APP_SECRET!,
});
```

### 支付请求

```typescript
async function createDouyinPayment(params: PaymentParams): Promise<PaymentResult> {
  const order = await dyPay.order.create({
    order_id: params.orderId,
    amount: Math.round(params.amount * 100),
    currency: params.currency === 'CNY' ? 'CNY' : 'USD',
    subject: params.description,
    body: params.description,
    notify_url: `${process.env.API_URL}/webhooks/douyin`,
  });

  return {
    paymentId: params.orderId,
    status: 'pending',
    paymentUrl: order.pay_url,
    qrCode: order.qr_code,
  };
}
```

## 统一退款处理

```typescript
async function processRefund(provider: string, params: RefundParams): Promise<RefundResult> {
  switch (provider) {
    case 'stripe':
      const stripeRefund = await stripe.refunds.create({
        payment_intent: params.paymentId,
        amount: Math.round(params.amount * 100),
      });
      return { success: true, refundId: stripeRefund.id, status: stripeRefund.status };

    case 'paypal':
      const captureId = params.metadata?.captureId;
      if (!captureId) throw new Error('Missing captureId for PayPal refund');
      const paypalRefund = await refundPayPalCapture(captureId, params.amount);
      return { success: true, refundId: paypalRefund.refundId, status: paypalRefund.status };

    case 'alipay':
      return refundAlipayPayment(params);

    case 'wechatpay':
      return refundWeChatPayment(params);

    case 'douyinpay':
      return refundDouyinPayment(params);

    default:
      throw new Error(`Unsupported provider: ${provider}`);
  }
}
```

## 支付安全最佳实践

| 措施         | 实现                       |
| ------------ | -------------------------- |
| 签名验证     | 验证回调签名确保真实性     |
| 幂等性       | 使用订单号防止重复支付     |
| 金额校验     | 服务端校验金额与数据库一致 |
| 异步处理     | 支付回调异步处理避免超时   |
| 日志记录     | 完整记录支付流程便于审计   |
| 限流         | 防止恶意请求刷单           |
| 证书安全     | 私钥妥善保管，旋转更新     |
| 敏感数据保护 | 不在日志中记录完整卡号等   |

## 错误处理

```typescript
class PaymentError extends Error {
  constructor(
    public code: string,
    message: string,
    public provider: string,
    public isRetryable: boolean = false
  ) {
    super(message);
    this.name = 'PaymentError';
  }
}

async function handlePaymentError(error: unknown, provider: string) {
  if (error instanceof PaymentError) {
    console.error(`Payment error [${provider}]:`, error.code, error.message);
    if (error.isRetryable) {
      await requeuePayment(error);
    }
  } else {
    console.error('Unexpected payment error:', error);
  }
}
```

## 相关技能

| 技能               | 说明             |
| ------------------ | ---------------- |
| stripe-patterns    | Stripe 详细集成  |
| alipay-patterns    | 支付宝详细集成   |
| wechatpay-patterns | 微信支付详细集成 |
| paypal-patterns    | PayPal 详细集成  |
| douyinpay-patterns | 抖音支付详细集成 |
| security-expert    | 支付安全         |
