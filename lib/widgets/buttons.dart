/// 贴记 PinNote · 按钮与链接（对应 app.css .btn / .icon-btn / .link）
library;

import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../design/forui_theme.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';

/// 按钮类型（对应 .btn-primary / .btn-secondary / .btn-danger / .btn-ghost / .btn-disabled）
enum PinButtonVariant { primary, secondary, danger, ghost, disabled }

/// 按钮尺寸（对应默认 / .btn-lg / .btn-xl）
enum PinButtonSize { md, lg, xl }

/// 主按钮 / 次按钮 / 危险 / 幽灵 / 禁用
class PinButton extends StatefulWidget {
  const PinButton(
    this.label, {
    super.key,
    this.variant = PinButtonVariant.primary,
    this.size = PinButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.onTap,
    this.expand = false,
  });

  final String label;
  final PinButtonVariant variant;
  final PinButtonSize size;
  final PinIconData? icon;
  final PinIconData? trailingIcon;
  final VoidCallback? onTap;
  final bool expand;

  @override
  State<PinButton> createState() => _PinButtonState();
}

class _PinButtonState extends State<PinButton> {
  FButtonVariant _foruiVariant() => switch (widget.variant) {
        PinButtonVariant.primary => FButtonVariant.primary,
        PinButtonVariant.secondary => FButtonVariant.outline,
        PinButtonVariant.danger => FButtonVariant.destructive,
        PinButtonVariant.ghost => FButtonVariant.ghost,
        PinButtonVariant.disabled => FButtonVariant.outline,
      };

  Color _fg(PinSpec spec) => switch (widget.variant) {
        PinButtonVariant.primary => Colors.white,
        PinButtonVariant.secondary => spec.text2,
        PinButtonVariant.danger => spec.dangerStrong,
        PinButtonVariant.ghost => spec.primaryStrong,
        PinButtonVariant.disabled => spec.faint,
      };

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final isDisabled = widget.variant == PinButtonVariant.disabled;
    final fg = _fg(spec);
    const gap = SizedBox(width: 7);

    // forui FButton：成熟按钮组件，hover / 按压 / 禁用态由库内处理；
    // 颜色经 FTheme 适配层与 PinSpec 对齐
    return FTheme(
      data: buildForuiTheme(spec),
      child: FButton(
        onPress: isDisabled ? null : widget.onTap,
        variant: _foruiVariant(),
        size: widget.size == PinButtonSize.md ? FButtonSizeVariant.md : FButtonSizeVariant.lg,
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) PinIcon(widget.icon!, size: 13, color: fg),
            if (widget.icon != null) gap,
            Text(
              widget.label,
              style: TextStyle(
                fontSize: widget.size == PinButtonSize.md
                    ? PinFontSize.sm
                    : PinFontSize.md,
                fontWeight: FontWeight.w600,
                color: fg,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
            if (widget.trailingIcon != null) gap,
            if (widget.trailingIcon != null)
              PinIcon(widget.trailingIcon!, size: 13, color: fg),
          ],
        ),
      ),
    );
  }
}

/// 图标按钮（对应 .icon-btn，激活态 .active）
class PinIconButton extends StatefulWidget {
  const PinIconButton(
    this.icon, {
    super.key,
    this.size = PinSize.iconButton,
    this.iconSize = 16,
    this.active = false,
    this.color,
    this.onTap,
    this.tooltip,
  });

  final PinIconData icon;
  final double size;
  final double iconSize;
  final bool active;
  final Color? color;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  State<PinIconButton> createState() => _PinIconButtonState();
}

class _PinIconButtonState extends State<PinIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final fg = widget.active
        ? spec.primaryStrong
        : (widget.color ?? spec.text2);
    final bg = widget.active
        ? spec.primaryTint
        : (_hover ? spec.hover : Colors.transparent);

    final btn = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: PinMotion.dur,
          curve: PinMotion.ease,
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(PinRadius.sm),
          ),
          child: Center(
            child: PinIcon(widget.icon, size: widget.iconSize, color: fg),
          ),
        ),
      ),
    );
    if (widget.tooltip == null) return btn;
    return Tooltip(message: widget.tooltip!, child: btn);
  }
}

/// 文本链接（对应 .link）
class PinLink extends StatefulWidget {
  const PinLink(
    this.label, {
    super.key,
    this.onTap,
    this.fontSize,
    this.underlineOnHover = true,
  });

  final String label;
  final VoidCallback? onTap;
  final double? fontSize;
  final bool underlineOnHover;

  @override
  State<PinLink> createState() => _PinLinkState();
}

class _PinLinkState extends State<PinLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.label,
          style: TextStyle(
            fontSize: widget.fontSize ?? PinFontSize.sm,
            fontWeight: FontWeight.w500,
            color: spec.primaryStrong,
            decoration: _hover && widget.underlineOnHover
                ? TextDecoration.underline
                : null,
            decorationColor: spec.primary,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ),
    );
  }
}
