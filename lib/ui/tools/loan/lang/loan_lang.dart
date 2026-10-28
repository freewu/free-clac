import '../../../../l10n/app_language.dart';
import '../../tool_info.dart';

/// 「贷款计算器」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kLoanLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '贷款计算器',
    '月供本金利息一眼拆开',
    '等额本息 / 等额本金，逐期列出本金与利息并用双色条对比，还给出总利息与总还款。',
  ),
  AppLanguage.zhHant: ToolText(
    '貸款計算機',
    '月付本金利息一眼拆開',
    '等額本息 / 等額本金，逐期列出本金與利息並用雙色條對比，還給出總利息與總還款。',
  ),
  AppLanguage.en: ToolText(
    'Loan',
    'Split each payment into principal and interest',
    'Equal payment or equal principal; per-period principal and interest bars, plus total interest and repayment.',
  ),
  AppLanguage.ja: ToolText(
    'ローン計算',
    '毎月の返済を元金と利息に分解',
    '元利均等・元金均等に対応。各回の元金と利息を色分け表示し、総利息と総返済額も算出。',
  ),
  AppLanguage.es: ToolText(
    'Préstamo',
    'Separa capital e intereses de cada cuota',
    'Cuota fija o capital constante; barras de capital e interés por periodo, con interés y pago totales.',
  ),
};
