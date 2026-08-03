# 贝壳 CLI Skills

贝壳地产 CLI 工具的 Skill 定义集合，为用户提供买房、租房、市场行情、政策咨询、学区查询等专业顾问服务。

## 包含的 Skills

| Skill | 功能描述 |
|-------|--------|
| **beike-buy** | 二手房和新房购买助手，支持房源搜索、小区详情、价格行情、经纪人咨询 |
| **beike-rent** | 租房助手，支持租房搜索、租金走势、看房预约、经纪人联系 |
| **beike-market** | 市场行情和成交数据查询，支持买卖行情、历史成交、租赁行情分析 |
| **beike-policy** | 购房政策顾问，支持购房资格、首付贷款、税费、交易流程咨询 |
| **beike-school** | 学区和学校查询，支持学校信息、学区划片、学区房选择建议 |

## 快速开始

### 安装 beike CLI

```bash
npm install -g @ke/beike-skill
```

### 保存 API Key

首次使用前需要保存 API Key：

```bash
beike auth <YOUR_API_KEY> --save
```

API Key 将保存到 `~/.beike/BEIKE_MCP_API_KEY`，后续自动使用。

### 使用示例

**查询二手房**
```bash
beike buy search -c 北京 -q "朝阳区 1000万以内 2居"
```

**查询租房**
```bash
beike rent search -c 北京 -q "望京 2000元以内 1居"
```

**查询学区**
```bash
beike buy school -c 北京 -q "西城区重点小学"
```

**查询购房政策**
```bash
beike policy search -c 北京 -q "非本地户籍购房资格"
```

## 文档

详细使用指南请查看各 Skill 的文档：

- [beike-buy - 二手房购买助手](./beike-buy/SKILL.md)
- [beike-rent - 租房助手](./beike-rent/SKILL.md)
- [beike-market - 市场行情查询](./beike-market/SKILL.md)
- [beike-policy - 购房政策顾问](./beike-policy/SKILL.md)
- [beike-school - 学区查询](./beike-school/SKILL.md)

## 命令结构

每个 Skill 对应一组 CLI 子命令：

```
beike <skill>
  buy       - 二手房和新房购买
  rent      - 租房
  market    - 市场行情
  policy    - 购房政策
  school    - 学区查询
```

## 常见问题

**Q: API Key 在哪里获取？**
A: 联系贝壳销售或技术支持获取 API Key。

**Q: 支持哪些城市？**
A: 支持全国主要城市，具体可通过 `beike buy search -c <城市>` 验证。

**Q: 如何重置 API Key？**
A: 运行 `beike auth <NEW_KEY> --save` 覆盖已保存的 Key。

## 许可

贝壳内部使用。
