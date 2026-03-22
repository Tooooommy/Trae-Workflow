---
alwaysApply: false
globs:
  - '**/nest-cli.json'
  - '**/*.controller.ts'
  - '**/*.service.ts'
  - '**/*.module.ts'
---

# NestJS 项目规范与指南

> 基于 NestJS 的企业级 Node.js 后端应用开发规范。

## 项目总览

- 技术栈: NestJS 10+, TypeScript, TypeORM/Prisma, PostgreSQL
- 架构: 模块化、依赖注入、装饰器模式

## 关键规则

### 模块结构

```
src/
├── modules/
│   ├── users/
│   │   ├── users.module.ts
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   ├── users.repository.ts
│   │   ├── entities/
│   │   │   └── user.entity.ts
│   │   ├── dto/
│   │   │   ├── create-user.dto.ts
│   │   │   └── update-user.dto.ts
│   │   └── interfaces/
│   │       └── user.interface.ts
│   └── auth/
├── common/
│   ├── guards/
│   ├── interceptors/
│   ├── filters/
│   ├── decorators/
│   └── pipes/
├── config/
│   └── configuration.ts
└── main.ts
```

### Controller

```typescript
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  @UseGuards(JwtAuthGuard)
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.usersService.findOne(+id);
  }
}
```

### Service

```typescript
@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>
  ) {}

  async create(createUserDto: CreateUserDto): Promise<User> {
    const user = this.usersRepository.create(createUserDto);
    return this.usersRepository.save(user);
  }

  async findOne(id: number): Promise<User> {
    const user = await this.usersRepository.findOne({ where: { id } });
    if (!user) {
      throw new NotFoundException(`User #${id} not found`);
    }
    return user;
  }
}
```

### DTO 验证

```typescript
import { IsEmail, IsString, MinLength } from 'class-validator';

export class CreateUserDto {
  @IsString()
  @MinLength(2)
  name: string;

  @IsEmail()
  email: string;

  @IsString()
  @MinLength(8)
  password: string;
}
```

## 环境变量

```bash
# .env
DATABASE_URL="postgresql://user:password@localhost:5432/mydb"
JWT_SECRET="your-jwt-secret"
PORT=3000
```

## 开发命令

```bash
npm run start:dev    # 开发模式
npm run build        # 构建
npm run start:prod   # 生产模式
npm run test         # 测试
npm run lint         # 代码检查
```
