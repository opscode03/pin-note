/// 贴记 PinNote · 静态设计变量
///
/// 与 `ui/tokens.css` 一一对应（设计语言规范 V1.0）。
/// 本文件只放【不随主题变化】的变量：字号、间距、圆角、便签 8 色、清单色点。
/// 随主题变化的中性色 / 主色 / 语义色见 `theme.dart` 的 [PinSpec]。
///
/// 约束：业务代码禁止出现魔法数字与魔法色值，一律引用这里的常量或 [PinSpec]。
library;

import 'package:flutter/material.dart';

/// 字号阶梯（桌面密度，对应 --text-*）
abstract final class PinFontSize {
  static const double xs2 = 11;
  static const double xs = 12;
  static const double sm = 13;
  static const double md = 14;
  static const double lg = 16;
  static const double xl = 18;
  static const double xxl = 22;
}

/// 间距（4 / 8 的倍数，对应 --space-*）
abstract final class PinSpace {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 24;
  static const double s6 = 32;
  static const double s7 = 48;
}

/// 圆角（对应 --radius-*）
abstract final class PinRadius {
  static const double sm = 8; // 控件
  static const double md = 10; // 卡片、便签
  static const double lg = 14; // 窗口、浮层
  static const double full = 999;
}

/// 布局尺寸（对应 app.css 中的骨架尺寸）
abstract final class PinSize {
  static const double titlebar = 44;
  static const double sidebar = 220;
  static const double detail = 340;
  static const double navItem = 32;
  static const double button = 32;
  static const double buttonLg = 42;
  static const double buttonXl = 46;
  static const double iconButton = 30;
  static const double taskbar = 48; // Windows 任务栏（场景页）
  static const double windowButtonZone = 146; // 右上留给窗口按钮的区域
  static const double windowMinWidth = 980;
  static const double windowMinHeight = 640;
  static const double windowDefaultWidth = 1440;
  static const double windowDefaultHeight = 900;
}

/// 动效（对应 --ease / --dur）
abstract final class PinMotion {
  static const Duration dur = Duration(milliseconds: 180);
  static const Curve ease = Cubic(0.2, 0.8, 0.2, 1);
}

/// 字体族（对应 --font-sans / --font-mono）
abstract final class PinFont {
  /// sans 主链。
  /// web 端前面放 Roboto / Noto Sans SC（CanvasKit 会从 gstatic 自动加载，
  /// 缺了会触发后备字形占位线）；桌面端自动跳到 Segoe UI / PingFang SC。
  static const List<String> sans = [
    'Roboto',
    'Noto Sans SC',
    'Segoe UI Variable',
    'Segoe UI',
    'Microsoft YaHei UI',
    'PingFang SC',
  ];
  static const List<String> mono = [
    'Cascadia Mono',
    'Consolas',
    'Menlo',
    'monospace',
  ];
}

/// 便签 8 色（data-color，主题无关）
enum StickyColor { lemon, apricot, cherry, mint, sky, lavender, paper, night }

/// 单个便签色的完整方案：bg 底 / line 描边 / ink 一级字 / ink2 二级字 / fold 折角
@immutable
class StickyScheme {
  const StickyScheme({
    required this.bg,
    required this.line,
    required this.ink,
    required this.ink2,
    required this.fold,
  });

  final Color bg;
  final Color line;
  final Color ink;
  final Color ink2;
  final Color fold;
}

/// 便签 8 色（对应 --sticky-*-*，顺序与设计语言规范板一致）
const Map<StickyColor, StickyScheme> kStickySchemes = {
  StickyColor.lemon: StickyScheme(
    bg: Color(0xFFFFE994),
    line: Color(0xFFECCE60),
    ink: Color(0xFF574414),
    ink2: Color(0xFF705D28),
    fold: Color(0xFFEBD886),
  ),
  StickyColor.apricot: StickyScheme(
    bg: Color(0xFFFFD8B2),
    line: Color(0xFFEEBE8C),
    ink: Color(0xFF6E421C),
    ink2: Color(0xFF84562B),
    fold: Color(0xFFF2C79C),
  ),
  StickyColor.cherry: StickyScheme(
    bg: Color(0xFFFFD1DC),
    line: Color(0xFFEEA8BA),
    ink: Color(0xFF7A2A44),
    ink2: Color(0xFF8E4357),
    fold: Color(0xFFF5BCCB),
  ),
  StickyColor.mint: StickyScheme(
    bg: Color(0xFFC9F0D6),
    line: Color(0xFF9AD6B2),
    ink: Color(0xFF145C38),
    ink2: Color(0xFF2E7049),
    fold: Color(0xFFB5E4C6),
  ),
  StickyColor.sky: StickyScheme(
    bg: Color(0xFFC6E4FF),
    line: Color(0xFF9AC4F0),
    ink: Color(0xFF184E96),
    ink2: Color(0xFF3264A2),
    fold: Color(0xFFB2D9F9),
  ),
  StickyColor.lavender: StickyScheme(
    bg: Color(0xFFDDD4FF),
    line: Color(0xFFBAAEF2),
    ink: Color(0xFF4E36A8),
    ink2: Color(0xFF5B46AE),
    fold: Color(0xFFCEC2F7),
  ),
  StickyColor.paper: StickyScheme(
    bg: Color(0xFFF2F2F5),
    line: Color(0xFFD8D9E0),
    ink: Color(0xFF383A42),
    ink2: Color(0xFF4E4F56),
    fold: Color(0xFFE4E4E9),
  ),
  StickyColor.night: StickyScheme(
    bg: Color(0xFF383942),
    line: Color(0xFF505260),
    ink: Color(0xFFECECF2),
    ink2: Color(0xFFCECFD6),
    fold: Color(0xFF2E2F37),
  ),
};

/// 清单色点（对应 --dot-*）
abstract final class PinListDots {
  static const Color inbox = Color(0xFF4A7DFF);
  static const Color work = Color(0xFF7C5CFF);
  static const Color life = Color(0xFF22C55E);
  static const Color study = Color(0xFFF09917);
  static const Color read = Color(0xFFDB4A94);
}

/// 图钉与胶带（对应 --tack-red / --tape）
abstract final class PinDecor {
  static const Color tackRed = Color(0xFFDB4C4C);
  static const Color tape = Color(0x73FFFFFF); // rgba(255,255,255,.45)
}

/// 桌面场景壁纸（对应 .wp-a ~ .wp-d：径向光斑 + 底色渐变）
@immutable
class WallpaperSpec {
  const WallpaperSpec({required this.base, required this.glow});

  /// 底部线性渐变（top → bottom）
  final List<Color> base;

  /// (圆心 x, 圆心 y, 半径, 颜色, 渐隐 stop)
  final List<(double, double, double, Color, double)> glow;
}

const Map<String, WallpaperSpec> kWallpapers = {
  'a': WallpaperSpec(
    base: [Color(0xFF0E1832), Color(0xFF1C385C)],
    glow: [
      (0.74, 0.16, 560, Color(0x802696AA), 0.70), // rgba(38,150,170,.50)
      (0.10, 0.88, 620, Color(0x756846BE), 0.72), // rgba(104,70,190,.46)
      (0.38, 0.42, 660, Color(0x6B285ADC), 0.75), // rgba(40,90,220,.42)
    ],
  ),
  'b': WallpaperSpec(
    base: [Color(0xFF0C162E), Color(0xFF1A3458)],
    glow: [
      (0.18, 0.20, 560, Color(0x752878B4), 0.70), // rgba(40,120,180,.46)
      (0.86, 0.76, 550, Color(0x61965AC8), 0.72), // rgba(150,90,200,.38)
      (0.58, 0.12, 460, Color(0x5C3CA096), 0.72), // rgba(60,160,150,.36)
    ],
  ),
  'c': WallpaperSpec(
    base: [Color(0xFF0A122A), Color(0xFF183050)],
    glow: [
      (0.50, 0.28, 600, Color(0x75325ADC), 0.72), // rgba(50,90,220,.46)
      (0.12, 0.82, 500, Color(0x6B5A3CB4), 0.72), // rgba(90,60,180,.42)
      (0.86, 0.18, 460, Color(0x61288CA0), 0.70), // rgba(40,140,160,.38)
    ],
  ),
  'd': WallpaperSpec(
    base: [Color(0xFF0C142C), Color(0xFF1A3256)],
    glow: [
      (0.14, 0.22, 490, Color(0x757846BE), 0.70), // rgba(120,70,190,.46)
      (0.82, 0.68, 530, Color(0x752878BE), 0.72), // rgba(40,120,190,.46)
      (0.44, 0.55, 430, Color(0x523C9652), 0.72), // rgba(60,150,140,.32)
    ],
  ),
};

/// 任务栏上的应用块配色（桌面场景 demo 用）
const List<(Color, String)> kTaskbarApps = [
  (Color(0xFF4C72E5), 'folder'),
  (Color(0xFFE8943A), 'note'),
  (Color(0xFF40A87A), 'check'),
  (Color(0xFFB060C6), 'image'),
  (Color(0xFF589EE4), 'person'),
  (Color(0xFF7A8494), 'gear'),
];
