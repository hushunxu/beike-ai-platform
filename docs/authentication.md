# API Key 管理

## 获取 API Key

联系贝壳销售或技术支持获取 API Key。

## 保存 API Key

### CLI 用户

```bash
beike auth <YOUR_API_KEY> --save
```

API Key 将保存到 `~/.beike/BEIKE_MCP_API_KEY`，后续自动使用。

### Skills 用户

Skills 安装后，在 Claude 中配置环境变量或通过脚本传入 API Key：

```bash
export BEIKE_MCP_API_KEY=<YOUR_API_KEY>
```

## 重置 API Key

### CLI 用户

```bash
beike auth <NEW_API_KEY> --save
```

### 手动重置

删除本地保存的 Key 文件：

```bash
rm ~/.beike/BEIKE_MCP_API_KEY
```

然后重新保存新的 Key。

## 安全建议

- 不要在代码或日志中暴露 API Key
- 定期更新 API Key
- 如有泄露，立即联系技术支持重置
