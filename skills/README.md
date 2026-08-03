# 贝壳 AI Skill 定义

贝壳 AI 开放平台的 Skill（能力模块）定义集合，为 AI Agent 提供买房、租房、市场行情、政策咨询、学区查询等专业顾问服务。

## 包含的 Skills

| Skill | 功能描述 |
|-------|--------|
| **beike-buy** | 二手房和新房购买助手，支持房源搜索、小区详情、价格行情、经纪人咨询 |
| **beike-rent** | 租房助手，支持租房搜索、租金走势、看房预约、经纪人联系 |
| **beike-market** | 市场行情和成交数据查询，支持买卖行情、历史成交、租赁行情分析 |
| **beike-policy** | 购房政策顾问，支持购房资格、首付贷款、税费、交易流程咨询 |
| **beike-school** | 学区和学校查询，支持学校信息、学区划片、学区房选择建议 |

## 快速开始

### 安装全部 Skills

```bash
curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/install.sh | bash
```

### 安装指定 Skills

```bash
# 安装单个或多个 skill
curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/install.sh | bash -s -- beike-buy beike-rent

# 安装列表
curl -fsSL https://raw.githubusercontent.com/hushunxu/beike-ai-platform/main/skills/install.sh | bash -s -- beike-buy beike-market beike-policy
```

Skills 默认安装到 `~/.claude/skills/<skill-name>/`。

## 详细文档

详细使用指南请查看各 Skill 的文档：

- [beike-buy - 二手房购买助手](./beike-buy/SKILL.md)
- [beike-rent - 租房助手](./beike-rent/SKILL.md)
- [beike-market - 市场行情查询](./beike-market/SKILL.md)
- [beike-policy - 购房政策顾问](./beike-policy/SKILL.md)
- [beike-school - 学区查询](./beike-school/SKILL.md)

## 许可

贝壳内部使用。
