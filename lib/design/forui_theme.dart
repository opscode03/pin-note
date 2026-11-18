/// 贴记 PinNote · forui 主题适配层
///
/// 将 PinSpec 设计变量映射为 forui 的 [FThemeData]：
/// forui 组件（FButton/FCheckbox/FSwitch/FProgress 等）由此获得
/// 与设计语言 V1.0 一致的配色，新增页面可直接组合 forui 组件。
///
/// 映射约定：
/// - primary       → 主色（今日主按钮/选中态）
/// - background    → 内容区背景 --color-bg
/// - foreground    → 一级文本 --color-text
/// - secondary     → 输入/分组底 --color-surface-3
/// - muted         → 同 secondary（shadcn 语义）
/// - mutedForeground → 二级文本 --color-text-2
/// - destructive   → 危险 --color-danger
/// - card          → 卡片面 --color-surface
/// - border        → 描边 --color-line
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';

import 'theme.dart';

/// 由 PinSpec 构建 forui 浅/深色主题
FThemeData buildForuiTheme(PinSpec spec) {
  final colors = FColors(
    brightness: spec.brightness,
    systemOverlayStyle:
        spec.brightness == Brightness.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
    barrier: const Color(0x33000000),
    background: spec.bg,
    foreground: spec.text,
    primary: spec.primary,
    primaryForeground: Colors.white,
    secondary: spec.surface3,
    secondaryForeground: spec.text,
    muted: spec.surface3,
    mutedForeground: spec.text2,
    destructive: spec.danger,
    destructiveForeground: Colors.white,
    error: spec.danger,
    errorForeground: Colors.white,
    card: spec.surface,
    border: spec.line,
  );
  return FThemeData(colors: colors, touch: false);
}

/// 由 PinSpec 构建 forui 桌面主题（别名，语义明确）
FThemeData buildForuiDesktopTheme(PinSpec spec) => buildForuiTheme(spec);
