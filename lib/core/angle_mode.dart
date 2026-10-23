/// 角度模式：三角函数与反三角函数按此模式解释输入 / 输出。
enum AngleMode {
  degrees('角度', 'DEG', '°'),
  radians('弧度', 'RAD', 'rad');

  const AngleMode(this.label, this.shortLabel, this.suffix);

  final String label;
  final String shortLabel;
  final String suffix;

  double toRadians(double value) =>
      this == AngleMode.degrees ? value * 3.1415926535897932 / 180.0 : value;

  double fromRadians(double value) =>
      this == AngleMode.degrees ? value * 180.0 / 3.1415926535897932 : value;

  AngleMode get toggled =>
      this == AngleMode.degrees ? AngleMode.radians : AngleMode.degrees;
}
