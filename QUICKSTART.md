# 快速开始

欢迎使用贝壳 AI 开放平台！本指南帮你 5 分钟内快速上手。

## 第 1 步：获取 API Key

所有功能都需要 API Key 认证。

👉 [如何获取 API Key](./docs/authentication.md)

## 第 2 步：选择使用方式

### 💻 方式 A：命令行查询（CLI）

适合快速查询房产信息、市场数据。

**安装：**
```bash
curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/cli/releases/install.sh | bash
```

**保存 API Key：**
```bash
beike auth <YOUR_API_KEY> --save
```

**快速示例：**
```bash
# 搜索北京的房源
beike buy search -c 北京 -q "朝阳区"

# 查看租赁行情
beike rent trend -c 北京

# 获取学区信息
beike school query -c 北京 -q "海淀区"
```

👉 [完整 CLI 文档](./cli/README.md)

---

### 🤖 方式 B：集成到 AI Agent（Skills）

适合在 Claude、ChatGPT 等 AI 工具中使用房产专业能力。

**安装全部 Skills：**
```bash
curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/install.sh | bash
```

**只安装特定 Skills：**
```bash
curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/install.sh | bash -s -- beike-buy beike-rent
```

**配置环境变量：**
```bash
export BEIKE_MCP_API_KEY=<YOUR_API_KEY>
```

**使用：** 在 Claude 等 AI 工具中提问：
- "帮我找一套北京朝阳区的学区房"
- "最近北京房租行情怎样"
- "周边有哪些学校"

👉 [完整 Skills 文档](./skills/README.md)

---

## 第 3 步：验证安装

### 验证 CLI
```bash
beike --version
# 输出: beike CLI v0.2.2
```

### 验证 Skills
```bash
ls ~/.claude/skills/
# 输出: beike-buy beike-rent beike-market beike-policy beike-school
```

## 常见问题

**Q: 我没有 API Key 怎么办？**  
A: 联系贝壳销售或技术支持获取。详见 [API Key 管理](./docs/authentication.md)

**Q: CLI 和 Skills 有什么区别？**  
A: 
- **CLI** — 命令行工具，适合直接查询、脚本自动化
- **Skills** — AI 能力集，适合集成到 AI 工具中，支持自然语言对话

**Q: 可以只装部分 Skills 吗？**  
A: 可以，用参数指定：`bash -s -- beike-buy beike-rent`

**Q: API Key 放在哪里最安全？**  
A: 
- **CLI 用户** — 自动保存到 `~/.beike/BEIKE_MCP_API_KEY`
- **Skills 用户** — 通过环境变量 `BEIKE_MCP_API_KEY`
- ⚠️ 不要提交到 Git 或分享给他人

## 后续资源

- [CLI 详细使用文档](./cli/README.md)
- [Skills 文档和示例](./skills/README.md)
- [API Key 管理指南](./docs/authentication.md)
- [GitHub 仓库](https://github.com/hushunxu/beike-ai-platform)

## 需要帮助？

- 📧 技术支持：联系贝壳技术团队
- 🐛 报告问题：[GitHub Issues](https://github.com/hushunxu/beike-ai-platform/issues)
- 💬 讨论建议：[GitHub Discussions](https://github.com/hushunxu/beike-ai-platform/discussions)

---

**祝你使用愉快！** 🎉
