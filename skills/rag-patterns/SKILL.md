---
name: rag-patterns
description: RAG (检索增强生成) 模式、向量数据库、文档处理和检索优化最佳实践。适用于知识库应用开发。
---

# RAG 检索增强生成模式

用于构建高效、准确和可扩展的知识库问答系统的模式与最佳实践。

## 何时激活

- 构建知识库问答系统
- 实现文档检索和问答
- 设计向量数据库架构
- 优化检索质量和性能

## 技术栈版本

| 技术                   | 最低版本    | 推荐版本               |
| ---------------------- | ----------- | ---------------------- |
| OpenAI API             | gpt-4o-mini | gpt-4o                 |
| Pinecone               | 3.0+        | 最新                   |
| LangChain              | 0.1+        | 最新                   |
| text-embedding-3-small | 最新        | text-embedding-3-large |
| TypeScript             | 5.0+        | 最新                   |

## 核心架构

### 基本流程

```
文档 → 分块 → 向量化 → 存储 → 索引
                              ↓
查询 → 向量化 → 检索 → 重排序 → 生成回答
```

### 组件层次

```
┌─────────────────────────────────────────┐
│              应用层                      │
├─────────────────────────────────────────┤
│  查询处理 │ 检索策略 │ 答案生成         │
├─────────────────────────────────────────┤
│  文档处理 │ 向量化   │ 向量存储         │
├─────────────────────────────────────────┤
│              基础设施层                  │
└─────────────────────────────────────────┘
```

## 文档处理

### 文档分块策略

```typescript
interface Chunk {
  id: string;
  content: string;
  metadata: {
    source: string;
    pageNumber?: number;
    position: number;
    embedding?: number[];
  };
}

class TextSplitter {
  private chunkSize: number;
  private overlap: number;

  constructor(chunkSize = 1000, overlap = 200) {
    this.chunkSize = chunkSize;
    this.overlap = overlap;
  }

  split(text: string, metadata: Record<string, unknown> = {}): Chunk[] {
    const chunks: Chunk[] = [];
    let position = 0;

    // 按段落分割
    const paragraphs = text.split(/\n\n+/);
    let currentChunk = '';

    for (const paragraph of paragraphs) {
      if (currentChunk.length + paragraph.length > this.chunkSize) {
        if (currentChunk.length > 0) {
          chunks.push({
            id: `chunk-${position}`,
            content: currentChunk.trim(),
            metadata: { ...metadata, position: position++ },
          });

          // 保留重叠部分
          const overlapText = currentChunk.slice(-this.overlap);
          currentChunk = overlapText + paragraph;
        } else {
          // 段落过长，需要进一步分割
          const sentences = paragraph.match(/[^.!?]+[.!?]+/g) || [paragraph];
          for (const sentence of sentences) {
            if (currentChunk.length + sentence.length > this.chunkSize) {
              chunks.push({
                id: `chunk-${position}`,
                content: currentChunk.trim(),
                metadata: { ...metadata, position: position++ },
              });
              currentChunk = sentence;
            } else {
              currentChunk += sentence;
            }
          }
        }
      } else {
        currentChunk += '\n\n' + paragraph;
      }
    }

    if (currentChunk.trim().length > 0) {
      chunks.push({
        id: `chunk-${position}`,
        content: currentChunk.trim(),
        metadata: { ...metadata, position: position++ },
      });
    }

    return chunks;
  }
}
```

### 语义分块

```typescript
import { OpenAI } from 'openai';

class SemanticChunker {
  private client: OpenAI;
  private similarityThreshold: number;

  constructor(client: OpenAI, similarityThreshold = 0.7) {
    this.client = client;
    this.similarityThreshold = similarityThreshold;
  }

  async chunk(text: string): Promise<Chunk[]> {
    // 按句子分割
    const sentences = text.match(/[^.!?]+[.!?]+/g) || [text];

    // 获取句子嵌入
    const embeddings = await this.getEmbeddings(sentences);

    // 计算相邻句子相似度
    const chunks: Chunk[] = [];
    let currentSentences: string[] = [sentences[0]];

    for (let i = 1; i < sentences.length; i++) {
      const similarity = this.cosineSimilarity(embeddings[i - 1], embeddings[i]);

      if (similarity < this.similarityThreshold) {
        // 语义断点，创建新块
        chunks.push({
          id: `chunk-${chunks.length}`,
          content: currentSentences.join(' '),
          metadata: { position: chunks.length },
        });
        currentSentences = [sentences[i]];
      } else {
        currentSentences.push(sentences[i]);
      }
    }

    // 添加最后一个块
    if (currentSentences.length > 0) {
      chunks.push({
        id: `chunk-${chunks.length}`,
        content: currentSentences.join(' '),
        metadata: { position: chunks.length },
      });
    }

    return chunks;
  }

  private async getEmbeddings(texts: string[]): Promise<number[][]> {
    const response = await this.client.embeddings.create({
      model: 'text-embedding-3-small',
      input: texts,
    });
    return response.data.map((d) => d.embedding);
  }

  private cosineSimilarity(a: number[], b: number[]): number {
    let dotProduct = 0;
    let normA = 0;
    let normB = 0;
    for (let i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }
}
```

## 向量存储

### 接口定义

```typescript
interface VectorStore {
  add(chunks: Chunk[]): Promise<void>;
  search(query: number[], k: number): Promise<Chunk[]>;
  delete(ids: string[]): Promise<void>;
}
```

### Pinecone 实现

```typescript
import { Pinecone } from '@pinecone-database/pinecone';

class PineconeStore implements VectorStore {
  private index: Pinecone.Index;

  constructor(client: Pinecone, indexName: string) {
    this.index = client.index(indexName);
  }

  async add(chunks: Chunk[]): Promise<void> {
    const vectors = chunks.map((chunk) => ({
      id: chunk.id,
      values: chunk.metadata.embedding!,
      metadata: {
        content: chunk.content,
        source: chunk.metadata.source,
      },
    }));

    await this.index.upsert(vectors);
  }

  async search(query: number[], k: number): Promise<Chunk[]> {
    const results = await this.index.query({
      vector: query,
      topK: k,
      includeMetadata: true,
    });

    return results.matches.map((match) => ({
      id: match.id,
      content: match.metadata?.content as string,
      metadata: {
        source: match.metadata?.source as string,
      },
    }));
  }

  async delete(ids: string[]): Promise<void> {
    await this.index.deleteMany(ids);
  }
}
```

### 内存向量存储

```typescript
class MemoryVectorStore implements VectorStore {
  private chunks: Chunk[] = [];

  async add(chunks: Chunk[]): Promise<void> {
    this.chunks.push(...chunks);
  }

  async search(query: number[], k: number): Promise<Chunk[]> {
    const scored = this.chunks.map((chunk) => ({
      chunk,
      score: this.cosineSimilarity(query, chunk.metadata.embedding!),
    }));

    return scored
      .sort((a, b) => b.score - a.score)
      .slice(0, k)
      .map((s) => s.chunk);
  }

  async delete(ids: string[]): Promise<void> {
    this.chunks = this.chunks.filter((c) => !ids.includes(c.id));
  }

  private cosineSimilarity(a: number[], b: number[]): number {
    let dotProduct = 0;
    let normA = 0;
    let normB = 0;
    for (let i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dotProduct / (Math.sqrt(normA) * Math.sqrt(normB));
  }
}
```

## 检索策略

### 混合检索

```typescript
interface Retriever {
  retrieve(query: string, k: number): Promise<Chunk[]>;
}

class HybridRetriever implements Retriever {
  private vectorStore: VectorStore;
  private embeddingClient: OpenAI;
  private bm25Index: Map<string, number[]>;

  constructor(vectorStore: VectorStore, embeddingClient: OpenAI) {
    this.vectorStore = vectorStore;
    this.embeddingClient = embeddingClient;
    this.bm25Index = new Map();
  }

  async retrieve(query: string, k: number): Promise<Chunk[]> {
    // 向量检索
    const queryEmbedding = await this.getEmbedding(query);
    const vectorResults = await this.vectorStore.search(queryEmbedding, k * 2);

    // 关键词检索 (BM25 简化版)
    const keywords = this.tokenize(query);
    const keywordResults = this.bm25Search(keywords, k * 2);

    // 融合结果 (RRF)
    return this.reciprocalRankFusion([vectorResults, keywordResults], k);
  }

  private reciprocalRankFusion(resultSets: Chunk[][], k: number, rrfK = 60): Chunk[] {
    const scores = new Map<string, number>();

    for (const results of resultSets) {
      results.forEach((chunk, rank) => {
        const current = scores.get(chunk.id) || 0;
        scores.set(chunk.id, current + 1 / (rrfK + rank + 1));
      });
    }

    const allChunks = new Map<string, Chunk>();
    for (const results of resultSets) {
      for (const chunk of results) {
        allChunks.set(chunk.id, chunk);
      }
    }

    return Array.from(scores.entries())
      .sort((a, b) => b[1] - a[1])
      .slice(0, k)
      .map(([id]) => allChunks.get(id)!);
  }

  private async getEmbedding(text: string): Promise<number[]> {
    const response = await this.embeddingClient.embeddings.create({
      model: 'text-embedding-3-small',
      input: text,
    });
    return response.data[0].embedding;
  }

  private tokenize(text: string): string[] {
    return text.toLowerCase().split(/\s+/).filter(Boolean);
  }

  private bm25Search(keywords: string[], k: number): Chunk[] {
    // 简化版 BM25 实现
    return [];
  }
}
```

### 重排序

```typescript
class Reranker {
  private client: OpenAI;

  constructor(client: OpenAI) {
    this.client = client;
  }

  async rerank(query: string, chunks: Chunk[], topK: number): Promise<Chunk[]> {
    const scored = await Promise.all(
      chunks.map(async (chunk) => {
        const score = await this.scoreRelevance(query, chunk.content);
        return { chunk, score };
      })
    );

    return scored
      .sort((a, b) => b.score - a.score)
      .slice(0, topK)
      .map((s) => s.chunk);
  }

  private async scoreRelevance(query: string, content: string): Promise<number> {
    const response = await this.client.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content:
            'Score the relevance of the content to the query on a scale of 0-10. Return only the number.',
        },
        {
          role: 'user',
          content: `Query: ${query}\n\nContent: ${content}`,
        },
      ],
      max_tokens: 10,
    });

    return parseFloat(response.choices[0].message.content || '0');
  }
}
```

## 答案生成

### RAG 管道

```typescript
class RAGPipeline {
  private retriever: Retriever;
  private reranker: Reranker;
  private client: OpenAI;

  constructor(retriever: Retriever, reranker: Reranker, client: OpenAI) {
    this.retriever = retriever;
    this.reranker = reranker;
    this.client = client;
  }

  async query(question: string): Promise<{
    answer: string;
    sources: Chunk[];
  }> {
    // 1. 检索相关文档
    const initialResults = await this.retriever.retrieve(question, 10);

    // 2. 重排序
    const reranked = await this.reranker.rerank(question, initialResults, 5);

    // 3. 构建上下文
    const context = reranked.map((c, i) => `[${i + 1}] ${c.content}`).join('\n\n');

    // 4. 生成答案
    const response = await this.client.chat.completions.create({
      model: 'gpt-4o-mini',
      messages: [
        {
          role: 'system',
          content: `You are a helpful assistant. Answer the question based on the provided context.
If the context doesn't contain enough information, say so.
Always cite your sources using [1], [2], etc.`,
        },
        {
          role: 'user',
          content: `Context:\n${context}\n\nQuestion: ${question}`,
        },
      ],
    });

    return {
      answer: response.choices[0].message.content || '',
      sources: reranked,
    };
  }
}
```

### 带引用的答案

```typescript
interface AnswerWithCitations {
  answer: string;
  citations: Array<{
    id: string;
    content: string;
    source: string;
  }>;
}

async function generateAnswerWithCitations(
  question: string,
  chunks: Chunk[]
): Promise<AnswerWithCitations> {
  const context = chunks
    .map((c, i) => `[${i + 1}] Source: ${c.metadata.source}\n${c.content}`)
    .join('\n\n');

  const response = await client.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      {
        role: 'system',
        content: `Answer based on the context. Use citations like [1], [2] to reference sources.
Format your response as JSON:
{
  "answer": "your answer with [citations]",
  "citations": [1, 2, 3]
}`,
      },
      {
        role: 'user',
        content: `Context:\n${context}\n\nQuestion: ${question}`,
      },
    ],
    response_format: { type: 'json_object' },
  });

  const parsed = JSON.parse(response.choices[0].message.content || '{}');

  return {
    answer: parsed.answer,
    citations: parsed.citations.map((i: number) => ({
      id: chunks[i - 1].id,
      content: chunks[i - 1].content,
      source: chunks[i - 1].metadata.source,
    })),
  };
}
```

## 评估指标

### 检索质量

```typescript
interface RetrievalMetrics {
  precision: number;
  recall: number;
  mrr: number;
}

function evaluateRetrieval(retrieved: string[], relevant: string[]): RetrievalMetrics {
  const retrievedSet = new Set(retrieved);
  const relevantSet = new Set(relevant);

  const truePositives = retrieved.filter((id) => relevantSet.has(id)).length;

  const precision = truePositives / retrieved.length;
  const recall = truePositives / relevant.length;

  // Mean Reciprocal Rank
  let mrr = 0;
  for (let i = 0; i < retrieved.length; i++) {
    if (relevantSet.has(retrieved[i])) {
      mrr = 1 / (i + 1);
      break;
    }
  }

  return { precision, recall, mrr };
}
```

### 答案质量

```typescript
async function evaluateAnswer(
  question: string,
  answer: string,
  groundTruth: string
): Promise<{ relevance: number; faithfulness: number }> {
  const response = await client.chat.completions.create({
    model: 'gpt-4o-mini',
    messages: [
      {
        role: 'system',
        content: `Evaluate the answer on two dimensions:
1. Relevance (0-1): How well does it address the question?
2. Faithfulness (0-1): How consistent is it with the ground truth?

Return JSON: {"relevance": number, "faithfulness": number}`,
      },
      {
        role: 'user',
        content: `Question: ${question}
Answer: ${answer}
Ground Truth: ${groundTruth}`,
      },
    ],
    response_format: { type: 'json_object' },
  });

  return JSON.parse(response.choices[0].message.content || '{}');
}
```

## 快速参考

| 组件     | 用途         | 工具选择                   |
| -------- | ------------ | -------------------------- |
| 文档分块 | 切分长文档   | 语义分块、固定大小         |
| 向量化   | 文本转向量   | OpenAI、Cohere             |
| 向量存储 | 存储和检索   | Pinecone、Weaviate、Milvus |
| 检索策略 | 提高召回率   | 混合检索、重排序           |
| 答案生成 | 生成最终答案 | GPT-4、Claude              |

**记住**：RAG 的质量取决于检索准确性和上下文相关性。持续评估和优化检索策略是关键。
