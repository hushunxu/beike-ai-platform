# Beike AI Platform

贝壳 AI 开放平台，为开发者提供房产信息查询、市场分析等 AI 能力。

> ⚡ **新用户？** 5 分钟快速上手 → [快速开始指南](./QUICKSTART.md)

## 🚀 主要功能

选择适合你的方式：

### 1️⃣ 使用 CLI 工具

命令行方式查询房产信息。

👉 [CLI 安装和使用指南](./cli/README.md)

### 2️⃣ 集成 AI Skills

在你的 AI Agent 中使用房产专业知识能力。

👉 [Skills 安装和文档](./skills/README.md)

### 3️⃣ 获取 API Key

所有方式都需要 API Key 进行认证。

👉 [API Key 管理](./docs/authentication.md)

## 📂 项目结构

```
.
├── cli/              # CLI 安装器、文档和二进制发布清单（不含源码）
│   ├── releases/     # 安装脚本和版本清单
│   └── README.md     # CLI 文档
├── skills/           # AI Skills 唯一源码与安装器
│   ├── dist/         # 打包的 Skill 压缩包
│   ├── install.sh    # Skills 安装脚本
│   └── README.md     # Skills 文档
├── scripts/          # Skill 构建、校验和发布脚本
└── docs/             # 平台文档
    └── authentication.md  # API Key 管理
```

CLI 的 Rust 源码在私有 `beike-skill` 仓库维护；这里只发布编译后的二进制。Skill 则直接在本仓库开发和发布，不再跨仓库同步。

## 📝 许可

商业软件，仅限授权用户使用。
