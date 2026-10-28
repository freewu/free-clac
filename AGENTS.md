# AGENTS.md

本仓库的协作约定，AI 代理与人类贡献者共同遵守。

## 项目速览

- **free-clac**：Flutter 科学计算器 + 2D 函数绘图，支持 Web / Windows / Android。
- 表达式解析与求值：`lib/core/math_engine.dart`（自研词法 + 递归下降，无第三方计算库）。
- 绘图：`lib/plot/`（视口、采样器、示例曲线），状态在 `lib/state/`，界面在 `lib/ui/`。
- 多语言：`lib/l10n/`（语言枚举 `AppLanguage`、应用级文案 `AppStrings`、全局入口 `t`），工具语言包在 `lib/ui/tools/<tool>/lang/`。
- 配色：`lib/theme/app_theme.dart` 的 `AppPalette`（深色 `kDarkPalette` / 浅色 `kLightPalette`），全局取色入口是 `AppColors`；设置页在 `lib/ui/settings_page.dart`，状态在 `lib/state/settings_controller.dart`，本地存储在 `lib/services/settings_store*.dart`。
- 已知环境：Windows + WSL，`flutter` / `dart` 是 Windows 程序。

## 环境与命令

在 WSL 中不要直接调用 `flutter`，用 `just`（会自动经 `cmd.exe` 换算路径）；也可手动：

```bash
cmd.exe /c "cd /d $(wslpath -w "$PWD") && flutter test"
```

| 命令 | 作用 |
| --- | --- |
| `just` | 列出全部命令 |
| `just check` | 格式检查 + `flutter analyze` + 全部测试（**提交前必跑**） |
| `just test` / `just analyze` / `just fmt` | 单项 |
| `just icons-check` | 校验图标文件齐全 |
| `just run` / `just build-web` | 本地运行 / 构建 Web |
| `just shots` | 重新生成 `docs/screenshots/*.png`（需 Chrome 与 `build/web`） |

## 提交与推送（硬性要求）

**每次开发任务完成（功能、修复、重构、文档）后，必须立即 commit 并 push 到远程，不要留下未提交的工作区。**

流程：

1. 跑 `just check`，确保格式化、静态分析、测试全部通过；顺带跑 `just icons-check`（如改动图标）。
2. `git add -A`。`build/`、`.dart_tool/` 等产物已被 `.gitignore` 排除，不要提交它们。
3. 写提交信息（中文，一行摘要 + 可选正文，说明动机与影响），例如：

   ```text
   新增隐式方程绘图（marching squares 等值线）

   - f(x, y) = 0 逐格求交点并首尾相连，鞍点按格心符号消歧
   - MathEngine 新增 compileSurface，追踪时显示 f(x, y) 取值
   ```

4. `git push origin main`；分支尚未跟踪时用 `git push -u origin main`。
5. 推送失败（网络、凭证）时保留本地提交并明确告知用户；**禁止** `push --force` 到 `main`。

## 代码约定

- 界面文案、注释、提交信息一律用中文；变量与 API 用英文。
- 严格通过 `dart format`（80 列）与 `analysis_options.yaml` 的 lint，不要用 `// ignore:` 绕过。
- 改动计算逻辑或采样算法时，在 `test/` 补单元测试；改动交互时补 Widget 测试。
- 新增曲线类型 / 视图行为时同步更新 README 的功能列表、示例表格与测试数量。
- **工具相关设置**（如 BMI 默认单位）放在 `lib/ui/tools/<tool>/setting.dart`，由设置页引用；设置项本身存在 `SettingsController`，页面用不到 `BuildContext` 时读全局 `currentSettings`。
- **只在部分语言提供的工具**（如养老金、个税只适用中国口径）在 `ToolInfo.availableIn` 里声明语言集合；工具页与 `toolById` 都只看 `visibleTools`，别直接遍历 `kTools`。
- **界面文案一律走多语言**：应用级（导航、设置、工具页标题）用 `t.xxx`（`lib/l10n/app_strings.dart` 里 `AppStrings` 的五个实现都要补），工具卡片名称 / 卖点 / 说明写进 `lib/ui/tools/<tool>/lang/<tool>_lang.dart` 的 `k<Tool>Lang`。注释用中文，界面文案用各语言母语。
- **颜色一律走 `AppColors`**：不要硬编码 `Color(0xFF...)`，也不要在 `const` 表达式里用 `AppColors.xxx`（它不是常量），深色 / 浅色两套配色都要能看。
- 小工具分两层：纯逻辑放 `lib/tools/`（不依赖 Flutter），界面放 `lib/ui/tools/<tool>/`。共用的输入框与比例条放在 `lib/ui/tools/widgets/`（`tool_field.dart`、`tool_unit_picker.dart`、`tool_select.dart`、`tool_bars.dart`），不要在每个工具里各写一份。每个工具的 `ToolInfo`（名称、卖点、图标、配色、页面构造器）写在**自己目录的 `defined.dart`** 里，`lib/ui/tools/tool_catalog.dart` 只汇总 `kTools`；新增工具 = 新建 `<tool>/defined.dart` + 新建 `<tool>/lang/<tool>_lang.dart`（五种语言）+ 在 `kTools` 追加一行 + `tool/screenshot.sh` 加一条 `shoot`。
- 界面有明显变化时用 `just shots` 重新生成截图，并在 README 引用。
- `justfile` 用到的 Python 辅助脚本（如 `tool/android_target.py`）要带 `--selftest`，并挂到 `just check` 的 `tool-check` 上。
- 需要 Android 工具链的配方（`build-apk`、`android`）先 `. tool/android-env.sh`：它会补 `JAVA_HOME` / `ANDROID_HOME`，WSL 下再用 `WSLENV` 传给 Windows 侧进程。
- Android 自适应图标 XML（`mipmap-anydpi-v26/*.xml`）必须声明 `xmlns:android`，否则 AAPT2 编译失败；`just icons-check` 会校验这一项。
- Web 产物必须自包含：`just build-web` 走 `--no-web-resources-cdn`（CanvasKit 取 SDK 自带副本），并把 `web/fonts/`（`tool/web_fonts.py` 下载的 Roboto / Noto 回退字体）拷进 `build/web/fonts/`，配合 `web/flutter_bootstrap.js` 的 `fontFallbackBaseUrl: "fonts/"`。改 Web 构建相关配置后，用「阻断外网 + headless Chrome 截图」验证断网可正常渲染（做法见 README《Web 部署》）。
- Android 导出图片走 `MediaStore`（`android/app/src/main/kotlin/.../MainActivity.kt` 的
  `free_clac/media_store` 通道），落盘位置必须和对话框「保存位置」一致；改动后用
  `just emulator` + `just test-android` 在模拟器上验证，别退回写应用缓存目录。
- 截图 / 离线演示一律用 `just shots`（内部就是 `just build-web`），不要用 `build-web-cdn`，否则内网或断网环境会白屏、文字变方块。
- **不要给 justfile 写 shebang 配方**（`#!/usr/bin/env sh`）：Windows 上 just 会用 `cygpath` 翻译解释器路径，而 Git for Windows 默认没把 `usr/bin` 放进 PATH，会直接报 `could not find cygpath`。用普通配方 + 行尾 `\` 连接（见 `build-apk`）。
