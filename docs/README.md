# Magic 计算器官网（docs/）

一份不用构建的静态站点，GitHub Pages 可直接把 `docs/` 当站点根目录发布
（仓库 Settings → Pages → Source: `main` / `/docs`）。

## 怎么看

```bash
just site-preview      # http://localhost:8780/index.html
```

或者直接双击 `docs/index.html`——`file://` 下同样能跑（截图与脚本都是相对路径）。

## 有什么

| 区块 | 内容 |
| --- | --- |
| 首屏 | 应用名、一句话介绍、四个统计数字、按当前配色展示的计算器截图 |
| 特性 | 表达式引擎、四种曲线、像素级采样、示例曲线、深浅配色、五种语言、导出、草稿 |
| 截图 | 计算器 / 绘图 / 心形 / 隐式 / 工具页 / 设置 六张，外加手机竖屏 |
| 配色 | 同一页面的深色与浅色并排 |
| 工具 | 全部工具各一张截图，卡片强调色取自 App 的 `AppColors` |
| 语言 | 五种语言卡片，点击切换整站（含整套截图） |
| 页脚 | 仓库、README、许可证 |

点任意截图可放大（灯箱，`Esc` 关闭）。

## 三条约定

1. **文案不手写工具名**：工具卡片来自 `assets/tools-data.js`，由 `tool/site_data.py`
   从 `lib/ui/tools/tool_catalog.dart`、各工具 `defined.dart` 与 `<tool>_lang.dart` 导出。
   改完语言包执行 `just site-data`（`just check` 里的 `site-check` 会检查有没有过期）。
2. **截图按语言分目录**：`screenshots/<语言>/<名字>.png`，语言代码与 App 里一致
   （`zh-Hans`、`zh-Hant`、`en`、`ja`、`es`）。全部由 `just shots` 重新生成，
   脚本用无头 Chrome 打开 `build/web` 并带 `?lang=` / `?theme=` / `?page=` 深链，
   所以图里的界面语言、配色、数据都和真机一致。
3. **配色只用 CSS 变量**：`assets/site.css` 顶部两组变量（`:root` 深色、
   `:root[data-theme='light']` 浅色），不要在别处硬编码颜色；工具卡片的强调色是
   行内 `--accent-dark` / `--accent-light`，两套主题各取一个。

## 改了 App 之后

```bash
just shots        # 重新截五种语言（只截一部分：just shots zh-Hans en）
just site-data    # 工具名称 / 卖点 / 颜色有变动时
```

`just shots` 会先 `just build-web`（离线自包含产物），再逐张截图；跑完记得
把 `docs/screenshots/` 一起提交。
