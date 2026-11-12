/// 贴记 PinNote · 桌面贴控制（对应 ui/pin-controls.html）
///
/// 桌面贴选中态：悬浮工具条 + 右键菜单 + 放大展示的便签。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/buttons.dart';
import '../widgets/interactive.dart';
import '../widgets/menu.dart';
import '../widgets/scene.dart';
import '../widgets/sticky_note.dart';

class PinControlsScreen extends StatelessWidget {
  const PinControlsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WallpaperScene(
      variant: 'b',
      child: Stack(
        children: [
          // 悬浮工具条
          const _ScenePosition(
            leftPct: 0.14,
            topPct: 0.165,
            child: _PinToolbar(),
          ),
          // 放大展示的便签
          const _ScenePosition(
            leftPct: 0.14,
            topPct: 0.29,
            width: 430,
            rotateDeg: -1,
            child: _BigNote(),
          ),
          // 右键菜单
          _ScenePosition(leftPct: 0.57, topPct: 0.19, child: _ContextMenu()),
          const PinTaskbar(activeAppIndex: 2),
        ],
      ),
    );
  }
}

class _ScenePosition extends StatelessWidget {
  const _ScenePosition({
    required this.leftPct,
    required this.topPct,
    required this.child,
    this.width,
    this.rotateDeg,
  });

  final double leftPct;
  final double topPct;
  final double? width;
  final double? rotateDeg;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    Widget w = width != null ? SizedBox(width: width, child: child) : child;
    if (rotateDeg != null) {
      w = Transform.rotate(
        angle: rotateDeg! * math.pi / 180,
        alignment: Alignment.center,
        child: w,
      );
    }
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.sizeOf(context).width * leftPct,
            top: MediaQuery.sizeOf(context).height * topPct,
          ),
          child: w,
        ),
      ),
    );
  }
}

/// 悬浮工具条（对应 .pin-toolbar）
class _PinToolbar extends StatelessWidget {
  const _PinToolbar();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.lg),
        border: Border.all(color: spec.line),
        boxShadow: spec.shadowFar,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _ToolButton(label: '颜色', icon: PinIcons.palette),
          const _ToolButton(
            label: '大小',
            child: 'Aa',
            childFontSize: 13,
            bold: true,
          ),
          const _ToolButton(label: '透明度', icon: PinIcons.opacity, wide: true),
          const _ToolButton(
            label: '置顶显示',
            icon: PinIcons.layers,
            wide: true,
            on: true,
          ),
          const _ToolButton(label: '更多', icon: PinIcons.more),
          Container(
            width: 1,
            height: 34,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            color: spec.line,
          ),
          PinIconButton(
            PinIcons.close,
            size: 36,
            iconSize: 13,
            onTap: () => Navigator.pushNamed(context, '/desktop-pins'),
          ),
        ],
      ),
    );
  }
}

/// 工具条按钮（对应 .pt-btn：58×50 竖排图标+文字）
class _ToolButton extends StatelessWidget {
  const _ToolButton({
    this.label,
    this.icon,
    this.child,
    this.childFontSize,
    this.bold = false,
    this.wide = false,
    this.on = false,
  });

  final String? label;
  final PinIconData? icon;
  final String? child; // 纯文字内容（如 Aa）
  final double? childFontSize;
  final bool bold;
  final bool wide;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) {
        final bg = on ? spec.primaryTint : (hover ? spec.hover : null);
        final fg = on ? spec.primaryStrong : spec.text2;
        return GestureDetector(
          child: Container(
            width: wide ? 72 : 58,
            height: 50,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (child != null)
                  Text(
                    child!,
                    style: TextStyle(
                      fontSize: childFontSize ?? 13,
                      height: 17 / 13,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                      color: fg,
                      fontFamilyFallback: PinFont.sans,
                    ),
                  )
                else
                  PinIcon(icon!, size: 17, color: fg),
                const SizedBox(height: 4),
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: PinFontSize.xs2,
                    fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                    color: fg,
                    fontFamilyFallback: PinFont.sans,
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

/// 放大展示的便签
class _BigNote extends StatelessWidget {
  const _BigNote();

  @override
  Widget build(BuildContext context) {
    return const PinSticky(
      color: StickyColor.lemon,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickyTitle('设计评审准备', fontSize: 17),
          StickyCheckRow('整理竞品分析', done: true),
          StickyCheckRow('收集 Q3 数据', done: true),
          StickyCheckRow('制作演示文稿'),
          StickyCheckRow('请 Anna 核对数据'),
          _NoteStatus(),
        ],
      ),
    );
  }
}

class _NoteStatus extends StatelessWidget {
  const _NoteStatus();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 18),
      child: PinNoteChip('已贴附 · 壁纸层', icon: PinIcons.pin),
    );
  }
}

/// 右键菜单（对应 .menu）
class _ContextMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PinMenu(
      width: 262,
      dividersAfter: const [2, 5, 8],
      items: [
        const PinMenuItem(label: '置顶显示', icon: PinIcons.check, showCheck: true),
        const PinMenuItem(label: '点击穿透', icon: PinIcons.opacity),
        const PinMenuItem(label: '锁定位置', icon: PinIcons.lock),
        const PinMenuItem(
          label: '更换颜色',
          icon: PinIcons.palette,
          hasSubmenu: true,
        ),
        const PinMenuItem(
          label: '透明度',
          icon: PinIcons.opacity,
          hasSubmenu: true,
        ),
        const PinMenuItem(label: '文字大小', icon: PinIcons.note, hasSubmenu: true),
        PinMenuItem(
          label: '转为任务',
          icon: PinIcons.check,
          onTap: () => Navigator.pushNamed(context, '/task-edit'),
        ),
        const PinMenuItem(label: '复制内容', icon: PinIcons.note),
        const PinMenuItem(label: '另存为图片', icon: PinIcons.image),
        PinMenuItem(
          label: '取消贴附',
          icon: PinIcons.pin,
          onTap: () => Navigator.pushNamed(context, '/notes'),
        ),
        const PinMenuItem(label: '删除', icon: PinIcons.trash, danger: true),
      ],
    );
  }
}
