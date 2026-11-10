/// 贴记 PinNote · Chip / kbd / flag（对应 app.css .chip / kbd / .flag）
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';

/// Chip 语义色（对应 .chip-accent / .chip-red / ...）
enum PinChipStyle { accent, red, amber, green, violet, teal, neutral }

/// Chip 尺寸（默认 22 高 / .chip-lg 26 高）
enum PinChipSize { md, lg }

/// 元信息胶囊
class PinChip extends StatelessWidget {
  const PinChip(
    this.label, {
    super.key,
    this.style = PinChipStyle.neutral,
    this.size = PinChipSize.md,
    this.icon,
    this.trailingIcon,
    this.bold = false,
    this.onTap,
  });

  final String label;
  final PinChipStyle style;
  final PinChipSize size;
  final PinIconData? icon;
  final PinIconData? trailingIcon;
  final bool bold;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final Color bg;
    final Color fg;
    switch (style) {
      case PinChipStyle.accent:
        bg = spec.primaryTint;
        fg = spec.primaryStrong;
      case PinChipStyle.red:
        bg = spec.dangerTint;
        fg = spec.dangerStrong;
      case PinChipStyle.amber:
        bg = spec.warningTint;
        fg = spec.warningStrong;
      case PinChipStyle.green:
        bg = spec.successTint;
        fg = spec.successStrong;
      case PinChipStyle.violet:
        bg = spec.violetTint;
        fg = spec.violetStrong;
      case PinChipStyle.teal:
        bg = spec.tealTint;
        fg = spec.tealStrong;
      case PinChipStyle.neutral:
        bg = spec.surface3;
        fg = spec.text2;
    }

    final double height;
    final double fontSize;
    final double hPadding;
    final double iconSize;
    switch (size) {
      case PinChipSize.md:
        height = 22;
        fontSize = PinFontSize.xs2;
        hPadding = 8;
        iconSize = 11;
      case PinChipSize.lg:
        height = 26;
        fontSize = PinFontSize.xs;
        hPadding = 10;
        iconSize = 13;
    }

    return MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(PinRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                PinIcon(icon!, size: iconSize, color: fg),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 5),
                PinIcon(trailingIcon!, size: iconSize, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 快捷键提示（对应 kbd）
class PinKbd extends StatelessWidget {
  const PinKbd(this.keys, {super.key});

  final List<String> keys;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          // HTML: border 1px + border-bottom 2px；用双层容器模拟（Flutter 不支持
          // 非均匀边框 + 圆角）：外层 1px 描边色打底、下边 2px，内层为键帽面
          Container(
            padding: const EdgeInsets.fromLTRB(1, 1, 1, 2),
            decoration: BoxDecoration(
              color: spec.lineStrong,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              constraints: const BoxConstraints(minWidth: 17),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: spec.surface,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                keys[i],
                style: TextStyle(
                  fontSize: PinFontSize.xs2,
                  color: spec.text2,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// 优先级旗标（对应 .flag：旗形图标 + 文字）
class PinFlag extends StatelessWidget {
  const PinFlag(this.label, {super.key, required this.color, this.fontSize});

  final String label;
  final Color color;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PinIcon(PinIcons.flag, size: 11, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: fontSize ?? PinFontSize.xs2,
            color: color,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}

/// 搜索结果高亮（对应 .hl：主色粗体 + 下划线）
class PinHighlightText extends StatelessWidget {
  const PinHighlightText(
    this.text, {
    super.key,
    required this.query,
    this.style,
  });

  final String text;
  final String query;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final base = style ?? context.pin.tsm;
    if (query.isEmpty) return Text(text, style: base);

    final spans = <TextSpan>[];
    var start = 0;
    var idx = text.indexOf(query);
    final hlStyle = base.copyWith(
      color: spec.primaryStrong,
      fontWeight: FontWeight.w700,
      decoration: TextDecoration.underline,
      decorationColor: spec.primary,
      decorationThickness: 1.5,
    );
    while (idx != -1) {
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx)));
      }
      spans.add(
        TextSpan(text: text.substring(idx, idx + query.length), style: hlStyle),
      );
      start = idx + query.length;
      idx = text.indexOf(query, start);
    }
    if (start < text.length) {
      spans.add(TextSpan(text: text.substring(start)));
    }
    return Text.rich(TextSpan(children: spans, style: base));
  }
}
