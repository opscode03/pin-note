/// 贴记 PinNote · 侧栏导航（对应 app.css .sidebar / .nav-*）
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'interactive.dart';

/// 侧栏条目
class SidebarEntry {
  const SidebarEntry(
    this.label, {
    this.icon,
    this.dotColor,
    this.hashColor,
    this.badge,
    this.selected = false,
    this.onTap,
    this.muted = false, // 新建清单这类弱化项
  });

  final String label;
  final PinIconData? icon;
  final Color? dotColor;
  final Color? hashColor;
  final String? badge;
  final bool selected;
  final VoidCallback? onTap;
  final bool muted;
}

/// 侧栏小节标题（“清单” / “标签”）
class SidebarHeader {
  const SidebarHeader(this.label);

  final String label;
}

/// 侧栏容器：220 宽、surface-2 底、右侧分割线、底部用户卡
class PinSidebar extends StatelessWidget {
  const PinSidebar({required this.items, this.footer = true, super.key});

  /// 依次为 [SidebarEntry] 与 [SidebarHeader]
  final List<Object> items;
  final bool footer;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: PinSize.sidebar,
      decoration: BoxDecoration(
        color: spec.surface2,
        border: Border(right: BorderSide(color: spec.line)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: PinSpace.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final item in items)
                    if (item is SidebarHeader)
                      _SectionTitle(item.label)
                    else if (item is SidebarEntry)
                      _NavTile(item),
                ],
              ),
            ),
          ),
          if (footer) const _SidebarFooter(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 6),
      child: Text(
        label,
        style: TextStyle(
          fontSize: PinFontSize.xs2,
          color: spec.faint,
          fontWeight: FontWeight.w600,
          fontFamilyFallback: PinFont.sans,
        ),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile(this.entry);

  final SidebarEntry entry;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final selected = entry.selected;
    final fg = selected ? spec.selText : (entry.muted ? spec.faint : spec.text);
    return HoverBuilder(
      builder: (context, hover, _) {
        final bg = selected ? spec.selBg : (hover ? spec.hover : null);
        return GestureDetector(
          onTap: entry.onTap,
          child: Container(
            height: PinSize.navItem,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(PinRadius.sm),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    if (entry.icon != null)
                      PinIcon(
                        entry.icon!,
                        size: 15,
                        color: selected ? spec.selText : spec.text2,
                      )
                    else if (entry.dotColor != null)
                      Container(
                        width: 9,
                        height: 9,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: entry.dotColor,
                        ),
                      )
                    else if (entry.hashColor != null)
                      SizedBox(
                        width: 14,
                        child: Text(
                          '#',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: entry.hashColor,
                            fontFamilyFallback: PinFont.sans,
                          ),
                        ),
                      )
                    else if (entry.muted)
                      const PinIcon(PinIcons.plus, size: 15),
                    // HTML .nav-item gap: 10px（nav-dot 自带 margin 0 3）
                    if (entry.icon != null ||
                        entry.dotColor != null ||
                        entry.hashColor != null ||
                        entry.muted)
                      const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        entry.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: PinFontSize.sm,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: fg,
                          fontFamilyFallback: PinFont.sans,
                        ),
                      ),
                    ),
                    if (entry.badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? spec.surface : spec.primaryTint,
                          borderRadius: BorderRadius.circular(PinRadius.full),
                        ),
                        child: Text(
                          entry.badge!,
                          style: TextStyle(
                            fontSize: PinFontSize.xs2,
                            fontWeight: FontWeight.w600,
                            color: spec.primaryStrong,
                            fontFamilyFallback: PinFont.sans,
                          ),
                        ),
                      ),
                  ],
                ),
                // 激活态左侧条 ::before
                if (selected)
                  Positioned(
                    left: -10,
                    top: 7,
                    bottom: 7,
                    child: Container(
                      width: 3,
                      decoration: BoxDecoration(
                        color: spec.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: spec.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spec.primaryTint,
            ),
            child: Text(
              '晓',
              style: TextStyle(
                fontSize: PinFontSize.xs,
                fontWeight: FontWeight.w600,
                color: spec.primaryStrong,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '李晓',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: spec.text,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '本地模式 · 数据已同步',
                  style: TextStyle(
                    fontSize: PinFontSize.xs2,
                    color: spec.faint,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ],
            ),
          ),
          PinIcon(PinIcons.sync, size: 13, color: spec.faint),
        ],
      ),
    );
  }
}
