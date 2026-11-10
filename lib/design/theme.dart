/// 贴记 PinNote · 主题（浅色 / 深色）
///
/// [PinSpec] 是 ThemeExtension，承载 `ui/tokens.css` 中所有随主题变化的变量。
/// 业务代码通过 `context.pin` 取用，禁止直接写死色值。
library;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// 便捷读取：`context.pin.text2`
extension PinSpecContext on BuildContext {
  PinSpec get pin => Theme.of(this).extension<PinSpec>()!;

  /// 图标“挖底”色（layers 前层方块等），默认取面板底色。
  Color surfaceColorOf() => pin.surface;
}

/// 随主题变化的设计变量（对应 tokens.css :root 与 [data-theme="dark"]）
@immutable
class PinSpec extends ThemeExtension<PinSpec> {
  const PinSpec({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.text,
    required this.text2,
    required this.faint,
    required this.line,
    required this.lineStrong,
    required this.hover,
    required this.primary,
    required this.primaryStrong,
    required this.primaryTint,
    required this.selBg,
    required this.selText,
    required this.success,
    required this.successStrong,
    required this.successTint,
    required this.warning,
    required this.warningStrong,
    required this.warningTint,
    required this.danger,
    required this.dangerStrong,
    required this.dangerTint,
    required this.violet,
    required this.violetStrong,
    required this.violetTint,
    required this.teal,
    required this.tealStrong,
    required this.tealTint,
    required this.pink,
    required this.pinkStrong,
    required this.pinkTint,
    required this.shadowSm,
    required this.shadowFar,
    required this.shadowLift,
  });

  final Brightness brightness;

  // ---- 中性色（按角色） ----
  final Color bg; // 内容区背景
  final Color surface; // 卡片、弹层、侧栏上的面板
  final Color surface2; // 侧栏
  final Color surface3; // 分组底、输入底
  final Color text; // 一级文本
  final Color text2; // 二级文本
  final Color faint; // 三级文本 / 占位
  final Color line; // 边框、分割线
  final Color lineStrong; // 描边按钮、输入框描边
  final Color hover; // 悬停底

  // ---- 主色 ----
  final Color primary;
  final Color primaryStrong;
  final Color primaryTint;
  final Color selBg; // 选中行底
  final Color selText; // 选中行文字

  // ---- 语义色（strong = 文字用，tint = 底色用） ----
  final Color success;
  final Color successStrong;
  final Color successTint;
  final Color warning;
  final Color warningStrong;
  final Color warningTint;
  final Color danger;
  final Color dangerStrong;
  final Color dangerTint;
  final Color violet;
  final Color violetStrong;
  final Color violetTint;
  final Color teal;
  final Color tealStrong;
  final Color tealTint;
  final Color pink;
  final Color pinkStrong;
  final Color pinkTint;

  // ---- 阴影（对应 --shadow-*） ----
  final List<BoxShadow> shadowSm;
  final List<BoxShadow> shadowFar;
  final List<BoxShadow> shadowLift;

  // ---- 字号阶梯（颜色随主题，字号不变） ----
  TextStyle get t2xs => TextStyle(
    fontSize: PinFontSize.xs2,
    color: text,
    fontFamilyFallback: PinFont.sans,
  );
  TextStyle get txs => TextStyle(
    fontSize: PinFontSize.xs,
    color: text,
    fontFamilyFallback: PinFont.sans,
  );
  TextStyle get tsm => TextStyle(
    fontSize: PinFontSize.sm,
    color: text,
    fontFamilyFallback: PinFont.sans,
  );
  TextStyle get tmd => TextStyle(
    fontSize: PinFontSize.md,
    color: text,
    fontFamilyFallback: PinFont.sans,
  );
  TextStyle get tlg => TextStyle(
    fontSize: PinFontSize.lg,
    color: text,
    fontFamilyFallback: PinFont.sans,
  );
  TextStyle get txl => TextStyle(
    fontSize: PinFontSize.xl,
    color: text,
    fontFamilyFallback: PinFont.sans,
  );
  TextStyle get t2xl => TextStyle(
    fontSize: PinFontSize.xxl,
    color: text,
    fontFamilyFallback: PinFont.sans,
  );

  /// 等宽小字（色值标注等）
  TextStyle mono(double size, Color color) =>
      TextStyle(fontSize: size, color: color, fontFamilyFallback: PinFont.mono);

  @override
  PinSpec copyWith({Brightness? brightness}) {
    return brightness == null || brightness == this.brightness
        ? this
        : (brightness == Brightness.light ? pinSpecLight : pinSpecDark);
  }

  @override
  PinSpec lerp(PinSpec? other, double t) {
    if (other == null || other.runtimeType != runtimeType) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return PinSpec(
      brightness: t < 0.5 ? brightness : other.brightness,
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      surface2: mix(surface2, other.surface2),
      surface3: mix(surface3, other.surface3),
      text: mix(text, other.text),
      text2: mix(text2, other.text2),
      faint: mix(faint, other.faint),
      line: mix(line, other.line),
      lineStrong: mix(lineStrong, other.lineStrong),
      hover: mix(hover, other.hover),
      primary: mix(primary, other.primary),
      primaryStrong: mix(primaryStrong, other.primaryStrong),
      primaryTint: mix(primaryTint, other.primaryTint),
      selBg: mix(selBg, other.selBg),
      selText: mix(selText, other.selText),
      success: mix(success, other.success),
      successStrong: mix(successStrong, other.successStrong),
      successTint: mix(successTint, other.successTint),
      warning: mix(warning, other.warning),
      warningStrong: mix(warningStrong, other.warningStrong),
      warningTint: mix(warningTint, other.warningTint),
      danger: mix(danger, other.danger),
      dangerStrong: mix(dangerStrong, other.dangerStrong),
      dangerTint: mix(dangerTint, other.dangerTint),
      violet: mix(violet, other.violet),
      violetStrong: mix(violetStrong, other.violetStrong),
      violetTint: mix(violetTint, other.violetTint),
      teal: mix(teal, other.teal),
      tealStrong: mix(tealStrong, other.tealStrong),
      tealTint: mix(tealTint, other.tealTint),
      pink: mix(pink, other.pink),
      pinkStrong: mix(pinkStrong, other.pinkStrong),
      pinkTint: mix(pinkTint, other.pinkTint),
      shadowSm: BoxShadow.lerpList(shadowSm, other.shadowSm, t)!,
      shadowFar: BoxShadow.lerpList(shadowFar, other.shadowFar, t)!,
      shadowLift: BoxShadow.lerpList(shadowLift, other.shadowLift, t)!,
    );
  }
}

/// 浅色主题（对应 tokens.css :root）
PinSpec pinSpecLight = const PinSpec(
  brightness: Brightness.light,
  bg: Color(0xFFF5F6F8),
  surface: Color(0xFFFFFFFF),
  surface2: Color(0xFFFAFBFC),
  surface3: Color(0xFFF4F5F7),
  text: Color(0xFF1F2329),
  text2: Color(0xFF5A6270),
  faint: Color(0xFF676F7A),
  line: Color(0xFFE4E7EC),
  lineStrong: Color(0xFFD6DAE2),
  hover: Color(0xFFF2F4F7),
  primary: Color(0xFF3867E0),
  primaryStrong: Color(0xFF2C52C8),
  primaryTint: Color(0xFFE8EEFF),
  selBg: Color(0xFFEBF1FF),
  selText: Color(0xFF3863DB),
  success: Color(0xFF22C55E),
  successStrong: Color(0xFF0E7A3C),
  successTint: Color(0xFFE2F8ED),
  warning: Color(0xFFF09917),
  warningStrong: Color(0xFF93590A),
  warningTint: Color(0xFFFDF2E0),
  danger: Color(0xFFEB5757),
  dangerStrong: Color(0xFFB32E2E),
  dangerTint: Color(0xFFFEEAEA),
  violet: Color(0xFF7C5CFF),
  violetStrong: Color(0xFF5F42D6),
  violetTint: Color(0xFFEFEAFF),
  teal: Color(0xFF0DAA9E),
  tealStrong: Color(0xFF08716A),
  tealTint: Color(0xFFE0F7F5),
  pink: Color(0xFFDB4A94),
  pinkStrong: Color(0xFFC83482),
  pinkTint: Color(0xFFFCEAF3),
  shadowSm: [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color(0x140F172A), // rgba(15,23,42,.08)
    ),
  ],
  shadowFar: [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 32,
      color: Color(0x290F172A), // rgba(15,23,42,.16)
    ),
  ],
  shadowLift: [
    BoxShadow(
      offset: Offset(0, 20),
      blurRadius: 48,
      color: Color(0x4D080E1C), // rgba(8,14,28,.30)
    ),
  ],
);

/// 深色主题（对应 tokens.css [data-theme="dark"]）
PinSpec pinSpecDark = const PinSpec(
  brightness: Brightness.dark,
  bg: Color(0xFF1E1F27),
  surface: Color(0xFF262832),
  surface2: Color(0xFF191A20),
  surface3: Color(0xFF2F313C),
  text: Color(0xFFE9EAEE),
  text2: Color(0xFFA2A8B4),
  faint: Color(0xFF989DA8),
  line: Color(0xFF2F313A),
  lineStrong: Color(0xFF3B3E4A),
  hover: Color(0xFF282A34),
  primary: Color(0xFF3867E0),
  primaryStrong: Color(0xFF8AA8FF),
  primaryTint: Color(0xFF2F3756),
  selBg: Color(0xFF2F354C),
  selText: Color(0xFF9EB7FF),
  success: Color(0xFF6CDCA4),
  successStrong: Color(0xFF6CDCA4),
  successTint: Color(0xFF1E3C2E),
  warning: Color(0xFFF7BE66),
  warningStrong: Color(0xFFF7BE66),
  warningTint: Color(0xFF46361C),
  danger: Color(0xFFFF8A80),
  dangerStrong: Color(0xFFFF8A80),
  dangerTint: Color(0xFF4C2A2C),
  violet: Color(0xFFBAA6FF),
  violetStrong: Color(0xFFBAA6FF),
  violetTint: Color(0xFF362E52),
  teal: Color(0xFF6CD6CA),
  tealStrong: Color(0xFF6CD6CA),
  tealTint: Color(0xFF1A3A37),
  pink: Color(0xFFFF98C4),
  pinkStrong: Color(0xFFFF98C4),
  pinkTint: Color(0xFF462636),
  shadowSm: [
    BoxShadow(
      offset: Offset(0, 2),
      blurRadius: 8,
      color: Color(0x4D000000), // rgba(0,0,0,.30)
    ),
  ],
  shadowFar: [
    BoxShadow(
      offset: Offset(0, 12),
      blurRadius: 32,
      color: Color(0x6B000000), // rgba(0,0,0,.42)
    ),
  ],
  shadowLift: [
    BoxShadow(offset: Offset(0, 20), blurRadius: 48, color: Color(0x4D080E1C)),
  ],
);

/// 由 PinSpec 构建 MaterialApp 用的 ThemeData
ThemeData buildPinTheme(PinSpec spec) {
  final colorScheme = ColorScheme(
    brightness: spec.brightness,
    primary: spec.primary,
    onPrimary: Colors.white,
    secondary: spec.violet,
    onSecondary: Colors.white,
    surface: spec.bg,
    onSurface: spec.text,
    error: spec.danger,
    onError: Colors.white,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: spec.bg,
    splashFactory: NoSplash.splashFactory,
    fontFamilyFallback: PinFont.sans,
    textTheme: TextTheme(
      bodySmall: spec.tsm,
      bodyMedium: spec.tsm,
      bodyLarge: spec.tmd,
    ),
    dividerColor: spec.line,
    visualDensity: VisualDensity.standard,
    extensions: <ThemeExtension<dynamic>>[spec],
  );
}
