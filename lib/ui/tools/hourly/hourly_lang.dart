import '../../../l10n/app_language.dart';
import '../tool_info.dart';

/// 「时薪计算器」卡片的多语言文案：名称、卖点、说明。
const Map<AppLanguage, ToolText> kHourlyLang = <AppLanguage, ToolText>{
  AppLanguage.zhHans: ToolText(
    '时薪计算器',
    '看看自己一小时值多少钱',
    '按月薪和工作日制度（21.75 天、大小周、996）折算时薪，结果可存进历史对比。',
  ),
  AppLanguage.zhHant: ToolText(
    '時薪計算器',
    '看看自己一小時值多少錢',
    '按月薪與工作日制度（21.75 天、大小週、996）換算時薪，結果可存進歷史對比。',
  ),
  AppLanguage.en: ToolText(
    'Hourly wage',
    'What is your hour worth',
    'Turn a monthly salary into an hourly wage for 21.75-day, alternating-week '
        'and 996 schedules, and keep results to compare.',
  ),
  AppLanguage.ja: ToolText(
    '時給計算',
    '自分の 1 時間の値打ち',
    '月給を勤務体系（月 21.75 日・隔週休 2 日・996）ごとの時給に換算し、履歴と比べられます。',
  ),
  AppLanguage.es: ToolText(
    'Salario por hora',
    'Cuánto vale tu hora',
    'Convierte el sueldo mensual en salario por hora para jornadas de 21,75 '
        'días, semanas alternas y 996, y guarda resultados para comparar.',
  ),
};
