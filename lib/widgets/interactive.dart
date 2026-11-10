/// 贴记 PinNote · 交互基座
///
/// [HoverScope] 让鼠标悬停状态沿组件树向下传播，
/// 对应 CSS 里 `a:hover .cb { border-color: primary }` 这类父级 hover 选择器。
library;

import 'package:flutter/material.dart';

/// 提供当前悬停状态给后代组件（checkbox、icon 等）
class HoverScope extends StatefulWidget {
  const HoverScope({super.key, required this.child});

  final Widget child;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_HoverScopeData>()?.hover ??
      false;

  @override
  State<HoverScope> createState() => _HoverScopeState();
}

class _HoverScopeState extends State<HoverScope> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: _HoverScopeData(hover: _hover, child: widget.child),
    );
  }
}

class _HoverScopeData extends InheritedWidget {
  const _HoverScopeData({required this.hover, required super.child});

  final bool hover;

  @override
  bool updateShouldNotify(_HoverScopeData oldWidget) =>
      oldWidget.hover != hover;
}

/// 悬停状态构建器：导航项 / 任务行 / 菜单项等共享
class HoverBuilder extends StatefulWidget {
  const HoverBuilder({super.key, required this.builder, this.child});

  final Widget Function(BuildContext context, bool hover, Widget? child)
  builder;
  final Widget? child;

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: HoverScope(child: widget.builder(context, _hover, widget.child)),
    );
  }
}
