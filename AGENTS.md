# AGENTS.md

本仓库的协作约定，AI 代理与人类贡献者共同遵守。

## 项目速览

- **free-clac**：Flutter 科学计算器 + 2D 函数绘图，支持 Web / Windows / Android。
- 表达式解析与求值：`lib/core/math_engine.dart`（自研词法 + 递归下降，无第三方计算库）。
- 绘图：`lib/plot/`（视口、采样器、示例曲线），状态在 `lib/state/`，界面在 `lib/ui/`。
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
- 界面有明显变化时用 `just shots` 重新生成截图，并在 README 引用。
- 需要 Android 工具链的配方（`build-apk`、`android`）先 `. tool/android-env.sh`：它会补 `JAVA_HOME` / `ANDROID_HOME`，WSL 下再用 `WSLENV` 传给 Windows 侧进程。
- Android 自适应图标 XML（`mipmap-anydpi-v26/*.xml`）必须声明 `xmlns:android`，否则 AAPT2 编译失败；`just icons-check` 会校验这一项。
- **不要给 justfile 写 shebang 配方**（`#!/usr/bin/env sh`）：Windows 上 just 会用 `cygpath` 翻译解释器路径，而 Git for Windows 默认没把 `usr/bin` 放进 PATH，会直接报 `could not find cygpath`。用普通配方 + 行尾 `\` 连接（见 `build-apk`）。
