---
name: payment-stripe-patterns
description: Stripe 支付集成模式 - 订阅、支付、Webhook 最佳实践
---

# Stripe 支付集成模式

> 订阅管理、支付处理、Webhook 处理的最佳实践

## 何时激活

- 实现支付功能
- 订阅管理系统
- 处理退款
- 发票生成
- 支付安全

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| Stripe SDK | 14.0+ | 最新 |
| Node.js | 18.0+ | 20.0+ |

## 核心概念

```
┌─────────────────────────────────────────────────────────────┐
│                    Stripe 支付流程                           │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │   Customer  │────>│ PaymentMethod│────>│   Payment   │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│         │                   │                   │          │
│         │                   │                   ▼          │
│         │                   │           ┌─────────────┐    │
│         │                   │           │  Invoice    │    │
│         │                   │           └─────────────┘    │
│         │                   │                   │          │
│         ▼                   ▼                   ▼          │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │ Subscription│────>│   Product   │────>│    Price    │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 初始化

```typescript
import Stripe from 'stripe';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY!, {
  apiVersion: '2024-01-01',
});
```

## 客户管理

```typescript
async function createCustomer(email: string, name: string) {
  return stripe.customers.create({
    email,
    name,
    metadata: {
      source: 'app',
    },
  });
}

async function getCustomer(customerId: string) {
  return stripe.customers.retrieve(customerId);
}

async function updateCustomer(customerId: string, data: Partial<Stripe.CustomerUpdateParams>) {
  return stripe.customers.update(customerId, data);
}
```

## 支付意图

```typescript
async function createPaymentIntent(
  amount: number,
  currency: string,
  customerId: string
) {
  return stripe.paymentIntents.create({
    amount,
    currency,
    customer: customerId,
    automatic_payment_methods: {
      enabled: true,
    },
    metadata: {
      orderId: crypto.randomUUID(),
    },
  });
}

async function confirmPaymentIntent(paymentIntentId: string) {
  return stripe.paymentIntents.confirm(paymentIntentId);
}
```

## 订阅管理

```typescript
async function createSubscription(
  customerId: string,
  priceId: string,
  paymentMethodId: string
) {
  await stripe.paymentMethods.attach(paymentMethodId, {
    customer: customerId,
  });

  await stripe.customers.update(customerId, {
    invoice_settings: {
      default_payment_method: paymentMethodId,
    },
  });

  return stripe.subscriptions.create({
    customer: customerId,
    items: [{ price: priceId }],
    expand: ['latest_invoice.payment_intent'],
  });
}

async function cancelSubscription(subscriptionId: string) {
  return stripe.subscriptions.cancel(subscriptionId);
}

async function updateSubscription(
  subscriptionId: string,
  newPriceId: string
) {
  const subscription = await stripe.subscriptions.retrieve(subscriptionId);
  
  return stripe.subscriptions.update(subscriptionId, {
    items: [{
      id: subscription.items.data[0].id,
      price: newPriceId,
    }],
    proration_behavior: 'create_prorations',
  });
}
```

## Webhook 处理

```typescript
import express, { Request, Response } from 'express';

const app = express();

app.post('/webhook/stripe', express.raw({ type: 'application/json' }), async (req: Request, res: Response) => {
  const sig = req.headers['stripe-signature'] as string;
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET!;

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(req.body, sig, webhookSecret);
  } catch (err) {
    console.error('Webhook signature verification failed:', err);
    return res.status(400).send('Webhook Error');
  }

  switch (event.type) {
    case 'payment_intent.succeeded':
      await handlePaymentSucceeded(event.data.object as Stripe.PaymentIntent);
      break;
    case 'invoice.paid':
      await handleInvoicePaid(event.data.object as Stripe.Invoice);
      break;
    case 'customer.subscription.deleted':
      await handleSubscriptionDeleted(event.data.object as Stripe.Subscription);
      break;
    case 'customer.subscription.updated':
      await handleSubscriptionUpdated(event.data.object as Stripe.Subscription);
      break;
  }

  res.json({ received: true });
});

async function handlePaymentSucceeded(paymentIntent: Stripe.PaymentIntent) {
  const orderId = paymentIntent.metadata.orderId;
  await updateOrderStatus(orderId, 'paid');
}

async function handleInvoicePaid(invoice: Stripe.Invoice) {
  const customerId = invoice.customer as string;
  await extendSubscription(customerId);
}

async function handleSubscriptionDeleted(subscription: Stripe.Subscription) {
  const customerId = subscription.customer as string;
  await revokeAccess(customerId);
}
```

## 退款处理

```typescript
async function createRefund(paymentIntentId: string, amount?: number) {
  return stripe.refunds.create({
    payment_intent: paymentIntentId,
    amount,
    reason: 'requested_by_customer',
  });
}

async function getRefund(refundId: string) {
  return stripe.refunds.retrieve(refundId);
}
```

## 产品和价格

```typescript
async function createProduct(name: string, description: string) {
  return stripe.products.create({
    name,
    description,
    active: true,
  });
}

async function createPrice(
  productId: string,
  amount: number,
  currency: string,
  interval: 'month' | 'year'
) {
  return stripe.prices.create({
    product: productId,
    unit_amount: amount,
    currency,
    recurring: {
      interval,
    },
  });
}

async function listPrices(productId: string) {
  return stripe.prices.list({
    product: productId,
    active: true,
  });
}
```

## 快速参考

```typescript
// 创建客户
const customer = await stripe.customers.create({ email, name });

// 创建支付意图
const intent = await stripe.paymentIntents.create({ amount, currency, customer });

// 创建订阅
const subscription = await stripe.subscriptions.create({ customer, items: [{ price }] });

// 处理 Webhook
const event = stripe.webhooks.constructEvent(body, sig, secret);

// 退款
const refund = await stripe.refunds.create({ payment_intent: id });
```

## 参考

- [Stripe Docs](https://stripe.com/docs)
- [Stripe API Reference](https://stripe.com/docs/api)
- [Stripe Samples](https://github.com/stripe-samples)
