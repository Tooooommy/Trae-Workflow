---
name: alipay-patterns
description: 支付宝支付集成模式。**必须激活当**：用户要求集成支付宝、处理支付或实现退款查询时。需与 payment-patterns 配合使用，payment-patterns 提供统一支付接口和通用模式。
---

# 支付宝支付集成模式

> 专注支付宝特有功能，与 payment-patterns 配合使用

## 何时激活

- 集成支付宝支付功能
- 电脑网站支付 (Web)
- 手机网站支付 (H5)
- APP 支付 (iOS/Android)
- 当面付 (扫码)

> **提示**：通用支付概念（统一接口、订单管理、退款流程）请参考 [payment-patterns](../payment-patterns/SKILL.md)

## 技术栈

| 技术       | 版本    |
| ---------- | ------- |
| alipay-sdk | 4.35.0+ |
| Node.js    | 18.0+   |

## 初始化

### SDK 初始化

```typescript
import AlipaySdk from 'alipay-sdk';

const alipay = new AlipaySdk({
  appId: process.env.ALIPAY_APP_ID!,
  privateKey: process.env.ALIPAY_PRIVATE_KEY!,
  alipayPublicKey: process.env.ALIPAY_PUBLIC_KEY!,
  signType: 'RSA2',
  gateway: process.env.ALIPAY_GATEWAY,
  timeout: 30000,
});
```

### 环境配置

```typescript
const config = {
  development: { gateway: 'https://openapi.alipaydev.com/gateway.do' },
  production: { gateway: 'https://openapi.alipay.com/gateway.do' },
}[process.env.NODE_ENV || 'development'];
```

## 支付方式

| 支付方式     | productCode              | 返回格式       |
| ------------ | ------------------------ | -------------- |
| 电脑网站支付 | `FAST_INSTANT_TRADE_PAY` | HTML 表单      |
| 手机网站支付 | `QUICK_WAP_WAY`          | HTML 表单      |
| APP 支付     | `QUICK_MSECURITY_PAY`    | 请求参数字符串 |
| 当面付       | `FAST_INSTANT_TRADE_PAY` | 直接返回结果   |

## 支付实现

### 电脑网站支付

```typescript
async function createWebPayOrder(orderId: string, amount: number, subject: string) {
  return await alipay.exec('alipay.trade.page.pay', {
    outTradeNo: orderId,
    productCode: 'FAST_INSTANT_TRADE_PAY',
    totalAmount: amount.toString(),
    subject,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/notify`,
    returnUrl: `${process.env.BASE_URL}/payment/result`,
  });
}
```

### 手机网站支付

```typescript
async function createH5PayOrder(orderId: string, amount: number, subject: string) {
  return await alipay.exec('alipay.trade.wap.pay', {
    outTradeNo: orderId,
    productCode: 'QUICK_WAP_WAY',
    totalAmount: amount.toString(),
    subject,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/notify`,
    quitUrl: `${process.env.BASE_URL}/payment/cancel`,
  });
}
```

### APP 支付

```typescript
async function createAppPayOrder(orderId: string, amount: number, subject: string) {
  return await alipay.exec('alipay.trade.app.pay', {
    outTradeNo: orderId,
    productCode: 'QUICK_MSECURITY_PAY',
    totalAmount: amount.toString(),
    subject,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/notify`,
  });
}
```

### 当面付

```typescript
async function createScanPayOrder(
  orderId: string,
  amount: number,
  subject: string,
  authCode: string
) {
  const result = await alipay.exec('alipay.trade.pay', {
    outTradeNo: orderId,
    totalAmount: amount.toString(),
    subject,
    authCode,
    notifyUrl: `${process.env.BASE_URL}/api/payment/alipay/notify`,
  });

  return {
    success: result.code === '10000',
    tradeNo: result.trade_no,
    message: result.msg,
  };
}
```

## 回调处理

### 异步通知

```typescript
router.post('/notify', async (req, res) => {
  const signResult = alipay.checkNotifySign(req.body);
  if (!signResult) {
    res.status(403).send('fail');
    return;
  }

  const { trade_status, out_trade_no, trade_no } = req.body;

  if (trade_status === 'TRADE_SUCCESS' || trade_status === 'TRADE_FINISHED') {
    await orderService.updateByTradeNo(out_trade_no, {
      status: 'PAID',
      alipayTradeNo: trade_no,
    });
  }

  res.send('success');
});
```

### 同步回调

```typescript
router.get('/return', async (req, res) => {
  const signResult = alipay.checkNotifySign(req.query);
  if (!signResult) {
    res.redirect('/payment/failed');
    return;
  }

  const { out_trade_no } = req.query;
  res.redirect(`/order/success?orderId=${out_trade_no}`);
});
```

## 退款

```typescript
async function refundOrder(orderId: string, refundId: string, amount: number) {
  const result = await alipay.exec('alipay.trade.refund', {
    outTradeNo: orderId,
    outRequestNo: refundId,
    refundAmount: amount.toString(),
  });

  return {
    success: result.code === '10000',
    refundId: result.trade_no,
  };
}
```

## 订单查询

```typescript
async function queryOrder(orderId: string) {
  const result = await alipay.exec('alipay.trade.query', {
    outTradeNo: orderId,
  });

  return {
    status: result.tradeStatus,
    amount: result.totalAmount,
    payTime: result.sendPayDate,
  };
}
```

## 安全配置

### 环境变量

```bash
ALIPAY_APP_ID=2021xxxxxx
ALIPAY_PRIVATE_KEY=-----BEGIN RSA PRIVATE KEY-----
ALIPAY_PUBLIC_KEY=-----BEGIN PUBLIC KEY-----
ALIPAY_GATEWAY=https://openapi.alipay.com/gateway.do
```

### 必检项

- [ ] 使用 RSA2 签名
- [ ] 所有回调验证签名
- [ ] 实现幂等性处理
- [ ] 回调地址使用 HTTPS
- [ ] 敏感信息存环境变量

## 错误码

| 错误码  | 说明         |
| ------- | ------------ |
| `10000` | 成功         |
| `20000` | 服务未知错误 |
| `40004` | 业务处理失败 |

## 参考

- [支付宝开放平台](https://opendocs.alipay.com/)
- [alipay-sdk-nodejs](https://www.npmjs.com/package/alipay-sdk)
