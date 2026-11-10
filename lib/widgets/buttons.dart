/// 贴记 PinNote · 按钮与链接（对应 app.css .btn / .icon-btn / .link）
library;

import 'package:flutter/material.dart';

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
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final isDisabled =
        widget.variant == PinButtonVariant.disabled ||
        widget.onTap == null && widget.variant == PinButtonVariant.disabled;

    final double height;
    final double hPadding;
    final double fontSize;
    final double radius;
    switch (widget.size) {
      case PinButtonSize.md:
        height = PinSize.button;
        hPadding = 14;
        fontSize = PinFontSize.sm;
        radius = PinRadius.sm;
      case PinButtonSize.lg:
        height = PinSize.buttonLg;
        hPadding = 24;
        fontSize = PinFontSize.md;
        radius = PinRadius.md;
      case PinButtonSize.xl:
        height = PinSize.buttonXl;
        hPadding = 28;
        fontSize = PinFontSize.md;
        radius = PinRadius.md;
    }

    Color bg;
    Color fg;
    Border? border;
    switch (widget.variant) {
      case PinButtonVariant.primary:
        bg = _hover
            ? _darken(spec.primary, 0.2)
            : spec.primary; // hover: color-mix 80% primary + 20% black
        fg = Colors.white;
      case PinButtonVariant.secondary:
        bg = spec.surface;
        fg = _hover ? spec.text : spec.text2;
        border = Border.fromBorderSide(
          BorderSide(color: _hover ? spec.faint : spec.lineStrong),
        );
      case PinButtonVariant.danger:
        bg = spec.dangerTint;
        fg = spec.dangerStrong;
      case PinButtonVariant.ghost:
        bg = Colors.transparent;
        fg = spec.primaryStrong;
      case PinButtonVariant.disabled:
        bg = spec.surface3;
        fg = spec.faint;
    }
    if (isDisabled) {
      bg = spec.surface3;
      fg = spec.faint;
    }

    return MouseRegion(
      cursor: isDisabled ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: isDisabled ? null : widget.onTap,
        child: AnimatedScale(
          scale: _down && !isDisabled ? 0.97 : 1,
          duration: PinMotion.dur,
          curve: PinMotion.ease,
          child: AnimatedContainer(
            duration: PinMotion.dur,
            curve: PinMotion.ease,
            height: height,
            padding: EdgeInsets.symmetric(horizontal: hPadding),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              border: border,
            ),
            child: widget.expand
                ? Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _content(fg, fontSize),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: _content(fg, fontSize),
                  ),
          ),
        ),
      ),
    );
  }

  List<Widget> _content(Color fg, double fontSize) {
    const gap = SizedBox(width: 7);
    return [
      if (widget.icon != null) PinIcon(widget.icon!, size: 13, color: fg),
      if (widget.icon != null) gap,
      Text(
        widget.label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: fg,
          fontFamilyFallback: PinFont.sans,
        ),
      ),
      if (widget.trailingIcon != null) gap,
      if (widget.trailingIcon != null)
        PinIcon(widget.trailingIcon!, size: 13, color: fg),
    ];
  }
}

Color _darken(Color c, double amount) => Color.lerp(c, Colors.black, amount)!;

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
