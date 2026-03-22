---
name: i18n-patterns
description: 国际化模式 - 多语言、本地化、区域设置最佳实践
---

# 国际化模式

> 多语言支持、本地化、区域设置的最佳实践

## 何时激活

- 实现多语言支持
- 日期/数字格式化
- 货币本地化
- 内容翻译
- 区域适配

## 技术栈版本

| 技术          | 最低版本 | 推荐版本   |
| ------------- | -------- | ---------- |
| i18next       | 23.0+    | 最新       |
| react-i18next | 14.0+    | 最新       |
| Intl API      | -        | 浏览器原生 |
| formatjs      | 10.0+    | 最新       |

## 核心概念

```
┌─────────────────────────────────────────────────────────────┐
│                    国际化 (i18n) 架构                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │   语言检测   │────>│   翻译加载   │────>│   格式化    │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│         │                   │                   │          │
│         ▼                   ▼                   ▼          │
│   ┌─────────────┐     ┌─────────────┐     ┌─────────────┐  │
│   │  浏览器设置  │     │  翻译文件    │     │  日期/数字   │  │
│   │  URL 参数   │     │  JSON/YAML   │     │  货币/复数   │  │
│   │  Cookie    │     │  数据库      │     │  排序规则    │  │
│   └─────────────┘     └─────────────┘     └─────────────┘  │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## i18next 配置

```typescript
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import HttpBackend from 'i18next-http-backend';
import LanguageDetector from 'i18next-browser-languagedetector';

i18n
  .use(HttpBackend)
  .use(LanguageDetector)
  .use(initReactI18next)
  .init({
    fallbackLng: 'en',
    supportedLngs: ['en', 'zh', 'ja', 'ko', 'es', 'fr', 'de'],
    debug: process.env.NODE_ENV === 'development',
    interpolation: {
      escapeValue: false,
    },
    backend: {
      loadPath: '/locales/{{lng}}/{{ns}}.json',
    },
    detection: {
      order: ['querystring', 'cookie', 'localStorage', 'navigator'],
      caches: ['cookie', 'localStorage'],
    },
  });

export default i18n;
```

## 翻译文件结构

```
locales/
├── en/
│   ├── common.json
│   ├── auth.json
│   └── dashboard.json
├── zh/
│   ├── common.json
│   ├── auth.json
│   └── dashboard.json
└── ja/
    ├── common.json
    ├── auth.json
    └── dashboard.json
```

### 翻译文件示例

```json
{
  "welcome": "Welcome, {{name}}!",
  "items": {
    "one": "{{count}} item",
    "other": "{{count}} items"
  },
  "navigation": {
    "home": "Home",
    "about": "About",
    "contact": "Contact"
  },
  "errors": {
    "required": "This field is required",
    "email": "Please enter a valid email"
  }
}
```

## React 使用

```tsx
import { useTranslation, Trans } from 'react-i18next';

function Component() {
  const { t, i18n } = useTranslation();

  return (
    <div>
      <h1>{t('welcome', { name: 'John' })}</h1>
      <p>{t('items', { count: 5 })}</p>

      <Trans i18nKey="description">
        Welcome to <strong>our app</strong>!
      </Trans>

      <button onClick={() => i18n.changeLanguage('zh')}>切换中文</button>
    </div>
  );
}
```

## 日期格式化

```typescript
function formatDate(date: Date, locale: string, options?: Intl.DateTimeFormatOptions) {
  return new Intl.DateTimeFormat(locale, {
    year: 'numeric',
    month: 'long',
    day: 'numeric',
    ...options,
  }).format(date);
}

const date = new Date();
formatDate(date, 'en-US');
formatDate(date, 'zh-CN');
formatDate(date, 'ja-JP');
```

## 数字格式化

```typescript
function formatNumber(number: number, locale: string, options?: Intl.NumberFormatOptions) {
  return new Intl.NumberFormat(locale, options).format(number);
}

formatNumber(1234567.89, 'en-US');
formatNumber(1234567.89, 'zh-CN');
formatNumber(1234567.89, 'de-DE');
```

## 货币格式化

```typescript
function formatCurrency(amount: number, currency: string, locale: string) {
  return new Intl.NumberFormat(locale, {
    style: 'currency',
    currency,
  }).format(amount);
}

formatCurrency(1234.56, 'USD', 'en-US');
formatCurrency(1234.56, 'CNY', 'zh-CN');
formatCurrency(1234.56, 'EUR', 'de-DE');
```

## 复数处理

```typescript
const messages = {
  en: {
    item_one: '{{count}} item',
    item_other: '{{count}} items',
  },
  zh: {
    item: '{{count}} 个项目',
  },
  ru: {
    item_one: '{{count}} элемент',
    item_few: '{{count}} элемента',
    item_many: '{{count}} элементов',
  },
};
```

## 服务端渲染

```typescript
import i18next from 'i18next';
import Backend from 'i18next-fs-backend';

async function initServerI18n(lng: string) {
  await i18next.use(Backend).init({
    lng,
    fallbackLng: 'en',
    backend: {
      loadPath: './locales/{{lng}}/{{ns}}.json',
    },
  });

  return i18next;
}

app.use(async (req, res, next) => {
  const lng = req.headers['accept-language']?.split(',')[0] || 'en';
  req.i18n = await initServerI18n(lng);
  next();
});
```

## 语言切换

```tsx
import { useTranslation } from 'react-i18next';

function LanguageSwitcher() {
  const { i18n } = useTranslation();

  const languages = [
    { code: 'en', name: 'English' },
    { code: 'zh', name: '中文' },
    { code: 'ja', name: '日本語' },
  ];

  return (
    <select value={i18n.language} onChange={(e) => i18n.changeLanguage(e.target.value)}>
      {languages.map((lang) => (
        <option key={lang.code} value={lang.code}>
          {lang.name}
        </option>
      ))}
    </select>
  );
}
```

## 快速参考

```typescript
// 翻译
t('key', { name: 'value' });

// 复数
t('items', { count: 5 });

// 日期
new Intl.DateTimeFormat(locale).format(date);

// 货币
new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount);

// 切换语言
i18n.changeLanguage('zh');
```

## 参考

- [i18next](https://www.i18next.com/)
- [react-i18next](https://react.i18next.com/)
- [MDN Intl API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl)
- [formatjs](https://formatjs.io/)
