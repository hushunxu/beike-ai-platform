# Beike AI Platform

贝壳 AI 开放平台发布仓库，包含 CLI 工具、Skills 定义、API 文档和使用示例。

## 📦 内容

- **dist/** - CLI 工具的编译产物和 NPM 包
- **skills/** - Skill 定义（从 beike-skill 项目同步）
  - beike-buy - 二手房购买助手
  - beike-rent - 租房助手
  - beike-market - 市场行情查询
  - beike-policy - 购房政策顾问
  - beike-school - 学区查询

## 🚀 快速开始

### 安装 CLI

```bash
npm install -g @ke/beike-skill
```

### 保存 API Key

```bash
beike auth <YOUR_API_KEY> --save
```

### 使用示例

```bash
# 查询二手房
beike buy search -c 北京 -q "朝阳区 1000万以内"

# 查询租房
beike rent search -c 北京 -q "望京 2000元以内"

# 查询学区
beike buy school -c 北京 -q "西城区重点小学"
```

## 📖 文档

详细文档请查看 [skills/README.md](./skills/README.md)

## 📝 许可

商业软件，仅限授权用户使用。
