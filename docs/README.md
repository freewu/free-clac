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
| 首屏 | 应用名、一句话介绍、四个统计数字、计算器手机截图（底部导航有热区，点了换图） |
| 特性 | 表达式引擎、四种曲线、像素级采样、示例曲线、深浅配色、五种语言、导出、草稿 |
| 截图 | 计算器 / 绘图 / 心形 / 隐式 / 工具页 / 设置 六张手机竖屏截图，套手机外壳 |
| 配色 | 同一页面的深色与浅色手机截图并排 |
| 工具 | 全部工具各一张手机截图（卡片里裁成 3:4 的上半屏），强调色取自 App 的 `AppColors` |
| 语言 | 五种语言卡片，点击切换整站（含整套截图） |
| 页脚 | 仓库、README、许可证 |

点任意截图可放大（灯箱，`Esc` 关闭）。

首屏那张手机图底部盖了四格透明热区，对上图里 App 自己的导航条（计算器 / 绘图 /
工具 / 设置，各占 1/4，高 62 / 844）：点哪格就换成那一页的手机截图，当前格用
`aria-current` 标记。实现在 `site.js` 的 `HERO_PAGES` / `.hero-hotspot`，截图都带
同样的底部导航，所以换任何一张都对得上；浅色主题下计算器仍是 `calculator-light`。

**整站以手机截图为主**：App 是「手机优先」的界面，官网也只用 390×844 的竖屏图，
配齐五种语言；桌面截图（1440 宽）只留给 README，不出现在官网上。

## 三条约定

1. **文案不手写工具名**：工具卡片来自 `assets/tools-data.js`，由 `tool/site_data.py`
   从 `lib/ui/tools/tool_catalog.dart`、各工具 `defined.dart` 与 `<tool>_lang.dart` 导出。
   改完语言包执行 `just site-data`（`just check` 里的 `site-check` 会检查有没有过期）。
2. **截图按语言分目录**：`screenshots/<语言>/`，语言代码与 App 里一致
   （`zh-Hans`、`zh-Hant`、`en`、`ja`、`es`）。两种规格：
   - `<名字>-phone.png`（390×844，2 倍图）——官网用的手机截图，五种语言齐备；
   - `<名字>.png`（1440 宽）——README 用的桌面截图，只有简体出全套，
     其它语言只留 `calculator.png` 当语言示例。

   全部由 `just shots` 重新生成，脚本用无头 Chrome 打开 `build/web` 并带
   `?lang=` / `?theme=` / `?page=` 深链，所以图里的界面语言、配色、数据都和真机一致。
3. **配色只用 CSS 变量**：`assets/site.css` 顶部两组变量（`:root` 深色、
   `:root[data-theme='light']` 浅色），不要在别处硬编码颜色；工具卡片的强调色是
   行内 `--accent-dark` / `--accent-light`，两套主题各取一个。
4. **顶栏语言切换不用原生 `<select>`**：原生下拉的展开面板由系统配色决定，
   深色下会出现浅底浅字（看不清）。现在是自己画的按钮 + `role="listbox"` 列表，
   底色文字色都来自变量（对比度 > 15:1），键盘也能全用（`↑` `↓` `Home` `End` `Enter` `Esc`）。
   以后要加下拉（如货币）也照这个来。

## 改了 App 之后

```bash
just shots        # 重新截五种语言（只截一部分：just shots zh-Hans en）
just site-data    # 工具名称 / 卖点 / 颜色有变动时
```

`just shots` 会先 `just build-web`（离线自包含产物），再逐张截图；跑完记得
把 `docs/screenshots/` 一起提交。
