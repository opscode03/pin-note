/// 贴记 PinNote · 搜索下拉浮层（Ctrl+K / 标题栏搜索胶囊直接触发）
///
/// 交互优化：不再跳转搜索页，点搜索框 / Ctrl+K 即弹出浮层——
/// 蒙层 + 居中输入框（自动聚焦）+ 实时结果下拉；
/// ↑↓ 选择、Enter 打开任务编辑、Esc 或点击蒙层关闭。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_scope.dart';
import '../../app/dialogs.dart';
import '../../app/navigation.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../chips.dart';
import '../search_drop.dart';

/// 打开搜索下拉浮层（替代原 /search 页面跳转）
Future<T?> showSearchOverlay<T>(BuildContext context) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '搜索',
    barrierColor: const Color(0x6B080C16), // rgba(8,12,22,.42) 同快速捕获蒙层
    pageBuilder: (ctx, a, b) => const _SearchOverlayPanel(),
    transitionBuilder: (ctx, anim, a2, child) => FadeTransition(
      opacity: anim,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, -0.04),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
  );
}

class _SearchOverlayPanel extends StatefulWidget {
  const _SearchOverlayPanel();

  @override
  State<_SearchOverlayPanel> createState() => _SearchOverlayPanelState();
}

class _SearchOverlayPanelState extends State<_SearchOverlayPanel> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _focus = FocusNode();
  final FocusNode _keyScope = FocusNode();
  int _selected = 0;
  List<SearchHit> _hits = const [];

  @override
  void initState() {
    super.initState();
    _query.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _query.removeListener(_refresh);
    _query.dispose();
    _focus.dispose();
    _keyScope.dispose();
    super.dispose();
  }

  /// 键盘导航：↑↓ 选择、Enter 打开、Esc 关闭（onKeyEvent 精确处理，不拦截输入）
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.escape) {
      Navigator.pop(context);
      return KeyEventResult.handled;
    }
    if (_hits.isEmpty) return KeyEventResult.ignored;
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _selected = (_selected + 1) % _hits.length);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(
        () => _selected = (_selected - 1 + _hits.length) % _hits.length,
      );
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _open(_hits[_selected.clamp(0, _hits.length - 1)]);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _refresh() {
    final repo = TaskScope.of(context);
    setState(() {
      _hits = buildSearchHits(repo, _query.text);
      _selected = 0;
    });
  }

  void _open(SearchHit hit) {
    switch (hit.kind) {
      case SearchKind.task:
        // Spotlight 式交互：搜索浮层保持，任务编辑弹层叠加其上；
        // Esc 关编辑后回到搜索结果继续筛选
        showTaskEditDialog<void>(context, task: hit.task);
      case SearchKind.tag:
        // 标签结果 → 收起浮层，回今日任务列表
        Navigator.pop(context);
        AppNav.go(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final width = MediaQuery.sizeOf(context).width;
    // .search-drop { width: min(600px, 62vw); top: 60px; 水平居中 }
    final dropWidth = width * 0.62 < 600 ? width * 0.62 : 600.0;

    return Material(
      type: MaterialType.transparency,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 输入胶囊（.tb-search 输入态样式：主色描边 + tint 光晕）
                Focus(
                  focusNode: _keyScope,
                  onKeyEvent: _onKey,
                  child: Container(
                    width: dropWidth,
                    height: 34,
                    padding:
                        const EdgeInsets.symmetric(horizontal: PinSpace.s3),
                    decoration: BoxDecoration(
                      color: spec.surface,
                      borderRadius: BorderRadius.circular(PinRadius.full),
                      border: Border.all(color: spec.primary),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 0,
                          spreadRadius: 3,
                          color: spec.primaryTint,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        PinIcon(PinIcons.search, size: 14, color: spec.text),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _query,
                            focusNode: _focus,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: PinFontSize.sm,
                              fontWeight: FontWeight.w600,
                              color: spec.text,
                              fontFamilyFallback: PinFont.sans,
                            ),
                            cursorColor: spec.primary,
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              hintText: '搜索任务…',
                            ),
                          ),
                        ),
                        const PinKbd(['Esc']),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SearchDrop(
                  width: dropWidth,
                  hits: _hits,
                  selected: _selected,
                  query: _query.text.trim(),
                  onOpen: _open,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
