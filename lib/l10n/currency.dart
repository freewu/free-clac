import 'app_language.dart';

/// 一种货币：ISO 代码、符号与各语言名称。
///
/// 符号本身是跨语言通用的（£ 永远是 £），只有名称需要翻译，所以名称放
/// 数据层自己身上，`nameIn()` 取不到时回落英文，再回落代码。
class CurrencyInfo {
  const CurrencyInfo(this.code, this.symbol, this.names);

  /// ISO 4217 代码，小写；`auto` 是「跟随语言」的伪代码。
  final String code;

  /// 金额符号，如 `¥`、`£`。
  final String symbol;

  /// 各语言的名称，如「人民币」「Pound sterling」。
  final Map<AppLanguage, String> names;

  String nameIn(AppLanguage language) =>
      names[language] ?? names[AppLanguage.en] ?? code.toUpperCase();
}

/// 「跟随语言」的伪代码。
const String kFollowLanguageCurrency = 'auto';

/// 可选货币表。第一项是通用占位符 ¤，用于「不想写具体货币」的场景。
const List<CurrencyInfo> kCurrencies = <CurrencyInfo>[
  CurrencyInfo('xxx', '¤', {
    AppLanguage.zhHans: '通用货币符号',
    AppLanguage.zhHant: '通用貨幣符號',
    AppLanguage.en: 'Generic currency sign',
    AppLanguage.ja: '汎用通貨記号',
    AppLanguage.es: 'Signo de moneda genérico',
  }),
  CurrencyInfo('cny', '¥', {
    AppLanguage.zhHans: '人民币',
    AppLanguage.zhHant: '人民幣',
    AppLanguage.en: 'Chinese yuan',
    AppLanguage.ja: '人民元',
    AppLanguage.es: 'Yuan chino',
  }),
  CurrencyInfo('usd', r'$', {
    AppLanguage.zhHans: '美元',
    AppLanguage.zhHant: '美元',
    AppLanguage.en: 'US dollar',
    AppLanguage.ja: '米ドル',
    AppLanguage.es: 'Dólar estadounidense',
  }),
  CurrencyInfo('eur', '€', {
    AppLanguage.zhHans: '欧元',
    AppLanguage.zhHant: '歐元',
    AppLanguage.en: 'Euro',
    AppLanguage.ja: 'ユーロ',
    AppLanguage.es: 'Euro',
  }),
  CurrencyInfo('jpy', '￥', {
    AppLanguage.zhHans: '日元',
    AppLanguage.zhHant: '日圓',
    AppLanguage.en: 'Japanese yen',
    AppLanguage.ja: '日本円',
    AppLanguage.es: 'Yen japonés',
  }),
  CurrencyInfo('gbp', '£', {
    AppLanguage.zhHans: '英镑',
    AppLanguage.zhHant: '英鎊',
    AppLanguage.en: 'Pound sterling',
    AppLanguage.ja: '英ポンド',
    AppLanguage.es: 'Libra esterlina',
  }),
  CurrencyInfo('inr', '₹', {
    AppLanguage.zhHans: '印度卢比',
    AppLanguage.zhHant: '印度盧比',
    AppLanguage.en: 'Indian rupee',
    AppLanguage.ja: 'インドルピー',
    AppLanguage.es: 'Rupia india',
  }),
  CurrencyInfo('rub', '₽', {
    AppLanguage.zhHans: '俄罗斯卢布',
    AppLanguage.zhHant: '俄羅斯盧布',
    AppLanguage.en: 'Russian ruble',
    AppLanguage.ja: 'ロシアルーブル',
    AppLanguage.es: 'Rublo ruso',
  }),
  CurrencyInfo('krw', '₩', {
    AppLanguage.zhHans: '韩元',
    AppLanguage.zhHant: '韓元',
    AppLanguage.en: 'South Korean won',
    AppLanguage.ja: '韓国ウォン',
    AppLanguage.es: 'Won surcoreano',
  }),
  CurrencyInfo('try', '₺', {
    AppLanguage.zhHans: '土耳其里拉',
    AppLanguage.zhHant: '土耳其里拉',
    AppLanguage.en: 'Turkish lira',
    AppLanguage.ja: 'トルコリラ',
    AppLanguage.es: 'Lira turca',
  }),
  CurrencyInfo('uah', '₴', {
    AppLanguage.zhHans: '乌克兰格里夫纳',
    AppLanguage.zhHant: '烏克蘭格里夫納',
    AppLanguage.en: 'Ukrainian hryvnia',
    AppLanguage.ja: 'ウクライナ・フリヴニャ',
    AppLanguage.es: 'Grivna ucraniana',
  }),
  CurrencyInfo('php', '₱', {
    AppLanguage.zhHans: '菲律宾比索',
    AppLanguage.zhHant: '菲律賓披索',
    AppLanguage.en: 'Philippine peso',
    AppLanguage.ja: 'フィリピンペソ',
    AppLanguage.es: 'Peso filipino',
  }),
  CurrencyInfo('ngn', '₦', {
    AppLanguage.zhHans: '尼日利亚奈拉',
    AppLanguage.zhHant: '奈及利亞奈拉',
    AppLanguage.en: 'Nigerian naira',
    AppLanguage.ja: 'ナイジェリアナイラ',
    AppLanguage.es: 'Naira nigeriana',
  }),
  CurrencyInfo('vnd', '₫', {
    AppLanguage.zhHans: '越南盾',
    AppLanguage.zhHant: '越南盾',
    AppLanguage.en: 'Vietnamese dong',
    AppLanguage.ja: 'ベトナムドン',
    AppLanguage.es: 'Dong vietnamita',
  }),
  CurrencyInfo('lak', '₭', {
    AppLanguage.zhHans: '老挝基普',
    AppLanguage.zhHant: '寮國基普',
    AppLanguage.en: 'Lao kip',
    AppLanguage.ja: 'ラオスキープ',
    AppLanguage.es: 'Kip laosiano',
  }),
  CurrencyInfo('mnt', '₮', {
    AppLanguage.zhHans: '蒙古图格里克',
    AppLanguage.zhHant: '蒙古圖格里克',
    AppLanguage.en: 'Mongolian tögrög',
    AppLanguage.ja: 'モンゴル・トゥグルグ',
    AppLanguage.es: 'Tugrik mongol',
  }),
  CurrencyInfo('azn', '₼', {
    AppLanguage.zhHans: '阿塞拜疆马纳特',
    AppLanguage.zhHant: '亞塞拜然馬納特',
    AppLanguage.en: 'Azerbaijani manat',
    AppLanguage.ja: 'アゼルバイジャン・マナト',
    AppLanguage.es: 'Manat azerbaiyano',
  }),
];

/// 按代码查货币，找不到返回 null。
CurrencyInfo? currencyByCode(String? code) {
  if (code == null) return null;
  for (final currency in kCurrencies) {
    if (currency.code == code) return currency;
  }
  return null;
}

/// 「跟随语言」时各语言的默认金额符号。
///
/// 简中用人民币符号、繁中与英语用美元、日语用全角日元、西语用欧元。
const Map<AppLanguage, String> kLanguageCurrencySymbols = <AppLanguage, String>{
  AppLanguage.zhHans: '¥',
  AppLanguage.zhHant: r'$',
  AppLanguage.en: r'$',
  AppLanguage.ja: '￥',
  AppLanguage.es: '€',
};

/// 按偏好代码与语言得出要显示的金额符号。
///
/// [code] 为 [kFollowLanguageCurrency] 或无法识别时跟语言走，否则用该货币的符号。
String currencySymbolFor(String code, AppLanguage language) {
  final currency = currencyByCode(code);
  if (currency != null) return currency.symbol;
  return kLanguageCurrencySymbols[language] ?? '¥';
}
