/// 贴记 PinNote · 菜单与 Toast（对应 app.css .menu / .toast）
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'buttons.dart';

/// 菜单项
class PinMenuItem {
  const PinMenuItem({
    required this.label,
    this.icon,
    this.kbd,
    this.hasSubmenu = false,
    this.showCheck = false,
    this.danger = false,
    this.onTap,
  });

  final String label;
  final PinIconData? icon;
  final String? kbd; // 快捷键（menu-kbd）
  final bool hasSubmenu; // 右侧箭头（menu-sub）
  final bool showCheck; // 左侧主色对勾（menu-check）
  final bool danger;
  final VoidCallback? onTap;
}

/// 菜单容器（对应 .menu：258 宽、面板底、远阴影）
class PinMenu extends StatelessWidget {
  const PinMenu({
    required this.items,
    this.width = 258,
    this.header,
    this.dividersAfter = const <int>[],
    super.key,
  });

  final List<PinMenuItem> items;
  final double width;
  final Widget? header;

  /// 在第 n 个 item 之后插入分隔线（对应 .menu-div）
  final List<int> dividersAfter;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: width,
      padding: const EdgeInsets.all(PinSpace.s2),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(color: spec.line),
        boxShadow: spec.shadowFar,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?header,
          for (var i = 0; i < items.length; i++) ...[
            _MenuItemTile(item: items[i]),
            if (dividersAfter.contains(i)) const MenuDivider(),
          ],
        ],
      ),
    );
  }
}

class _MenuItemTile extends StatefulWidget {
  const _MenuItemTile({required this.item});

  final PinMenuItem item;

  @override
  State<_MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<_MenuItemTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final item = widget.item;
    final fg = item.danger ? spec.dangerStrong : spec.text;
    final iconColor = item.danger
        ? spec.dangerStrong
        : (item.showCheck ? spec.primary : spec.text2);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: item.onTap,
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: PinSpace.s3),
          decoration: BoxDecoration(
            color: _hover ? spec.hover : Colors.transparent,
            borderRadius: BorderRadius.circular(PinRadius.sm),
          ),
          child: Row(
            children: [
              if (item.icon != null) ...[
                PinIcon(item.icon!, size: 15, color: iconColor),
                const SizedBox(width: 10),
              ],
              Text(item.label, style: spec.tsm.copyWith(color: fg)),
              const Spacer(),
              if (item.kbd != null)
                // FittedBox：超宽快捷键提示（长组合键）按需缩小，正常宽度不影响视觉
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item.kbd!,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: PinFontSize.xs2,
                        color: spec.faint,
                        fontFamilyFallback: PinFont.sans,
                      ),
                    ),
                  ),
                ),
              if (item.hasSubmenu)
                PinIcon(PinIcons.chevronRight, size: 15, color: spec.text2),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分隔线（.menu-div）
class MenuDivider extends StatelessWidget {
  const MenuDivider({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: spec.line,
    );
  }
}

/// Toast（对应 .toast：图标圆 + 标题/说明 + 右侧动作）
class PinToast extends StatelessWidget {
  const PinToast({
    required this.title,
    this.subtitle,
    this.iconBg,
    this.iconColor,
    this.icon = PinIcons.check,
    this.action,
    this.trailing,
    this.minWidth = 320,
    super.key,
  });

  final String title;
  final String? subtitle;
  final Color? iconBg;
  final Color? iconColor;
  final PinIconData icon;
  final String? action; // e.g. 撤销
  final String? trailing; // e.g. 刚刚
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: const EdgeInsets.symmetric(
        horizontal: PinSpace.s4,
        vertical: 13,
      ),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(color: spec.line),
        boxShadow: spec.shadowFar,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBg ?? spec.successTint,
            ),
            child: Center(
              child: PinIcon(icon, color: iconColor ?? spec.successStrong),
            ),
          ),
          const SizedBox(width: PinSpace.s3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: spec.tsm.copyWith(fontWeight: FontWeight.w600),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: PinFontSize.xs2,
                      color: spec.text2,
                      fontFamilyFallback: PinFont.sans,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: PinLink(action!, fontSize: PinFontSize.xs),
            ),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                fontSize: PinFontSize.xs2,
                color: spec.text2,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
        ],
      ),
    );
  }
}
