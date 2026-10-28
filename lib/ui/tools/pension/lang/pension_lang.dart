import '../../../../l10n/app_language.dart';
import '../../tool_info.dart';

/// 「养老金计算器」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kPensionLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '养老金计算器',
    '现在缴多少，退休领多少',
    '按国发〔2005〕38 号口径测算基础养老金与个人账户养老金，给出替代率与账户构成。',
  ),
  AppLanguage.zhHant: ToolText(
    '養老金計算機',
    '現在繳多少，退休領多少',
    '依國發〔2005〕38 號口徑試算基礎養老金與個人帳戶養老金，給出替代率與帳戶組成。',
  ),
  AppLanguage.en: ToolText(
    'Pension',
    'Pay now, see what you retire on',
    'Estimates the basic and personal-account pension following Guo Fa [2005] No. 38, with replacement rate and account breakdown.',
  ),
  AppLanguage.ja: ToolText(
    '年金計算',
    '今の掛金から受給額を試算',
    '国発〔2005〕38 号に基づき基礎年金と個人勘定年金を試算。代替率と勘定内訳も表示。',
  ),
  AppLanguage.es: ToolText(
    'Pensión',
    'Aporta ahora, cobra al jubilarte',
    'Estima la pensión básica y la de cuenta individual según el documento 国发〔2005〕38, con tasa de sustitución y desglose.',
  ),
};
