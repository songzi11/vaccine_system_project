# 疫苗预约与接种管理系统

一个功能完善的疫苗预约与接种管理系统，包含用户端、医生端和管理端三个角色，支持疫苗库存管理、预约管理、接种记录、数据统计等功能。

## 项目简介

本系统是基于 Spring Boot 后端和 UniApp 前端的全栈疫苗管理系统，为疫苗接种机构提供信息化管理解决方案。

## 功能特性

### 用户端功能
- 用户注册与登录
- 儿童信息管理
- 疫苗预约
- 接种记录查询
- 接种提醒通知
- 接种点查询

### 医生端功能
- 医生信息管理
- 预约审核
- 疫苗接种
- 接种记录录入
- 不良反应记录
- 消息通知

### 管理端功能
- 用户管理
- 医生管理
- 接种点管理
- 疫苗信息管理
- 疫苗批次管理
- 库存管理
- 预约调度生成
- 数据统计分析
- 系统公告

## 技术栈

### 后端技术
- **框架**: Spring Boot 3.2.8
- **ORM**: MyBatis Plus 3.5.5
- **数据库**: MySQL 8.0
- **JDK**: Java 17
- **构建工具**: Maven
- **其他**: Lombok, Swagger/OpenAPI, Spring Security

### 前端技术
- **框架**: UniApp (Vue 3)
- **UI组件**: uni-ui
- **多端支持**: H5, 微信小程序, Android App, iOS App

### 开发工具
- **IDE**: IntelliJ IDEA / HBuilderX
- **版本控制**: Git

## 项目结构

```
vaccine_system_project/
├── vaccine_system/          # 后端项目
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/       # Java 源码
│   │   │   └── resources/  # 配置文件和SQL脚本
│   │   └── test/           # 测试代码
│   ├── pom.xml              # Maven 依赖配置
│   └── mvnw                # Maven Wrapper
├── vaccine_system_app/      # 前端项目
│   ├── pages/              # 页面文件
│   ├── components/          # 组件文件
│   ├── static/             # 静态资源
│   ├── uni_modules/        # uni-app 插件
│   └── manifest.json       # 应用配置
├── thesis/                 # 毕业论文文档
└── docs/                   # 项目文档
```

## 快速开始

### 环境要求

- **Java**: JDK 17 或更高版本
- **MySQL**: MySQL 8.0 或更高版本
- **Node.js**: Node.js 16 或更高版本
- **Maven**: 3.6+ (或使用项目自带的 mvnw)

### 安装步骤

的后端默认数据库配置：
- 数据库名: `vaccine_system`
- 用户名: `root`
- 密码: `123456`
- 端口: `3306`

如需修改，请编辑 `vaccine_system/src/main/resources/application.properties`

#### 1. 克隆项目

```bash
git clone https://github.com/songzi11/vaccine_system_project.git
cd vaccine_system_project
```

#### 2. 初始化数据库

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库
CREATE DATABASE vaccine_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

# 导入数据
USE vaccine_system;
SOURCE vaccine_system/src/main/resources/sql/vaccine_system.sql;

# 退出
EXIT;
```

#### 3. 启动后端服务

```bash
cd vaccine_system

# Windows 使用 mvnw.cmd
mvnw.cmd spring-boot:run

# Linux/Mac 使用 mvnw
./mvnw spring-boot:run

# 或使用全局 Maven
mvn spring-boot:run
```

后端服务将运行在: http://localhost:8080

API 文档访问: http://localhost:8080/swagger-ui.html

#### 4. 启动前端服务

```bash
cd vaccine_system_app

# 安装依赖（首次运行）
npm install

# 启动 H5 开发版本
npm run dev:h5

# 或启动微信小程序开发版本
npm run dev:mp-weixin
```

前端 H5 版本将运行在: http://localhost:5173

## 使用说明

### 默认账号

系统初始化后会创建以下默认账号：

| 角色 | 用户名 | 密码 | 说明 |
|------|--------|------|------|
| 管理员 | admin | admin123 | 系统管理员账号 |
| 医生 | doctor001 | doctor123 | 示例医生账号 |

用户可以通过注册功能创建自己的账号。

### 功能访问路径

#### H5 版本
- 管理端: http://localhost:5173/pages/admin/index
- 医生端: http://localhost:5173/pages/doctor/index
- 用户端: http://localhost:5173/pages/user/index

#### 微信小程序
使用微信开发者工具导入 `vaccine_system_app` 目录，使用微信小程序账号登录开发。

## 开发指南

### 后端开发

```bash
# 进入后端目录
cd vaccine_system

# 编译项目
mvnw.cmd clean compile

# 运行测试
mvnw.cmd test

# 打包项目
mvnw.cmd clean package
```

### 前端开发

```bash
# 进入前端目录
cd vaccine_system_app

# 代码开发
# 使用 HBuilderX 或 VS Code 编辑器

# 启动开发服务器
npm run dev:h5
```

## 部署说明

### 后端部署

```bash
# 打包项目
cd vaccine_system
mvnw.cmd clean package -DskipTests

# 生成的 JAR 文件位于 target 目录
# 运行: java -jar target/vaccine_system-1.0.0-SNAPSHOT.jar
```

### 前端部署

#### H5 部署

```bash
cd vaccine_system_app
npm run build:h5

# 生成文件位于 unpackage/dist/build/h5 目录
# 部署到 Nginx 或其他 Web 服务器
```

#### 微信小程序部署

使用微信开发者工具打开项目，点击"上传"按钮提交审核。

## 常见问题

### 数据库连接失败

1. 检查 MySQL 服务是否启动
2. 检查数据库用户名密码是否正确
3. 检查数据库 `vaccine_system` 是否已创建
4. 修改 `application.properties` 中的数据库配置

### 后端端口被占用

修改 `vaccine_system/src/main/resources/application.properties`:
```properties
server.port=8081  # 改为其他端口
```

### 前端无法连接后端

1. 检查后端服务是否正常运行
2. 检查 `manifest.json` 中的代理配置
3. 确保 CORS 配置正确

## 贡献指南

欢迎提交 Issue 和 Pull Request 来帮助改进本项目。

## 许可证

本项目仅供学习和研究使用。

## 联系方式

如有问题，请提交 Issue 或通过以下方式联系：

- GitHub: https://github.com/songzi11/vaccine_system_project

## 更新日志

### v1.0.0 (2024-03)
- 初始版本发布
- 实现基础的用户、医生、管理三大端功能
- 完成疫苗预约、接种、库存管理核心功能
