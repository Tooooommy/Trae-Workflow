---
alwaysApply: false
globs:
  - '**/app.py'
  - '**/requirements.txt'
---

# Flask 项目规范与指南

> 基于 Flask 的轻量级 Web 应用开发规范。

## 项目总览

- 技术栈: Flask 3+, Python 3.12+, SQLAlchemy, PostgreSQL
- 架构: 应用工厂模式, 蓝图

## 关键规则

### 项目结构

```
project/
├── app/
│   ├── __init__.py          # 应用工厂
│   ├── config.py            # 配置
│   ├── extensions.py        # 扩展初始化
│   ├── models/
│   │   ├── __init__.py
│   │   └── user.py
│   ├── routes/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   └── api.py
│   ├── services/
│   │   └── user_service.py
│   └── utils/
│       └── helpers.py
├── migrations/
├── tests/
├── requirements.txt
├── config.py
└── run.py
```

### 应用工厂

```python
# app/__init__.py
from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate

db = SQLAlchemy()
migrate = Migrate()

def create_app(config_name='default'):
    app = Flask(__name__)
    app.config.from_object(config[config_name])

    db.init_app(app)
    migrate.init_app(app, db)

    from .routes.auth import auth_bp
    from .routes.api import api_bp

    app.register_blueprint(auth_bp, url_prefix='/auth')
    app.register_blueprint(api_bp, url_prefix='/api')

    return app
```

### Model

```python
# app/models/user.py
from werkzeug.security import generate_password_hash, check_password_hash
from ..extensions import db

class User(db.Model):
    __tablename__ = 'users'

    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password_hash = db.Column(db.String(256), nullable=False)
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    def set_password(self, password):
        self.password_hash = generate_password_hash(password)

    def check_password(self, password):
        return check_password_hash(self.password_hash, password)
```

### Blueprint

```python
# app/routes/api.py
from flask import Blueprint, jsonify, request
from ..services.user_service import UserService

api_bp = Blueprint('api', __name__)
user_service = UserService()

@api_bp.route('/users', methods=['GET'])
def get_users():
    users = user_service.get_all()
    return jsonify([u.to_dict() for u in users])

@api_bp.route('/users', methods=['POST'])
def create_user():
    data = request.get_json()
    user = user_service.create(data)
    return jsonify(user.to_dict()), 201
```

## 环境变量

```bash
# .env
FLASK_APP=run.py
FLASK_ENV=development
SECRET_KEY=your-secret-key
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
```

## 开发命令

```bash
flask run              # 开发服务器
flask db init          # 初始化迁移
flask db migrate       # 创建迁移
flask db upgrade       # 应用迁移
pytest                 # 运行测试
```
