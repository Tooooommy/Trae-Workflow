---
name: llm-integration-patterns
description: LLM 集成模式、Prompt 工程、Token 优化和错误处理最佳实践。适用于 AI 应用开发。
---

# LLM 集成模式

用于构建可靠、高效和可维护的 LLM 应用的模式与最佳实践。

## 何时激活

- 集成 OpenAI、Anthropic 等 LLM API
- 设计 AI 应用架构
- 优化 Token 使用和成本
- 处理 LLM 响应和错误

## 技术栈版本

| 技术 | 最低版本 | 推荐版本 |
|------|---------|---------|
| OpenAI SDK | 4.0+ | 最新 |
| Anthropic SDK | 0.20+ | 最新 |
| TypeScript | 5.0+ | 最新 |
| LangChain | 0.1+ | 最新 |
| tiktoken | 0.5+ | 最新 |

## 核心原则

### 1. 设计原则

- **确定性**：相同输入应产生可预测的输出
- **可观测性**：记录请求、响应和中间状态
- **容错性**：处理 API 限制、超时和错误响应
- **成本控制**：优化 Token 使用，监控费用

### 2. 架构层次

```
用户请求 → 应用层 → Prompt 构建 → LLM 调用 → 响应处理 → 返回结果
              ↓           ↓            ↓            ↓
           上下文管理   模板引擎    重试/缓存    解析/验证
```

## API 集成模式

### 基础客户端

```typescript
import OpenAI from 'openai';

const client = new OpenAI({
  apiKey: process.env.OPENAI_API_KEY,
});

interface LLMResponse {
  content: string;
  usage: {
    promptTokens: number;
    completionTokens: number;
    totalTokens: number;
  };
}

async function generateCompletion(
  messages: Array<{ role: string; content: string }>,
  options: {
    model?: string;
    temperature?: number;
    maxTokens?: number;
  } = {}
): Promise<LLMResponse> {
  const response = await client.chat.completions.create({
    model: options.model || 'gpt-4o-mini',
    messages,
    temperature: options.temperature ?? 0.7,
    max_tokens: options.maxTokens ?? 1000,
  });

  return {
    content: response.choices[0].message.content || '',
    usage: {
      promptTokens: response.usage?.prompt_tokens || 0,
      completionTokens: response.usage?.completion_tokens || 0,
      totalTokens: response.usage?.total_tokens || 0,
    },
  };
}
```

### 重试和错误处理

```typescript
import { retry } from 'ts-retry';

async function generateWithRetry(
  messages: Array<{ role: string; content: string }>,
  maxRetries = 3
): Promise<LLMResponse> {
  return retry(
    async () => {
      try {
        return await generateCompletion(messages);
      } catch (error) {
        if (error instanceof OpenAI.APIError) {
          if (error.status === 429) {
            throw new Error('Rate limited');
          }
          if (error.status && error.status >= 500) {
            throw new Error('Server error');
          }
        }
        throw error;
      }
    },
    {
      maxTry: maxRetries,
      delay: 1000,
      backoff: 'exponential',
      onError: (err, tryNum) => {
        console.warn(`Attempt ${tryNum} failed: ${err.message}`);
      },
    }
  );
}
```

### 流式响应

```typescript
async function* streamCompletion(
  messages: Array<{ role: string; content: string }>
): AsyncGenerator<string> {
  const stream = await client.chat.completions.create({
    model: 'gpt-4o-mini',
    messages,
    stream: true,
  });

  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content;
    if (content) {
      yield content;
    }
  }
}

// 使用
for await (const chunk of streamCompletion(messages)) {
  process.stdout.write(chunk);
}
```

## Prompt 工程模式

### 系统提示模板

```typescript
const SYSTEM_PROMPTS = {
  codeReview: `You are an expert code reviewer. Analyze the code for:
1. Bugs and potential errors
2. Security vulnerabilities
3. Performance issues
4. Code style and best practices

Provide specific, actionable feedback with code examples.`,

  summarizer: `You are a concise summarizer. Create a brief summary that:
- Captures key points
- Uses bullet points for clarity
- Maintains original meaning
- Is no longer than 3 sentences`,

  translator: `You are a professional translator. Translate the text while:
- Preserving tone and style
- Using natural, idiomatic expressions
- Maintaining formatting
- Not adding or removing content`,
};
```

### 结构化输出

```typescript
interface CodeReviewResult {
  issues: Array<{
    type: 'bug' | 'security' | 'performance' | 'style';
    line: number;
    description: string;
    suggestion: string;
  }>;
  overallScore: number;
  summary: string;
}

async function reviewCode(code: string): Promise<CodeReviewResult> {
  const response = await generateCompletion([
    { role: 'system', content: SYSTEM_PROMPTS.codeReview },
    {
      role: 'user',
      content: `Review this code and respond in JSON format:
\`\`\`
${code}
\`\`\`

Respond with JSON matching this schema:
{
  "issues": [{ "type": "bug|security|performance|style", "line": number, "description": "string", "suggestion": "string" }],
  "overallScore": number (1-10),
  "summary": "string"
}`,
    },
  ]);

  return JSON.parse(response.content);
}
```

### Few-Shot 学习

```typescript
function buildFewShotPrompt<T>(
  examples: Array<{ input: string; output: T }>,
  newInput: string
): string {
  const exampleText = examples
    .map(
      (ex) => `Input: ${ex.input}
Output: ${JSON.stringify(ex.output)}`
    )
    .join('\n\n');

  return `${exampleText}

Input: ${newInput}
Output:`;
}
```

## Token 优化

### Token 估算

```typescript
function estimateTokens(text: string): number {
  return Math.ceil(text.length / 4);
}

function truncateToTokenLimit(text: string, maxTokens: number): string {
  const maxChars = maxTokens * 4;
  if (text.length <= maxChars) return text;
  return text.slice(0, maxChars - 3) + '...';
}
```

### 上下文窗口管理

```typescript
class ContextManager {
  private maxTokens: number;
  private reservedTokens: number;

  constructor(maxTokens = 4096, reservedTokens = 500) {
    this.maxTokens = maxTokens;
    this.reservedTokens = reservedTokens;
  }

  buildContext(
    systemPrompt: string,
    conversationHistory: Array<{ role: string; content: string }>,
    newMessage: string
  ): Array<{ role: string; content: string }> {
    const availableTokens = this.maxTokens - this.reservedTokens;
    let usedTokens = estimateTokens(systemPrompt) + estimateTokens(newMessage);

    const truncatedHistory: typeof conversationHistory = [];

    for (const msg of [...conversationHistory].reverse()) {
      const msgTokens = estimateTokens(msg.content);
      if (usedTokens + msgTokens <= availableTokens) {
        truncatedHistory.unshift(msg);
        usedTokens += msgTokens;
      } else {
        break;
      }
    }

    return [
      { role: 'system', content: systemPrompt },
      ...truncatedHistory,
      { role: 'user', content: newMessage },
    ];
  }
}
```

## 缓存策略

### 响应缓存

```typescript
import { createHash } from 'crypto';

interface CacheEntry {
  response: LLMResponse;
  timestamp: number;
}

class LLMCache {
  private cache = new Map<string, CacheEntry>();
  private ttl: number;

  constructor(ttlMs = 3600000) {
    this.ttl = ttlMs;
  }

  private hashKey(messages: Array<{ role: string; content: string }>): string {
    return createHash('sha256')
      .update(JSON.stringify(messages))
      .digest('hex');
  }

  async getOrGenerate(
    messages: Array<{ role: string; content: string }>,
    generator: () => Promise<LLMResponse>
  ): Promise<LLMResponse> {
    const key = this.hashKey(messages);
    const cached = this.cache.get(key);

    if (cached && Date.now() - cached.timestamp < this.ttl) {
      return cached.response;
    }

    const response = await generator();
    this.cache.set(key, { response, timestamp: Date.now() });
    return response;
  }
}
```

## 函数调用

### 工具定义

```typescript
const tools: OpenAI.Chat.Completions.ChatCompletionTool[] = [
  {
    type: 'function',
    function: {
      name: 'get_weather',
      description: 'Get current weather for a location',
      parameters: {
        type: 'object',
        properties: {
          location: {
            type: 'string',
            description: 'City and country, e.g., "Tokyo, Japan"',
          },
          unit: {
            type: 'string',
            enum: ['celsius', 'fahrenheit'],
            description: 'Temperature unit',
          },
        },
        required: ['location'],
      },
    },
  },
];

async function runWithTools(
  messages: Array<{ role: string; content: string }>
): Promise<string> {
  const response = await client.chat.completions.create({
    model: 'gpt-4o-mini',
    messages,
    tools,
    tool_choice: 'auto',
  });

  const message = response.choices[0].message;

  if (message.tool_calls) {
    for (const toolCall of message.tool_calls) {
      if (toolCall.function.name === 'get_weather') {
        const args = JSON.parse(toolCall.function.arguments);
        const result = await getWeather(args.location, args.unit);

        messages.push(message);
        messages.push({
          role: 'tool',
          content: JSON.stringify(result),
          tool_call_id: toolCall.id,
        });
      }
    }

    const finalResponse = await client.chat.completions.create({
      model: 'gpt-4o-mini',
      messages,
    });

    return finalResponse.choices[0].message.content || '';
  }

  return message.content || '';
}
```

## 成本监控

### Token 计费

```typescript
const PRICING = {
  'gpt-4o': { input: 0.005, output: 0.015 },
  'gpt-4o-mini': { input: 0.00015, output: 0.0006 },
  'claude-3-opus': { input: 0.015, output: 0.075 },
  'claude-3-sonnet': { input: 0.003, output: 0.015 },
};

function calculateCost(
  model: string,
  inputTokens: number,
  outputTokens: number
): number {
  const pricing = PRICING[model as keyof typeof PRICING];
  if (!pricing) return 0;

  return (
    (inputTokens / 1000) * pricing.input +
    (outputTokens / 1000) * pricing.output
  );
}
```

### 使用量追踪

```typescript
class UsageTracker {
  private usage: Array<{
    timestamp: Date;
    model: string;
    inputTokens: number;
    outputTokens: number;
    cost: number;
  }> = [];

  track(
    model: string,
    inputTokens: number,
    outputTokens: number
  ): void {
    const cost = calculateCost(model, inputTokens, outputTokens);
    this.usage.push({
      timestamp: new Date(),
      model,
      inputTokens,
      outputTokens,
      cost,
    });
  }

  getDailyCost(date: Date = new Date()): number {
    return this.usage
      .filter(
        (u) =>
          u.timestamp.toDateString() === date.toDateString()
      )
      .reduce((sum, u) => sum + u.cost, 0);
  }
}
```

## 快速参考

| 模式 | 用途 |
|------|------|
| 系统提示 | 定义 AI 角色和行为 |
| Few-Shot | 提供示例引导输出 |
| 结构化输出 | 获取 JSON 格式响应 |
| 流式响应 | 实时显示生成内容 |
| 函数调用 | 扩展 AI 能力 |
| 缓存 | 减少重复调用成本 |
| 重试 | 处理临时错误 |

**记住**：LLM 是非确定性的，需要通过温度设置、结构化输出和验证来提高可靠性。始终监控 Token 使用和成本。
