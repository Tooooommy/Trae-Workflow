---
name: alipay-patterns
description: 支付宝支付集成模式 - 电脑网站支付、手机网站支付、APP 支付、当面付及退款、查询等最佳实践。**必须激活当**：用户要求集成支付宝、处理支付或实现退款查询时。即使用户没有明确说"支付宝"，当涉及支付集成或第三方支付时也应使用。
---

# 支付宝支付集成模式

> 电脑网站支付、手机网站支付、APP 支付、当面付及退款、查询等最佳实践

## 何时激活

- 实现支付宝支付功能
- 电脑网站支付 (Web)
- 手机网站支付 (H5)
- APP 支付 (iOS/Android)
- 当面付 (扫码)
- 支付退款处理
- 订单查询与管理

## 技术栈版本

| 技术       | 最低版本 | 推荐版本 |
| ---------- | -------- | -------- |
| alipay-sdk | 4.35.0+  | 最新     |
| Node.js    | 16.0+    | 20.0+    |
| Redis      | 6.0+     | 7.0+     |

## 核心概念

```
┌─────────────────────────────────────────────────────────────┐
│                    支付宝支付流程                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │   商户下单   │────>│  构造请求    │────>│   支付宝    │  │
│   └─────────────┘     └─────────────┘     │   收银台    │  │
│                                            └─────────────┘  │
│                                                   │         │
│                                                   ▼         │
│                                            ┌─────────────┐  │
│                                            │   支付结果   │  │
│                                            └─────────────┘  │
│                                                   │         │
│                                                   ▼         │
│                                            ┌─────────────┐  │
│                                            │   异步通知   │  │
│                                            └─────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## 初始化

```typescript
import AlipaySdk from 'alipay-sdk';

const alipay = new AlipaySdk({
  appId: process.env.ALIPAY_APP_ID!,
  privateKey: process.env.ALIPAY_PRIVATE_KEY!,
  alipayPublicKey: process.env.ALIPAY_PUBLIC_KEY!,
  signType: 'RSA2', // 推荐使用 RSA2
});
```

## 电脑网站支付 (Web)

### 构造支付请求

```typescript
async function createWebPayOrder(orderId: string, amount: number, subject: string) {
  const result = await alipay.exec('alipay.trade.page.pay', {
    outTradeNo: orderId,
    productCode: 'FAST_INSTANT_TRADE_PAY',
    totalAmount: amount.toString(),
    subject,
    body: `订单${orderId}的描述`,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/web/notify`,
    returnUrl: `${process.env.BASE_URL}/api/payment/alipay/web/return`,
  });

  // 返回的是表单 HTML，可直接返回给前端
  return result;
}

// Express/Koa 示例
app.post('/api/payment/alipay/web/pay', async (ctx) => {
  const { orderId, amount, subject } = ctx.request.body;
  const form = await createWebPayOrder(orderId, amount, subject);
  ctx.body = { form };
});
```

### 同步跳转处理

```typescript
app.get('/api/payment/alipay/web/return', async (ctx) => {
  const { out_trade_no, trade_no } = ctx.query;

  // 验证签名
  const signResult = alipay.checkNotifySign(ctx.query);
  if (!signResult) {
    ctx.status = 403;
    ctx.body = '验签失败';
    return;
  }

  // 根据 out_trade_no 查询并更新订单状态
  await updateOrderByTradeNo(out_trade_no, {
    status: 'PAID',
    alipayTradeNo: trade_no,
  });

  ctx.redirect('/order/success');
});
```

## 手机网站支付 (H5)

```typescript
async function createH5PayOrder(orderId: string, amount: number, subject: string) {
  const result = await alipay.exec('alipay.trade.wap.pay', {
    outTradeNo: orderId,
    productCode: 'QUICK_WAP_WAY',
    totalAmount: amount.toString(),
    subject,
    body: `订单${orderId}的描述`,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/h5/notify`,
    quitUrl: `${process.env.BASE_URL}/payment/cancel`,
  });

  return result;
}
```

## APP 支付

```typescript
async function createAppPayOrder(orderId: string, amount: number, subject: string) {
  const result = await alipay.exec('alipay.trade.app.pay', {
    outTradeNo: orderId,
    productCode: 'QUICK_MSECURITY_PAY',
    totalAmount: amount.toString(),
    subject,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/app/notify`,
  });

  // 返回的是请求参数字符串，客户端直接使用
  return result;
}
```

## 当面付 (扫码)

```typescript
async function createScanPayOrder(orderId: string, amount: number, subject: string) {
  const result = await alipay.exec('alipay.trade.pay', {
    outTradeNo: orderId,
    totalAmount: amount.toString(),
    subject,
    authCode: '用户授权码', // 扫码枪扫描的用户支付宝付款码
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/scan/notify`,
  });

  return {
    tradeNo: result.trade_no,
    outTradeNo: result.out_trade_no,
    buyerLogId: result.buyer_log_id,
    status: result.code, // 10000 表示成功
  };
}
```

## 异步通知处理

```typescript
app.post('/api/payment/alipay/notify', async (ctx) => {
  const postData = ctx.request.body;

  // 验证签名
  const signResult = alipay.checkNotifySign(postData);
  if (!signResult) {
    ctx.status = 403;
    ctx.body = 'fail';
    return;
  }

  const { trade_status, out_trade_no, trade_no, total_amount } = postData;

  if (trade_status === 'TRADE_SUCCESS' || trade_status === 'TRADE_FINISHED') {
    // 支付成功
    await updateOrderByTradeNo(out_trade_no, {
      status: 'PAID',
      alipayTradeNo: trade_no,
      paidAmount: parseFloat(total_amount),
    });

    // 回复支付宝
    ctx.body = 'success';
  } else {
    ctx.body = 'fail';
  }
});
```

## 订单查询

```typescript
async function queryOrder(orderId: string) {
  const result = await alipay.exec('alipay.trade.query', {
    out_trade_no: orderId,
  });

  return {
    code: result.code,
    status: result.trade_status,
    amount: result.total_amount,
    buyerEmail: result.buyer_logon_id,
    transactionId: result.trade_no,
  };
}
```

## 退款

```typescript
async function refundOrder(orderId: string, refundAmount: number, reason?: string) {
  const result = await alipay.exec('alipay.trade.refund', {
    out_trade_no: orderId,
    refund_amount: refundAmount.toString(),
    refund_reason: reason || '用户主动退款',
  });

  return {
    code: result.code,
    refundTradeNo: result.trade_no,
    buyerLogId: result.buyer_log_id,
  };
}
```

## 退款查询

```typescript
async function queryRefund(orderId: string, refundId: string) {
  const result = await alipay.exec('alipay.trade.fastpay.refund.query', {
    out_trade_no: orderId,
    out_request_no: refundId,
  });

  return {
    code: result.code,
    status: result.refund_status,
    refundAmount: result.refund_amount,
  };
}
```

## 关闭订单

```typescript
async function closeOrder(orderId: string) {
  const result = await alipay.exec('alipay.trade.close', {
    out_trade_no: orderId,
  });

  return { code: result.code };
}
```

## 快速参考

```typescript
import AlipaySdk from 'alipay-sdk';

const alipay = new AlipaySdk({
  appId: process.env.ALIPAY_APP_ID!,
  privateKey: process.env.ALIPAY_PRIVATE_KEY!,
  alipayPublicKey: process.env.ALIPAY_PUBLIC_KEY!,
  signType: 'RSA2',
});

// 电脑网站支付
await alipay.exec('alipay.trade.page.pay', {
  outTradeNo: '订单号',
  totalAmount: '0.01',
  subject: '商品',
  productCode: 'FAST_INSTANT_TRADE_PAY',
});

// 手机网站支付
await alipay.exec('alipay.trade.wap.pay', {
  outTradeNo: '订单号',
  totalAmount: '0.01',
  subject: '商品',
  productCode: 'QUICK_WAP_WAY',
});

// APP 支付
await alipay.exec('alipay.trade.app.pay', {
  outTradeNo: '订单号',
  totalAmount: '0.01',
  subject: '商品',
  productCode: 'QUICK_MSECURITY_PAY',
});

// 当面付
await alipay.exec('alipay.trade.pay', {
  outTradeNo: '订单号',
  totalAmount: '0.01',
  subject: '商品',
  authCode: '用户付款码',
});

// 查询
await alipay.exec('alipay.trade.query', { out_trade_no: '订单号' });

// 退款
await alipay.exec('alipay.trade.refund', { out_trade_no: '订单号', refund_amount: '0.01' });
```

## 参考

- [支付宝开放平台文档](https://opendocs.alipay.com/)
- [alipay-sdk-nodejs](https://www.npmjs.com/package/alipay-sdk)
