import '../models/plot_function.dart';
import 'app_i18n.dart';
import 'app_language.dart';

/// 绘图页面（顶栏、画布、曲线面板、示例面板、导出对话框）的界面文案。
///
/// 与工具页的 `<tool>_strings.dart` 同一套写法：`required` 具名字段保证不漏
/// 语言，带参数的话术写成 `{0}` 模板，用 [fill] 填充。
class PlotStrings {
  const PlotStrings({
    required this.title,
    required this.angleTooltip,
    required this.hideGrid,
    required this.showGrid,
    required this.traceOff,
    required this.traceOn,
    required this.exportTooltip,
    required this.emptyCanvas,
    required this.moveUp,
    required this.moveDown,
    required this.moveLeft,
    required this.moveRight,
    required this.zoomIn,
    required this.zoomOut,
    required this.resetView,
    required this.fitVertical,
    required this.showAll,
    required this.panelTitle,
    required this.presets,
    required this.clearAll,
    required this.addCurve,
    required this.modeCartesian,
    required this.modePolar,
    required this.modeParametric,
    required this.modeImplicit,
    required this.modeCartesianMenu,
    required this.modePolarMenu,
    required this.modeParametricMenu,
    required this.modeImplicitMenu,
    required this.modeCartesianHint,
    required this.modePolarHint,
    required this.modeParametricHint,
    required this.modeImplicitHint,
    required this.emptyCurves,
    required this.gestureHint,
    required this.latexFailed,
    required this.latexCopied,
    required this.tapToChangeColor,
    required this.switchMode,
    required this.hideCurve,
    required this.showCurve,
    required this.copyLatex,
    required this.delete,
    required this.presetAlready,
    required this.presetAdded,
    required this.presetIntro,
    required this.presetCurveCount,
    required this.presetSource,
    required this.exportTitle,
    required this.close,
    required this.vectorSize,
    required this.imageSize,
    required this.vectorSizeValue,
    required this.rasterSizeValue,
    required this.viewportLabel,
    required this.curvesLabel,
    required this.saveLocation,
    required this.cancel,
    required this.download,
    required this.save,
    required this.saved,
    required this.openFolder,
    required this.exportFailed,
    required this.noVisibleCurves,
    required this.saveLocationWeb,
    required this.saveLocationBrowser,
    required this.saveLocationAndroid,
    required this.saveLocationIos,
    required this.notePng,
    required this.noteWebp,
    required this.noteSvg,
    required this.traceUndefined,
    required this.traceError,
  });

  final String title;

  /// 「角度单位（{0}），点击切换」。
  final String angleTooltip;
  final String hideGrid;
  final String showGrid;
  final String traceOff;
  final String traceOn;
  final String exportTooltip;

  /// 画布空状态。
  final String emptyCanvas;
  final String moveUp;
  final String moveDown;
  final String moveLeft;
  final String moveRight;
  final String zoomIn;
  final String zoomOut;
  final String resetView;
  final String fitVertical;
  final String showAll;

  final String panelTitle;
  final String presets;
  final String clearAll;
  final String addCurve;

  /// 曲线类型的短名称（曲线卡片上的标签、切换菜单）。
  final String modeCartesian;
  final String modePolar;
  final String modeParametric;
  final String modeImplicit;

  /// 「添加曲线」菜单里的完整描述。
  final String modeCartesianMenu;
  final String modePolarMenu;
  final String modeParametricMenu;
  final String modeImplicitMenu;

  /// 表达式输入框的提示。
  final String modeCartesianHint;
  final String modePolarHint;
  final String modeParametricHint;
  final String modeImplicitHint;

  final String emptyCurves;
  final String gestureHint;
  final String latexFailed;
  final String latexCopied;
  final String tapToChangeColor;
  final String switchMode;
  final String hideCurve;
  final String showCurve;
  final String copyLatex;
  final String delete;

  /// 「「{0}」已在图中」。
  final String presetAlready;

  /// 「已添加示例：{0}（+{1} 条）」。
  final String presetAdded;
  final String presetIntro;

  /// 「{0} 条」。
  final String presetCurveCount;
  final String presetSource;

  final String exportTitle;
  final String close;
  final String vectorSize;
  final String imageSize;

  /// 「{0} × {1}（可无限缩放）」。
  final String vectorSizeValue;

  /// 「{0}（{1} 倍图）」。
  final String rasterSizeValue;
  final String viewportLabel;
  final String curvesLabel;
  final String saveLocation;
  final String cancel;
  final String download;
  final String save;

  /// 「已保存：{0}」。
  final String saved;
  final String openFolder;

  /// 「导出失败：{0}」。
  final String exportFailed;
  final String noVisibleCurves;

  /// 各种平台「保存位置」的说明。
  final String saveLocationWeb;
  final String saveLocationBrowser;
  final String saveLocationAndroid;
  final String saveLocationIos;

  /// 三种图片格式的说明。
  final String notePng;
  final String noteWebp;
  final String noteSvg;

  /// 追踪卡片上的两句话。
  final String traceUndefined;
  final String traceError;

  /// 曲线类型短名称。
  String modeLabel(PlotMode mode) => switch (mode) {
    PlotMode.cartesian => modeCartesian,
    PlotMode.polar => modePolar,
    PlotMode.parametric => modeParametric,
    PlotMode.implicit => modeImplicit,
  };

  /// 「添加曲线」菜单里的名称。
  String modeMenu(PlotMode mode) => switch (mode) {
    PlotMode.cartesian => modeCartesianMenu,
    PlotMode.polar => modePolarMenu,
    PlotMode.parametric => modeParametricMenu,
    PlotMode.implicit => modeImplicitMenu,
  };

  /// 表达式输入框的提示。
  String modeHint(PlotMode mode) => switch (mode) {
    PlotMode.cartesian => modeCartesianHint,
    PlotMode.polar => modePolarHint,
    PlotMode.parametric => modeParametricHint,
    PlotMode.implicit => modeImplicitHint,
  };
}

/// 各语言的绘图页面文案。
const Map<AppLanguage, PlotStrings> kPlotStrings = <AppLanguage, PlotStrings>{
  AppLanguage.zhHans: PlotStrings(
    title: '函数绘图',
    angleTooltip: '角度单位（{0}），点击切换',
    hideGrid: '隐藏网格',
    showGrid: '显示网格',
    traceOff: '关闭触摸追踪',
    traceOn: '开启触摸追踪（拖动查看数值）',
    exportTooltip: '导出图片（PNG / SVG / WebP）',
    emptyCanvas: '还没有函数，点击右上角“+”添加一条曲线',
    moveUp: '上移视图（↑）',
    moveDown: '下移视图（↓）',
    moveLeft: '左移视图（←）',
    moveRight: '右移视图（→）',
    zoomIn: '放大（+）',
    zoomOut: '缩小（-）',
    resetView: '重置视图（0）',
    fitVertical: '纵向自适应',
    showAll: '显示全部',
    panelTitle: '曲线',
    presets: '示例曲线',
    clearAll: '清空全部',
    addCurve: '添加曲线',
    modeCartesian: '直角坐标',
    modePolar: '极坐标',
    modeParametric: '参数方程',
    modeImplicit: '隐式方程',
    modeCartesianMenu: '直角坐标 y = f(x)',
    modePolarMenu: '极坐标 r = f(t)',
    modeParametricMenu: '参数方程',
    modeImplicitMenu: '隐式方程 f(x, y) = 0',
    modeCartesianHint: 'y = f(x)',
    modePolarHint: 'r(t)，t 为角度',
    modeParametricHint: 'x(t) 与 y(t)',
    modeImplicitHint: 'f(x, y) = 0',
    emptyCurves: '点击 + 添加曲线\n例如 sin(x)、x^2/4、1/x\n隐式方程：x^2 + y^2 - 1',
    gestureHint: '提示：滚轮 / 双指缩放，拖拽平移，悬停或长按查看数值',
    latexFailed: '表达式不完整，无法转换为 LaTeX',
    latexCopied: 'LaTeX 已复制',
    tapToChangeColor: '点击切换颜色',
    switchMode: '切换曲线类型',
    hideCurve: '隐藏曲线',
    showCurve: '显示曲线',
    copyLatex: '复制 LaTeX',
    delete: '删除',
    presetAlready: '「{0}」已在图中',
    presetAdded: '已添加示例：{0}（+{1} 条）',
    presetIntro: '示例会追加到当前画布，视口自动扩展以容纳已有图形；重复载入不会叠加相同曲线。',
    presetCurveCount: '{0} 条',
    presetSource: '来源：知乎《绘制出令人怦然心动的7种心形函数》\n{0}',
    exportTitle: '导出图片',
    close: '关闭',
    vectorSize: '矢量尺寸',
    imageSize: '图片尺寸',
    vectorSizeValue: '{0} × {1}（可无限缩放）',
    rasterSizeValue: '{0}（{1} 倍图）',
    viewportLabel: '视口范围',
    curvesLabel: '曲线',
    saveLocation: '保存位置',
    cancel: '取消',
    download: '下载',
    save: '保存',
    saved: '已保存：{0}',
    openFolder: '打开文件夹',
    exportFailed: '导出失败：{0}',
    noVisibleCurves: '暂无可见曲线',
    saveLocationWeb: '浏览器下载目录',
    saveLocationBrowser: '浏览器默认下载目录',
    saveLocationAndroid: '系统相册「Pictures/free-clac」（SVG 存到「Download/free-clac」）',
    saveLocationIos: '应用沙盒临时目录',
    notePng: '位图，无损，兼容性最好',
    noteWebp: '位图，有损压缩，体积更小',
    noteSvg: '矢量，可无限放大，适合排版印刷',
    traceUndefined: '未定义',
    traceError: '表达式错误',
  ),
  AppLanguage.zhHant: PlotStrings(
    title: '函數繪圖',
    angleTooltip: '角度單位（{0}），點擊切換',
    hideGrid: '隱藏網格',
    showGrid: '顯示網格',
    traceOff: '關閉觸控追蹤',
    traceOn: '開啟觸控追蹤（拖曳查看數值）',
    exportTooltip: '匯出圖片（PNG / SVG / WebP）',
    emptyCanvas: '還沒有函數，點擊右上角「+」新增一條曲線',
    moveUp: '上移視圖（↑）',
    moveDown: '下移視圖（↓）',
    moveLeft: '左移視圖（←）',
    moveRight: '右移視圖（→）',
    zoomIn: '放大（+）',
    zoomOut: '縮小（-）',
    resetView: '重設視圖（0）',
    fitVertical: '縱向自適應',
    showAll: '顯示全部',
    panelTitle: '曲線',
    presets: '範例曲線',
    clearAll: '清空全部',
    addCurve: '新增曲線',
    modeCartesian: '直角座標',
    modePolar: '極座標',
    modeParametric: '參數方程',
    modeImplicit: '隱式方程',
    modeCartesianMenu: '直角座標 y = f(x)',
    modePolarMenu: '極座標 r = f(t)',
    modeParametricMenu: '參數方程',
    modeImplicitMenu: '隱式方程 f(x, y) = 0',
    modeCartesianHint: 'y = f(x)',
    modePolarHint: 'r(t)，t 為角度',
    modeParametricHint: 'x(t) 與 y(t)',
    modeImplicitHint: 'f(x, y) = 0',
    emptyCurves: '點擊 + 新增曲線\n例如 sin(x)、x^2/4、1/x\n隱式方程：x^2 + y^2 - 1',
    gestureHint: '提示：滾輪 / 雙指縮放，拖曳平移，懸停或長按查看數值',
    latexFailed: '表達式不完整，無法轉換為 LaTeX',
    latexCopied: 'LaTeX 已複製',
    tapToChangeColor: '點擊切換顏色',
    switchMode: '切換曲線類型',
    hideCurve: '隱藏曲線',
    showCurve: '顯示曲線',
    copyLatex: '複製 LaTeX',
    delete: '刪除',
    presetAlready: '「{0}」已在圖中',
    presetAdded: '已新增範例：{0}（+{1} 條）',
    presetIntro: '範例會附加到目前畫布，視圖自動擴展以容納既有圖形；重複載入不會疊加相同曲線。',
    presetCurveCount: '{0} 條',
    presetSource: '來源：知乎《繪製出令人怦然心動的 7 種心形函數》\n{0}',
    exportTitle: '匯出圖片',
    close: '關閉',
    vectorSize: '向量尺寸',
    imageSize: '圖片尺寸',
    vectorSizeValue: '{0} × {1}（可無限縮放）',
    rasterSizeValue: '{0}（{1} 倍圖）',
    viewportLabel: '視圖範圍',
    curvesLabel: '曲線',
    saveLocation: '儲存位置',
    cancel: '取消',
    download: '下載',
    save: '儲存',
    saved: '已儲存：{0}',
    openFolder: '開啟資料夾',
    exportFailed: '匯出失敗：{0}',
    noVisibleCurves: '暫無可見曲線',
    saveLocationWeb: '瀏覽器下載目錄',
    saveLocationBrowser: '瀏覽器預設下載目錄',
    saveLocationAndroid: '系統相簿「Pictures/free-clac」（SVG 存到「Download/free-clac」）',
    saveLocationIos: '應用程式沙盒暫存目錄',
    notePng: '點陣圖，無損，相容性最好',
    noteWebp: '點陣圖，有損壓縮，體積更小',
    noteSvg: '向量圖，可無限放大，適合排版印刷',
    traceUndefined: '未定義',
    traceError: '表達式錯誤',
  ),
  AppLanguage.en: PlotStrings(
    title: 'Function plot',
    angleTooltip: 'Angle unit ({0}) — tap to switch',
    hideGrid: 'Hide grid',
    showGrid: 'Show grid',
    traceOff: 'Turn off touch tracing',
    traceOn: 'Turn on touch tracing (drag to read values)',
    exportTooltip: 'Export image (PNG / SVG / WebP)',
    emptyCanvas: 'No functions yet — tap “+” in the top right to add one',
    moveUp: 'Move view up (↑)',
    moveDown: 'Move view down (↓)',
    moveLeft: 'Move view left (←)',
    moveRight: 'Move view right (→)',
    zoomIn: 'Zoom in (+)',
    zoomOut: 'Zoom out (-)',
    resetView: 'Reset view (0)',
    fitVertical: 'Fit vertically',
    showAll: 'Show everything',
    panelTitle: 'Curves',
    presets: 'Sample curves',
    clearAll: 'Clear all',
    addCurve: 'Add curve',
    modeCartesian: 'Cartesian',
    modePolar: 'Polar',
    modeParametric: 'Parametric',
    modeImplicit: 'Implicit',
    modeCartesianMenu: 'Cartesian y = f(x)',
    modePolarMenu: 'Polar r = f(t)',
    modeParametricMenu: 'Parametric x(t), y(t)',
    modeImplicitMenu: 'Implicit f(x, y) = 0',
    modeCartesianHint: 'y = f(x)',
    modePolarHint: 'r(t), t in degrees',
    modeParametricHint: 'x(t) and y(t)',
    modeImplicitHint: 'f(x, y) = 0',
    emptyCurves:
        'Tap + to add a curve\ne.g. sin(x), x^2/4, 1/x\n'
        'implicit: x^2 + y^2 - 1',
    gestureHint:
        'Tip: wheel / pinch to zoom, drag to pan, hover or long-press for values',
    latexFailed: 'Incomplete expression, cannot convert to LaTeX',
    latexCopied: 'LaTeX copied',
    tapToChangeColor: 'Tap to change the color',
    switchMode: 'Switch curve type',
    hideCurve: 'Hide curve',
    showCurve: 'Show curve',
    copyLatex: 'Copy LaTeX',
    delete: 'Delete',
    presetAlready: '“{0}” is already on the canvas',
    presetAdded: 'Sample added: {0} (+{1})',
    presetIntro:
        'Samples are appended to the canvas and the viewport grows to fit. '
        'Loading the same sample twice does not duplicate its curves.',
    presetCurveCount: '{0} curves',
    presetSource:
        'Source: Zhihu, “7 heart functions that make you fall in love”\n{0}',
    exportTitle: 'Export image',
    close: 'Close',
    vectorSize: 'Vector size',
    imageSize: 'Image size',
    vectorSizeValue: '{0} × {1} (scales forever)',
    rasterSizeValue: '{0} ({1}× pixel ratio)',
    viewportLabel: 'Viewport',
    curvesLabel: 'Curves',
    saveLocation: 'Saved to',
    cancel: 'Cancel',
    download: 'Download',
    save: 'Save',
    saved: 'Saved: {0}',
    openFolder: 'Open folder',
    exportFailed: 'Export failed: {0}',
    noVisibleCurves: 'No visible curves',
    saveLocationWeb: 'your browser’s download folder',
    saveLocationBrowser: 'your browser’s download folder',
    saveLocationAndroid:
        'the gallery folder “Pictures/free-clac” (SVG goes to “Download/free-clac”)',
    saveLocationIos: 'the app sandbox’s temporary folder',
    notePng: 'Bitmap, lossless, best compatibility',
    noteWebp: 'Bitmap, lossy, smaller files',
    noteSvg: 'Vector, scales infinitely, best for print',
    traceUndefined: 'undefined',
    traceError: 'expression error',
  ),
  AppLanguage.ja: PlotStrings(
    title: '関数グラフ',
    angleTooltip: '角度の単位（{0}）— タップで切り替え',
    hideGrid: 'グリッドを隠す',
    showGrid: 'グリッドを表示',
    traceOff: 'タッチ追跡をオフ',
    traceOn: 'タッチ追跡をオン（ドラッグで値を表示）',
    exportTooltip: '画像を書き出す（PNG / SVG / WebP）',
    emptyCanvas: 'まだ関数がありません。右上の「+」で曲線を追加',
    moveUp: '表示を上へ（↑）',
    moveDown: '表示を下へ（↓）',
    moveLeft: '表示を左へ（←）',
    moveRight: '表示を右へ（→）',
    zoomIn: '拡大（+）',
    zoomOut: '縮小（-）',
    resetView: '表示をリセット（0）',
    fitVertical: '縦方向に合わせる',
    showAll: 'すべて表示',
    panelTitle: '曲線',
    presets: 'サンプル曲線',
    clearAll: 'すべて消去',
    addCurve: '曲線を追加',
    modeCartesian: '直交座標',
    modePolar: '極座標',
    modeParametric: '媒介変数',
    modeImplicit: '陰関数',
    modeCartesianMenu: '直交座標 y = f(x)',
    modePolarMenu: '極座標 r = f(t)',
    modeParametricMenu: '媒介変数 x(t), y(t)',
    modeImplicitMenu: '陰関数 f(x, y) = 0',
    modeCartesianHint: 'y = f(x)',
    modePolarHint: 'r(t)、t は角度',
    modeParametricHint: 'x(t) と y(t)',
    modeImplicitHint: 'f(x, y) = 0',
    emptyCurves:
        '+ をタップして曲線を追加\n例：sin(x)、x^2/4、1/x\n'
        '陰関数：x^2 + y^2 - 1',
    gestureHint: 'ヒント：ホイール / ピンチで拡大縮小、ドラッグで移動、ホバーか長押しで値を表示',
    latexFailed: '式が不完全なため LaTeX に変換できません',
    latexCopied: 'LaTeX をコピーしました',
    tapToChangeColor: 'タップで色を変更',
    switchMode: '曲線の種類を切り替え',
    hideCurve: '曲線を隠す',
    showCurve: '曲線を表示',
    copyLatex: 'LaTeX をコピー',
    delete: '削除',
    presetAlready: '「{0}」はすでに表示中です',
    presetAdded: 'サンプルを追加：{0}（+{1}）',
    presetIntro:
        'サンプルは現在のキャンバスに追加され、既存の図に合わせて表示範囲が広がります。'
        '同じサンプルを再度読み込んでも重複しません。',
    presetCurveCount: '{0} 本',
    presetSource: '出典：知乎「思わずときめく 7 つのハート関数」\n{0}',
    exportTitle: '画像を書き出す',
    close: '閉じる',
    vectorSize: 'ベクターサイズ',
    imageSize: '画像サイズ',
    vectorSizeValue: '{0} × {1}（無限に拡大可能）',
    rasterSizeValue: '{0}（{1} 倍）',
    viewportLabel: '表示範囲',
    curvesLabel: '曲線',
    saveLocation: '保存先',
    cancel: 'キャンセル',
    download: 'ダウンロード',
    save: '保存',
    saved: '保存しました：{0}',
    openFolder: 'フォルダーを開く',
    exportFailed: '書き出しに失敗：{0}',
    noVisibleCurves: '表示中の曲線はありません',
    saveLocationWeb: 'ブラウザーのダウンロード先',
    saveLocationBrowser: 'ブラウザーの既定のダウンロード先',
    saveLocationAndroid:
        '端末のアルバム「Pictures/free-clac」（SVG は「Download/free-clac」）',
    saveLocationIos: 'アプリのサンドボックス内の一時フォルダー',
    notePng: 'ビットマップ、可逆、互換性が最も高い',
    noteWebp: 'ビットマップ、非可逆、ファイルが小さい',
    noteSvg: 'ベクター、無限に拡大可能、印刷向け',
    traceUndefined: '未定義',
    traceError: '式のエラー',
  ),
  AppLanguage.es: PlotStrings(
    title: 'Gráfica de funciones',
    angleTooltip: 'Unidad de ángulo ({0}); toca para cambiar',
    hideGrid: 'Ocultar cuadrícula',
    showGrid: 'Mostrar cuadrícula',
    traceOff: 'Desactivar el seguimiento táctil',
    traceOn: 'Activar el seguimiento táctil (arrastra para ver valores)',
    exportTooltip: 'Exportar imagen (PNG / SVG / WebP)',
    emptyCanvas:
        'Aún no hay funciones: toca “+” arriba a la derecha para añadir una',
    moveUp: 'Mover la vista arriba (↑)',
    moveDown: 'Mover la vista abajo (↓)',
    moveLeft: 'Mover la vista a la izquierda (←)',
    moveRight: 'Mover la vista a la derecha (→)',
    zoomIn: 'Acercar (+)',
    zoomOut: 'Alejar (-)',
    resetView: 'Restablecer la vista (0)',
    fitVertical: 'Ajustar en vertical',
    showAll: 'Mostrar todo',
    panelTitle: 'Curvas',
    presets: 'Curvas de ejemplo',
    clearAll: 'Borrar todo',
    addCurve: 'Añadir curva',
    modeCartesian: 'Cartesiana',
    modePolar: 'Polar',
    modeParametric: 'Paramétrica',
    modeImplicit: 'Implícita',
    modeCartesianMenu: 'Cartesiana y = f(x)',
    modePolarMenu: 'Polar r = f(t)',
    modeParametricMenu: 'Paramétrica x(t), y(t)',
    modeImplicitMenu: 'Implícita f(x, y) = 0',
    modeCartesianHint: 'y = f(x)',
    modePolarHint: 'r(t), t en grados',
    modeParametricHint: 'x(t) e y(t)',
    modeImplicitHint: 'f(x, y) = 0',
    emptyCurves:
        'Toca + para añadir una curva\np. ej. sin(x), x^2/4, 1/x\n'
        'implícita: x^2 + y^2 - 1',
    gestureHint:
        'Consejo: rueda o pinza para acercar, arrastra para mover, '
        'pasa el cursor o mantén pulsado para ver valores',
    latexFailed: 'La expresión está incompleta; no se puede convertir a LaTeX',
    latexCopied: 'LaTeX copiado',
    tapToChangeColor: 'Toca para cambiar el color',
    switchMode: 'Cambiar el tipo de curva',
    hideCurve: 'Ocultar curva',
    showCurve: 'Mostrar curva',
    copyLatex: 'Copiar LaTeX',
    delete: 'Eliminar',
    presetAlready: '«{0}» ya está en el lienzo',
    presetAdded: 'Ejemplo añadido: {0} (+{1})',
    presetIntro:
        'Los ejemplos se añaden al lienzo y la vista se amplía para encajar. '
        'Cargar dos veces el mismo ejemplo no duplica sus curvas.',
    presetCurveCount: '{0} curvas',
    presetSource:
        'Fuente: Zhihu, «7 funciones con forma de corazón que enamoran»\n{0}',
    exportTitle: 'Exportar imagen',
    close: 'Cerrar',
    vectorSize: 'Tamaño vectorial',
    imageSize: 'Tamaño de imagen',
    vectorSizeValue: '{0} × {1} (se amplía sin límite)',
    rasterSizeValue: '{0} ({1}× de resolución)',
    viewportLabel: 'Vista',
    curvesLabel: 'Curvas',
    saveLocation: 'Se guarda en',
    cancel: 'Cancelar',
    download: 'Descargar',
    save: 'Guardar',
    saved: 'Guardado: {0}',
    openFolder: 'Abrir carpeta',
    exportFailed: 'Error al exportar: {0}',
    noVisibleCurves: 'No hay curvas visibles',
    saveLocationWeb: 'la carpeta de descargas del navegador',
    saveLocationBrowser: 'la carpeta de descargas del navegador',
    saveLocationAndroid:
        'la carpeta de la galería «Pictures/free-clac» (el SVG va a '
        '«Download/free-clac»)',
    saveLocationIos: 'la carpeta temporal del sandbox de la app',
    notePng: 'Mapa de bits, sin pérdida, máxima compatibilidad',
    noteWebp: 'Mapa de bits, con pérdida, archivos más pequeños',
    noteSvg: 'Vectorial, se amplía sin límite, ideal para impresión',
    traceUndefined: 'indefinido',
    traceError: 'error en la expresión',
  ),
};

/// 当前语言的绘图页面文案。
PlotStrings get plotStrings => toolText(kPlotStrings);
