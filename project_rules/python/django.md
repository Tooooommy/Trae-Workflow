---
alwaysApply: false
globs:
  - "**/settings.py"
  - "**/models.py"
  - "**/views.py"
---

# Django 项目规范与指南

> 基于 Django 5+ 的全栈 Web 应用开发规范。

## 项目总览

* 技术栈: Django 5+, Python 3.12+, PostgreSQL, Redis
* 架构: MTV (Model-Template-View), Django REST Framework

## 关键规则

### 项目结构

```
project/
├── config/
│   ├── settings/
│   │   ├── base.py
│   │   ├── development.py
│   │   └── production.py
│   ├── urls.py
│   ├── wsgi.py
│   └── asgi.py
├── apps/
│   ├── users/
│   │   ├── models.py
│   │   ├── views.py
│   │   ├── serializers.py
│   │   ├── urls.py
│   │   └── admin.py
│   └── products/
├── static/
├── media/
├── templates/
├── requirements/
│   ├── base.txt
│   ├── dev.txt
│   └── prod.txt
└── manage.py
```

### Model 定义

```python
from django.db import models
from django.contrib.auth.models import AbstractUser

class User(AbstractUser):
    phone = models.CharField(max_length=20, blank=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'users'

class Product(models.Model):
    name = models.CharField(max_length=200)
    price = models.DecimalField(max_digits=10, decimal_places=2)
    description = models.TextField(blank=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'products'
        ordering = ['-created_at']
```

### ViewSet (DRF)

```python
from rest_framework import viewsets, permissions
from rest_framework.decorators import action
from .models import Product
from .serializers import ProductSerializer

class ProductViewSet(viewsets.ModelViewSet):
    queryset = Product.objects.all()
    serializer_class = ProductSerializer
    permission_classes = [permissions.IsAuthenticatedOrReadOnly]

    @action(detail=False, methods=['get'])
    def featured(self, request):
        products = Product.objects.filter(featured=True)
        serializer = self.get_serializer(products, many=True)
        return Response(serializer.data)
```

### Serializer

```python
from rest_framework import serializers
from .models import Product

class ProductSerializer(serializers.ModelSerializer):
    class Meta:
        model = Product
        fields = ['id', 'name', 'price', 'description', 'created_at']
        read_only_fields = ['id', 'created_at']
```

## 环境变量

```bash
# .env
DJANGO_SETTINGS_MODULE=config.settings.development
DATABASE_URL=postgresql://user:password@localhost:5432/mydb
SECRET_KEY=your-secret-key
DEBUG=True
ALLOWED_HOSTS=localhost,127.0.0.1
```

## 开发命令

```bash
python manage.py runserver      # 开发服务器
python manage.py migrate        # 数据库迁移
python manage.py makemigrations # 创建迁移
python manage.py test           # 运行测试
python manage.py collectstatic  # 收集静态文件
```
