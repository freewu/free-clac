# free-clac

<img src="logo.png" alt="应用图标" width="96" align="right" />

使用 Flutter 开发的一款高级科学计算器，除常规表达式计算外，还内置二维平面函数绘图。

![计算器](docs/screenshots/calculator.png)
![函数绘图](docs/screenshots/plot.png)
![示例曲线：心形函数](docs/screenshots/heart.png)
![隐式方程：等值线心形](docs/screenshots/implicit.png)

## 功能

### 计算

- 自研词法 / 语法分析器 + 递归下降解析，支持完整运算符优先级、右结合幂运算与隐式乘法（`2π`、`3sin(x)`、`(1+2)(3+4)`）
- 实时预览：输入表达式时即时显示结果；按 `=` 或回车写入历史
- 历史记录：点击回填表达式，支持 `ans` 连续计算
- 角度单位一键切换 DEG / RAD（影响全部三角与反三角函数）
- 乘号按键显示为 `*`，粘贴 `×` 也会自动转换成 `*`
- Unicode 输入归一化：`× ÷ − π τ φ √ ∞`、全角括号、上标数字（`x²`）自动转换
- 常量：`π e τ φ ∞`
- 变量：`ans`（上次结果）、`mem`（存储值，支持 M+ / M− / MR / MC）

### 数学能力

| 类别 | 支持内容 |
| --- | --- |
| 三角 | `sin cos tan sec csc cot` 及反函数 `asin acos atan atan2` |
| 双曲 | `sinh cosh tanh asinh acosh atanh` |
| 指数对数 | `exp ln log lg log2`、任意幂 `x^y`、`√`、`cbrt`、`root(n,x)` |
| 取整 | `abs sign floor ceil round trunc frac`、取模 `mod` / `a % b` |
| 组合统计 | `fact`、`gamma`、`ncr`、`npr`、`gcd`、`lcm`、`min`、`max`、`avg`、`hypot` |
| 单位换算 | `deg`、`rad`、`sinc` |
| 随机 | `rand()`、`randint(a,b)` |
| 高级 | 求和 `sum(expr, i, a, b)`、连乘 `prod(...)` |
| 微积分 | 定积分 `integrate(f, x, a, b)`（自适应 Simpson）、数值求导 `diff(f, x, a)`（中心差分 + Richardson 外推） |

数值格式化会自动去除浮点噪声、按需切换科学计数法。

### 绘图

- 四种曲线类型：直角坐标 `y = f(x)`、极坐标 `r = f(t)`、参数方程 `(x(t), y(t))`、隐式方程 `f(x, y) = 0`
- 多条曲线同时绘制，独立配色、显隐、删除、类型切换
- 像素级自适应采样：按屏幕像素细分，间断点（如 `1/x`、`tan(x)`）自动断线
- 隐式方程用 marching squares 逐格求等值线，交点首尾相接成折线，鞍点按格心符号消歧；隐式曲线在追踪时显示该点的 `f(x, y)` 取值
- 交互：拖动平移、滚轮 / 触控板 / 双指缩放，悬停或长按追踪读数
- 移动视图：右下角十字方向键（或键盘 `← ↑ ↓ →`）按固定步长平移，`+` / `-` 缩放，`0` 重置视图
- 视图：网格与刻度自适应（1/2/2.5/5 × 10ⁿ）、纵向自适应、显示全部、重置
- 与计算器共享角度模式：极坐标与三角函数曲线随 DEG/RAD 切换重新采样
- 内置示例曲线：点面板右上角的 ✨ 图标一键载入心形函数、玫瑰线、李萨如曲线等，示例追加到当前画布（不清空已有曲线），详见下文
- 导出图片：点标题栏的图片按钮，可保存为 **PNG**（2 倍高清位图）、**WebP**（体积约为 PNG 的 1/10）或 **SVG**（矢量，可无限放大）
  - 桌面 / 移动端写入系统「图片」或「下载」文件夹，Web 端交给浏览器下载
  - 导出按当前视口与画布尺寸重新渲染，含网格、坐标轴、刻度与曲线光晕

### 示例曲线

绘图页函数面板右上角的 ✨ 按钮会打开示例列表，点选即**追加**到当前曲线（不清空已有图形，重复点选不会叠加同一曲线），视口自动扩展为与原视口的并集，已有图形不会移出视野。
示例主要来自知乎《[绘制出令人怦然心动的7种心形函数](https://zhuanlan.zhihu.com/p/662309066)》：

| 示例 | 类型 | 表达式 |
| --- | --- | --- |
| 心形 | 参数方程 | `x = 16sin³t`，`y = 13cos t − 5cos 2t − 2cos 3t − cos 4t` |
| 心形 | 极坐标 | `r = 2 − 2sin t + sin t·√\|cos t\| / (sin t + 1.4)` |
| 心形（正切幂） | 极坐标 | `r = \|tan t\|^(1/\|tan t\|)` |
| 无限爱心 | 直角坐标 | `y = √\|sin x\| ± √\|cos x\|` |
| 填充爱心 | 直角坐标 | `y = \|x\|^(2/3) + (4/5)√(9/10 − x²)·sin(1000πx)` |
| 跳动爱心 | 极坐标 | `r = (4 + sin t)/√(1 − \|cos t\|·sin t)` |
| 心形 | 隐式方程 | `(x²+y²−1)³ − x²y³ = 0` |

此外还内置玫瑰线 `r = 4cos(3t)`、李萨如曲线 `x = 4sin(3t), y = 4sin(4t)` 等常见图形。

Web 端可直接深链到示例：`?page=plot&preset=0`（`preset` 为示例下标，从 0 开始）。

### 视图移动

绘图区右下角新增十字方向键，按画布宽高的 22% 平移视图；中间按钮重置视图。

| 操作 | 效果 |
| --- | --- |
| 拖动画布 / 方向键按钮 | 平移视图（拖动时鼠标为“抓手”光标） |
| 键盘 `← ↑ ↓ →` | 平移视图（画布获得焦点时，点一下画布即可） |
| 键盘 `+` / `-` | 放大 / 缩小 |
| 键盘 `0` | 重置视图 |
| 滚轮 / 双指 | 以光标为中心缩放 |

## 应用图标

`logo.png`（256×256，透明底）是唯一来源，改图后执行一次即可同步所有平台：

```bash
just icons         # 由 logo.png 生成全部图标
just icons-check   # 只校验文件是否齐全（CI 可用）
```

生成的内容：

| 平台 | 文件 |
| --- | --- |
| Web | `web/favicon.png`、`web/icons/Icon-192/512.png`、`web/icons/Icon-maskable-192/512.png` |
| Windows | `windows/runner/resources/app_icon.ico`（16–256 七种尺寸，任务栏 / 资源管理器） |
| Android | `mipmap-*/ic_launcher.png`、`ic_launcher_round.png`，以及自适应图标 `ic_launcher_foreground.png` + `mipmap-anydpi-v26/ic_launcher.xml` |

Maskable / 自适应图标需要满幅，脚本会垫一层深色底（`#0B0F14`，与深色主题一致）并让图形占 72% 安全区；普通图标保留 logo 的透明背景。
项目暂无 iOS / macOS 目录，如需新增平台，脚本里加一段尺寸表即可。

## 运行

```bash
flutter pub get
flutter run -d chrome       # Web
flutter run -d windows      # Windows 桌面
flutter run                 # Android 设备 / 模拟器
```

Web 端可用 `?page=plot` 直接打开绘图页，`?page=plot&preset=0` 还会同时载入第一个示例。

## 开发命令（just）

项目用 [just](https://github.com/casey/just) 管理常用任务，`just` 不带参数即可列出全部命令。

- **WSL**：自动通过 `cmd.exe` 调用 Windows 侧的 Flutter，无需额外配置
- **Windows（PowerShell / cmd）**：recipes 由 Git Bash 的 `sh` 执行，需安装 [Git for Windows](https://git-scm.com/download/win)

```bash
just              # 列出全部命令
just deps         # flutter pub get
just run          # 运行（可附加参数：just run -d chrome）
just web          # Chrome 中调试 Web
just windows      # Windows 桌面调试
just android      # Android 调试
just devices      # 列出设备
```

| 分组 | 命令 | 说明 |
| --- | --- | --- |
| 质量 | `just analyze` | 静态分析 |
| 质量 | `just fmt` / `just fmt-check` | 格式化 / 检查格式 |
| 质量 | `just test` | 全部测试（`just test 历史` 按名称过滤） |
| 质量 | `just test-core` / `test-plot` / `test-widget` | 分模块测试 |
| 质量 | `just cover` | 生成覆盖率 `coverage/lcov.info` |
| 质量 | `just check` | 格式检查 + 分析 + 测试 |
| 构建 | `just build-web` / `build-apk` / `build-windows` | 分平台构建 |
| 构建 | `just build-web-offline` | 离线 Web 构建（CanvasKit 本地加载，不依赖 CDN） |
| 构建 | `just build` | Web + APK |
| 构建 | `just ci` | 依赖 → 检查 → 构建 |
| 工具 | `just preview` | 构建并本地预览（<http://localhost:8765>） |
| 工具 | `just shots` | 重新生成 `docs/screenshots` 截图 |
| 工具 | `just icons` / `just icons-check` | 由 `logo.png` 生成 / 校验各平台图标 |
| 工具 | `just clean` / `just outdated` | 清理产物 / 查看可升级依赖 |

## Android 构建

Android 构建需要本机具备 Android SDK 与 JDK（Web / Windows 构建不需要）。若未安装，`just build-apk` 会直接给出中文提示并退出：

```
✗ 没有检测到 Android SDK，构建无法继续。
```

安装步骤：

1. 安装 [Android Studio](https://developer.android.com/studio)（自带 SDK 与 JDK），或单独安装 commandline-tools
2. 在 SDK Manager 中安装 **Android 14 (API 34)** 平台、**Build-Tools**、**Platform-Tools**
3. 设置环境变量后重开终端：

   | 变量 | 示例值 |
   | --- | --- |
   | `ANDROID_HOME` | `%LOCALAPPDATA%\Android\Sdk`（Android Studio 默认位置） |
   | `JAVA_HOME` | `C:\Program Files\Android\Android Studio\jbr`（或任意 JDK 17+） |

   ```powershell
   setx ANDROID_HOME "$env:LOCALAPPDATA\Android\Sdk"
   setx JAVA_HOME "C:\Program Files\Android\Android Studio\jbr"
   ```

4. 接受许可并自检：

   ```bash
   flutter doctor --android-licenses
   flutter doctor -v      # Android toolchain 应为 ✓
   ```

5. 构建：

   ```bash
   just build-apk         # 产物：build/app/outputs/flutter-apk/app-release.apk
   just android           # 或直接连真机 / 模拟器调试
   ```

> 也可以不改环境变量，直接告诉 Flutter SDK 位置：`flutter config --android-sdk "C:\Users\<你>\AppData\Local\Android\Sdk"`。
>
> WSL 中执行 `just build-apk` 同样是调用 Windows 侧 Flutter，因此 SDK 需装在 Windows 上。

## 测试

```bash
just test
```

包含计算引擎单元测试（优先级、隐式乘法、函数、微积分、错误处理、格式化）、绘图视口 / 采样器（含隐式等值线）/ 控制器 / 示例曲线 / 导出（PNG、WebP、SVG）单元测试，以及多尺寸布局、示例面板、导出对话框等 Widget 测试（共 66 项）。

## 目录结构

```
lib/
├── core/       词法、语法、AST、求值器、内置函数、数字格式化、计算引擎
├── plot/       视口、曲线采样器、绘图画笔、示例预设、PNG / WebP / SVG 导出
├── models/     曲线、历史记录数据模型
├── services/   导出文件保存（Web 下载 / 磁盘写入，条件导入隔离平台差异）
├── state/      计算器与绘图控制器（ChangeNotifier）
├── ui/         页面与组件（键盘、显示屏、历史面板、绘图画布、函数面板）
└── theme/      深色主题与配色
test/           引擎、绘图、Widget 测试
tool/           辅助脚本（截图、由 logo.png 生成应用图标）
justfile        常用开发任务
```

## 常见问题

- **Windows 首次构建报 `Unsupported file type "notFound" ... flutter_windows.dll.pdb`**：Flutter SDK 的引擎产物下载不完整，执行 `just precache`（即 `flutter precache --windows --force`）重新下载即可。
- **PowerShell 下 `just` 报 `$'\r': command not found`**：recipes 需要 Git Bash，确认 `sh.exe` 在 PATH 中（安装 Git for Windows）。
- **`just build-apk` 报 `No Android SDK found`**：参见上文「Android 构建」，装好 SDK / JDK 并设置 `ANDROID_HOME`、`JAVA_HOME` 后重开终端。

## 说明

- 计算引擎不依赖第三方数学库，`sum` / `integrate` / `diff` 等以特殊形式在求值阶段处理，因此可对变量求值。
- 计算器与绘图页共享同一个 `MathEngine` 实例，角度模式、解析缓存保持一致。

## 协作约定

提交前跑 `just check`（格式化 + 静态分析 + 全部测试）；**每次开发完成后立即提交并推送到远程**（`git push origin main`）。完整约定见 [AGENTS.md](AGENTS.md)。
