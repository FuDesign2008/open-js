# open-js

通过 GitHub + jsDelivr 托管的公开 JS 文件，供外部项目通过 CDN 引用。

## 文件清单

| 文件 | 说明 | 大小 |
|------|------|------|
| `collect-window.js` | 有道云笔记网页收藏 SDK（UMD） | ~31KB |

## CDN 地址

所有文件通过 [jsDelivr](https://www.jsdelivr.com/) 分发，基于 GitHub release tag：

```
https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@<tag>/<filename>
```

### collect-window.js

| 类型 | URL |
|------|-----|
| 版本锁定（推荐） | `https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@v1.0.0/collect-window.js` |
| 最新 tag | `https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@latest/collect-window.js` |
| main 分支 | `https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@main/collect-window.js` |

> **生产环境务必使用版本锁定地址**，避免 CDN 缓存刷新延迟导致版本不一致。

## 更新 & 发布流程

### 1. 更新文件

将新版本的 JS 文件复制到仓库根目录，覆盖旧文件：

```bash
cp /path/to/new/collect-window.js ./collect-window.js
```

### 2. 提交 & 推送

```bash
git add .
git commit -m "feat: update collect-window.js to vX.Y.Z"
git push origin main
```

### 3. 创建版本 Tag

遵循 [semver](https://semver.org/) 规范，格式为 `vMAJOR.MINOR.PATCH`：

```bash
git tag vX.Y.Z
git push origin vX.Y.Z
```

**版本号规则**：

| 变更类型 | 版本递增 | 示例 |
|----------|----------|------|
| 不兼容的 API 变更 | MAJOR | v1.0.0 → v2.0.0 |
| 新增功能（向后兼容） | MINOR | v1.0.0 → v1.1.0 |
| Bug 修复 | PATCH | v1.0.0 → v1.0.1 |

### 4. 验证 CDN 生效

```bash
# 验证新 tag 的 CDN 地址可访问
curl -sI "https://cdn.jsdelivr.net/gh/FuDesign2008/open-js@vX.Y.Z/collect-window.js" | head -5
```

预期输出：

```
HTTP/2 200
content-type: application/javascript; charset=utf-8
cache-control: public, max-age=31536000, s-maxage=31536000, immutable
access-control-allow-origin: *
```

> jsDelivr 对新 tag 通常在几分钟内生效。若返回 404，等待 5 分钟后重试。

### 5. 更新下游引用

发布新版本后，需同步更新引用了旧版本 CDN 地址的下游项目：

- **ynote-claw**：`openclaw/skills/ynote-clip/SKILL.md` Step 3 中的 CDN URL

## jsDelivr 缓存说明

| URL 类型 | 缓存策略 | 说明 |
|----------|----------|------|
| `@vX.Y.Z`（tag） | 永久缓存（immutable） | 发布后内容不可变，最可靠 |
| `@latest` | 短期缓存（~24h） | 自动指向最新 tag，有延迟 |
| `@main`（分支） | 短期缓存（~24h） | 跟踪分支最新 commit，有延迟 |

**如需强制刷新 CDN 缓存**：

```
https://purge.jsdelivr.net/gh/FuDesign2008/open-js@main/collect-window.js
```

## 版本历史

| Tag | 日期 | 说明 |
|-----|------|------|
| v1.0.0 | 2026-03-03 | 首次发布 collect-window.js |
