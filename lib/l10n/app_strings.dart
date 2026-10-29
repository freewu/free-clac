import 'app_language.dart';

/// 应用级文案（导航、设置、工具页外壳）。
///
/// 工具自己的文案放在各自目录的 `<tool>_lang.dart` 里，见 `lib/ui/tools/<tool>/`。
abstract class AppStrings {
  const AppStrings();

  /// 当前语言对应的文案表。
  static AppStrings of(AppLanguage language) => switch (language) {
    AppLanguage.zhHans => const _ZhHansStrings(),
    AppLanguage.zhHant => const _ZhHantStrings(),
    AppLanguage.en => const _EnStrings(),
    AppLanguage.ja => const _JaStrings(),
    AppLanguage.es => const _EsStrings(),
  };

  String get appTitle;
  String get navCalculator;
  String get navPlot;
  String get navTools;
  String get navSettings;

  String get toolsTitle;
  String get toolsOffline;

  /// 「12 个应用」这类计数文案，[count] 为工具数量。
  String toolsCount(int count);

  String get settingsTitle;
  String get settingsSubtitle;
  String get settingsAppearance;
  String get themeSystem;
  String get themeLight;
  String get themeDark;
  String get settingsLanguage;
  String get settingsLanguageHint;
  String get settingsBmiUnit;
  String get settingsBmiUnitHint;
  String get settingsCurrency;
  String get settingsCurrencyHint;
  String get currencyFollowLanguage;
  String get unitMetricDetail;
  String get unitImperialDetail;
  String get settingsConversion;
  String get settingsConversionHint;
  String get settingsConvertSystem;
  String get settingsConvertTab;
  String get settingsConvertUnit;
  String get systemMetric;
  String get systemImperial;
  String get systemChinese;
  String get settingsAbout;
  String get aboutDescription;
  String get aboutVersion;
  String get aboutRepo;
  String get aboutRepoAction;
  String get aboutLinkCopied;
  String get settingsFootnote;
}

class _ZhHansStrings extends AppStrings {
  const _ZhHansStrings();

  @override
  String get appTitle => '科学计算器';
  @override
  String get navCalculator => '计算';
  @override
  String get navPlot => '绘图';
  @override
  String get navTools => '工具';
  @override
  String get navSettings => '设置';
  @override
  String get toolsTitle => '工具';
  @override
  String get toolsOffline => '全部内置，离线可用';
  @override
  String toolsCount(int count) => '$count 个应用';
  @override
  String get settingsTitle => '设置';
  @override
  String get settingsSubtitle => '外观与语言，只保存在本机';
  @override
  String get settingsAppearance => '外观';
  @override
  String get themeSystem => '跟随系统';
  @override
  String get themeLight => '浅色';
  @override
  String get themeDark => '深色';
  @override
  String get settingsLanguage => '语言';
  @override
  String get settingsLanguageHint => '界面文案立即切换；工具内部文案正在逐步补齐。';
  @override
  String get settingsBmiUnit => 'BMI 默认单位';
  @override
  String get settingsBmiUnitHint => '打开 BMI 计算时默认用这个单位，页内仍可随时切换。';
  @override
  String get settingsCurrency => '金额符号';
  @override
  String get settingsCurrencyHint =>
      '涉及金额的工具（贷款、复利、利息、养老金、个税）用它显示；选「跟随语言」时随界面语言切换，'
      '也可以固定成人民币、美元、欧元、英镑等具体货币。';
  @override
  String get currencyFollowLanguage => '跟随语言';
  @override
  String get unitMetricDetail => '公制（cm / kg）';
  @override
  String get unitImperialDetail => '英制（ft·in / lb）';
  @override
  String get settingsConversion => '单位换算默认值';
  @override
  String get settingsConversionHint => '六个换算工具各记一套：打开时的计量体系，以及结果默认选中的标签页。';
  @override
  String get settingsConvertSystem => '默认体系';
  @override
  String get settingsConvertUnit => '默认单位';
  @override
  String get settingsConvertTab => '结果 tab';
  @override
  String get systemMetric => '公制';
  @override
  String get systemImperial => '英制';
  @override
  String get systemChinese => '市制';
  @override
  String get settingsAbout => '关于';
  @override
  String get aboutDescription => '表达式求值 + 2D 函数绘图 + 内置小工具，全部离线可用。';
  @override
  String get aboutVersion => '版本';
  @override
  String get aboutRepo => '开源地址';
  @override
  String get aboutRepoAction => '复制链接';
  @override
  String get aboutLinkCopied => '仓库链接已复制';
  @override
  String get settingsFootnote => '设置保存在本机，不会上传。';
}

class _ZhHantStrings extends AppStrings {
  const _ZhHantStrings();

  @override
  String get appTitle => '科學計算機';
  @override
  String get navCalculator => '計算';
  @override
  String get navPlot => '繪圖';
  @override
  String get navTools => '工具';
  @override
  String get navSettings => '設定';
  @override
  String get toolsTitle => '工具';
  @override
  String get toolsOffline => '全部內建，離線可用';
  @override
  String toolsCount(int count) => '$count 個應用';
  @override
  String get settingsTitle => '設定';
  @override
  String get settingsSubtitle => '外觀與語言，只儲存在本機';
  @override
  String get settingsAppearance => '外觀';
  @override
  String get themeSystem => '跟隨系統';
  @override
  String get themeLight => '淺色';
  @override
  String get themeDark => '深色';
  @override
  String get settingsLanguage => '語言';
  @override
  String get settingsLanguageHint => '介面文字立即切換；工具內部文字正在逐步補齊。';
  @override
  String get settingsBmiUnit => 'BMI 預設單位';
  @override
  String get settingsBmiUnitHint => '開啟 BMI 計算時預設用這個單位，頁內仍可隨時切換。';
  @override
  String get settingsCurrency => '金額符號';
  @override
  String get settingsCurrencyHint =>
      '涉及金額的工具（貸款、複利、利息、退休金、所得稅）用它顯示；選「跟隨語言」時隨介面語言切換，'
      '也可以固定成人民幣、美元、歐元、英鎊等具體貨幣。';
  @override
  String get currencyFollowLanguage => '跟隨語言';
  @override
  String get unitMetricDetail => '公制（cm / kg）';
  @override
  String get unitImperialDetail => '英制（ft·in / lb）';
  @override
  String get settingsConversion => '單位換算預設值';
  @override
  String get settingsConversionHint => '六個換算工具各記一套：開啟時的計量體系，以及結果預設選中的分頁。';
  @override
  String get settingsConvertSystem => '預設體系';
  @override
  String get settingsConvertUnit => '預設單位';
  @override
  String get settingsConvertTab => '結果分頁';
  @override
  String get systemMetric => '公制';
  @override
  String get systemImperial => '英制';
  @override
  String get systemChinese => '市制';
  @override
  String get settingsAbout => '關於';
  @override
  String get aboutDescription => '表達式求值 + 2D 函式繪圖 + 內建小工具，全部離線可用。';
  @override
  String get aboutVersion => '版本';
  @override
  String get aboutRepo => '開源位址';
  @override
  String get aboutRepoAction => '複製連結';
  @override
  String get aboutLinkCopied => '已複製倉庫連結';
  @override
  String get settingsFootnote => '設定儲存在本機，不會上傳。';
}

class _EnStrings extends AppStrings {
  const _EnStrings();

  @override
  String get appTitle => 'Scientific Calculator';
  @override
  String get navCalculator => 'Calc';
  @override
  String get navPlot => 'Plot';
  @override
  String get navTools => 'Tools';
  @override
  String get navSettings => 'Settings';
  @override
  String get toolsTitle => 'Tools';
  @override
  String get toolsOffline => 'All built in, works offline';
  @override
  String toolsCount(int count) => '$count apps';
  @override
  String get settingsTitle => 'Settings';
  @override
  String get settingsSubtitle =>
      'Appearance and language, stored on this device';
  @override
  String get settingsAppearance => 'Appearance';
  @override
  String get themeSystem => 'System';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get settingsLanguage => 'Language';
  @override
  String get settingsLanguageHint =>
      'UI text switches immediately; tool contents are being translated.';
  @override
  String get settingsBmiUnit => 'Default BMI units';
  @override
  String get settingsBmiUnitHint =>
      'Used when the BMI calculator opens; you can still switch it there.';
  @override
  String get settingsCurrency => 'Currency symbol';
  @override
  String get settingsCurrencyHint =>
      'Used by money tools (loan, compound, interest, pension, tax). With '
      "'Follow language' it follows the interface language; you can also pin a "
      'specific currency such as yuan, dollar, euro or pound.';
  @override
  String get currencyFollowLanguage => 'Follow language';
  @override
  String get unitMetricDetail => 'Metric (cm / kg)';
  @override
  String get unitImperialDetail => 'Imperial (ft·in / lb)';
  @override
  String get settingsConversion => 'Unit converter defaults';
  @override
  String get settingsConversionHint =>
      'Stored per tool: the unit system it opens with and the result tab it shows first.';
  @override
  String get settingsConvertSystem => 'Default system';
  @override
  String get settingsConvertUnit => 'Default unit';
  @override
  String get settingsConvertTab => 'Result tab';
  @override
  String get systemMetric => 'Metric';
  @override
  String get systemImperial => 'Imperial';
  @override
  String get systemChinese => 'Chinese';
  @override
  String get settingsAbout => 'About';
  @override
  String get aboutDescription =>
      'Expression evaluator, 2D function plotting and built-in tools, all offline.';
  @override
  String get aboutVersion => 'Version';
  @override
  String get aboutRepo => 'Repository';
  @override
  String get aboutRepoAction => 'Copy link';
  @override
  String get aboutLinkCopied => 'Repository link copied';
  @override
  String get settingsFootnote => 'Settings stay on this device.';
}

class _JaStrings extends AppStrings {
  const _JaStrings();

  @override
  String get appTitle => '関数電卓';
  @override
  String get navCalculator => '計算';
  @override
  String get navPlot => 'グラフ';
  @override
  String get navTools => 'ツール';
  @override
  String get navSettings => '設定';
  @override
  String get toolsTitle => 'ツール';
  @override
  String get toolsOffline => 'すべて内蔵、オフラインで動作';
  @override
  String toolsCount(int count) => '$count 個のアプリ';
  @override
  String get settingsTitle => '設定';
  @override
  String get settingsSubtitle => '外観と言語、この端末にのみ保存';
  @override
  String get settingsAppearance => '外観';
  @override
  String get themeSystem => 'システム';
  @override
  String get themeLight => 'ライト';
  @override
  String get themeDark => 'ダーク';
  @override
  String get settingsLanguage => '言語';
  @override
  String get settingsLanguageHint => '画面の文言はすぐに切り替わります。ツール内の文言は順次対応中です。';
  @override
  String get settingsBmiUnit => 'BMI の既定単位';
  @override
  String get settingsBmiUnitHint => 'BMI 計算を開いたときの単位です。画面内でも切り替えられます。';
  @override
  String get settingsCurrency => '金額の記号';
  @override
  String get settingsCurrencyHint =>
      '金額を扱うツール（ローン・複利・利息・年金・所得税）で使います。「言語に合わせる」なら画面の言語に追従し、人民元・米ドル・ユーロ・英ポンドなども選べます。';
  @override
  String get currencyFollowLanguage => '言語に合わせる';
  @override
  String get unitMetricDetail => 'メートル法（cm / kg）';
  @override
  String get unitImperialDetail => 'ヤード・ポンド法（ft·in / lb）';
  @override
  String get settingsConversion => '単位換算の既定値';
  @override
  String get settingsConversionHint => '6 つの換算ツールごとに、開いたときの単位系と結果タブを記憶します。';
  @override
  String get settingsConvertSystem => '既定の単位系';
  @override
  String get settingsConvertUnit => '既定の単位';
  @override
  String get settingsConvertTab => '結果タブ';
  @override
  String get systemMetric => 'メートル法';
  @override
  String get systemImperial => 'ヤード・ポンド法';
  @override
  String get systemChinese => '中国の市制';
  @override
  String get settingsAbout => 'このアプリについて';
  @override
  String get aboutDescription => '数式評価・2D 関数グラフ・内蔵ツール。すべてオフラインで使えます。';
  @override
  String get aboutVersion => 'バージョン';
  @override
  String get aboutRepo => 'リポジトリ';
  @override
  String get aboutRepoAction => 'リンクをコピー';
  @override
  String get aboutLinkCopied => 'リポジトリのリンクをコピーしました';
  @override
  String get settingsFootnote => '設定はこの端末にのみ保存されます。';
}

class _EsStrings extends AppStrings {
  const _EsStrings();

  @override
  String get appTitle => 'Calculadora científica';
  @override
  String get navCalculator => 'Cálculo';
  @override
  String get navPlot => 'Gráfica';
  @override
  String get navTools => 'Herramientas';
  @override
  String get navSettings => 'Ajustes';
  @override
  String get toolsTitle => 'Herramientas';
  @override
  String get toolsOffline => 'Todo integrado, funciona sin conexión';
  @override
  String toolsCount(int count) => '$count aplicaciones';
  @override
  String get settingsTitle => 'Ajustes';
  @override
  String get settingsSubtitle =>
      'Apariencia e idioma, guardados en este dispositivo';
  @override
  String get settingsAppearance => 'Apariencia';
  @override
  String get themeSystem => 'Sistema';
  @override
  String get themeLight => 'Claro';
  @override
  String get themeDark => 'Oscuro';
  @override
  String get settingsLanguage => 'Idioma';
  @override
  String get settingsLanguageHint =>
      'Los textos de la interfaz cambian al instante; el contenido de las herramientas se está traduciendo.';
  @override
  String get settingsBmiUnit => 'Unidades del IMC';
  @override
  String get settingsBmiUnitHint =>
      'Se usa al abrir la calculadora de IMC; dentro puedes cambiarlas.';
  @override
  String get settingsCurrency => 'Símbolo de moneda';
  @override
  String get settingsCurrencyHint =>
      'Lo usan las herramientas de dinero (préstamo, interés compuesto, interés, pensión, IRPF). Con «Seguir el idioma» cambia con la interfaz; también puedes fijar yuan, dólar, euro o libra.';
  @override
  String get currencyFollowLanguage => 'Seguir el idioma';
  @override
  String get unitMetricDetail => 'Métrico (cm / kg)';
  @override
  String get unitImperialDetail => 'Imperial (ft·in / lb)';
  @override
  String get settingsConversion => 'Valores de conversión';
  @override
  String get settingsConversionHint =>
      'Se guarda por herramienta: el sistema con el que abre y la pestaña de resultados.';
  @override
  String get settingsConvertSystem => 'Sistema por defecto';
  @override
  String get settingsConvertUnit => 'Unidad predeterminada';
  @override
  String get settingsConvertTab => 'Pestaña de resultados';
  @override
  String get systemMetric => 'Métrico';
  @override
  String get systemImperial => 'Imperial';
  @override
  String get systemChinese => 'Chino';
  @override
  String get settingsAbout => 'Acerca de';
  @override
  String get aboutDescription =>
      'Evaluador de expresiones, gráficas 2D y herramientas integradas, todo sin conexión.';
  @override
  String get aboutVersion => 'Versión';
  @override
  String get aboutRepo => 'Repositorio';
  @override
  String get aboutRepoAction => 'Copiar enlace';
  @override
  String get aboutLinkCopied => 'Enlace del repositorio copiado';
  @override
  String get settingsFootnote => 'Los ajustes se quedan en este dispositivo.';
}
