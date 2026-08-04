# 快速开始

3 步开始使用贝壳 AI 开放平台：

## 1️⃣ 获取 API Key

所有功能都需要 API Key。

**打开浏览器获取：** https://preview-skill.ke.com/?action=get-key

👉 [详细说明](./docs/authentication.md)

---

## 2️⃣ 选择使用方式

### 💻 CLI（命令行查询）

```bash
# 安装
curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/cli/releases/install.sh | bash

# 保存 API Key
beike auth <YOUR_API_KEY> --save

# 快速示例
beike buy search -c 北京 -q "朝阳区"
```

**场景：** 快速查询房产、行情、学区  
👉 [完整文档](./cli/README.md)

---

### 🤖 Skills（AI Agent）

```bash
# 安装全部
curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/install.sh | bash

# 或只装特定 Skill
bash -s -- beike-buy beike-rent

# 配置环境变量
export BEIKE_MCP_API_KEY=<YOUR_API_KEY>
```

**场景：** 在 Claude/Cursor 中用自然语言提问  
👉 [完整文档](./skills/README.md)

---

## 3️⃣ 验证成功

```bash
# CLI
beike --version

# Skills
ls ~/.claude/skills/
```

---

## 更多帮助

| 问题 | 答案 |
|------|------|
| **没有 API Key？** | [获取凭证](./docs/authentication.md) |
| **CLI vs Skills？** | [对比说明](./cli/README.md) |
| **问题或建议？** | [GitHub Issues](https://github.com/hushunxu/beike-ai-platform/issues) |
