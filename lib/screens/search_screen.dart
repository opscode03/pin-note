/// 贴记 PinNote · 搜索（对应 ui/search.html）
///
/// 标题栏真输入框实时过滤（任务 / 便签 / 标签三组结果），
/// ↑↓ 选择、Enter 打开、Esc 关闭；点击结果直达对应目标。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_scope.dart';
import '../app/dialogs.dart';
import '../app/navigation.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/search_drop.dart';
import '../widgets/sidebar.dart';

/// 搜索页（search.html：标题栏激活搜索胶囊 + 空内容区 + 结果浮层）
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _query = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  int _selected = 0;
  List<SearchHit> _hits = const [];

  @override
  void initState() {
    super.initState();
    _query.addListener(_refresh);
    HardwareKeyboard.instance.addHandler(_onKey);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_onKey);
    _query.removeListener(_refresh);
    _query.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  ModalRoute<Object?>? _route;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context);
  }

  /// 全局键盘：↑↓ 移动选择、Enter 打开、Esc 关闭（先于 TextField 消费）
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;
    final key = event.logicalKey;
    // Esc：仅当搜索页是当前路由时由本页处理（否则交给弹层自身的 EscHandler）
    if (key == LogicalKeyboardKey.escape) {
      if (_route?.isCurrent == true) {
        AppNav.go(context, '/');
        return true;
      }
      return false;
    }
    if (_hits.isEmpty) return false;
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _selected = (_selected + 1) % _hits.length);
      return true;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(() => _selected = (_selected - 1 + _hits.length) % _hits.length);
      return true;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _open(_hits[_selected.clamp(0, _hits.length - 1)]);
      return true;
    }
    return false;
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
        showTaskEditDialog<void>(context, task: hit.task);
      case SearchKind.tag:
        // 只保留任务主流程：标签结果回到今日任务列表
        AppNav.go(context, '/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // .search-drop { width: min(600px, 62vw); top: 60px; 水平居中 }
    final dropWidth = width * 0.62 < 600 ? width * 0.62 : 600.0;

    // Esc 关闭搜索：由本页 HardwareKeyboard 处理器接管（见 _onKey）
    return Stack(
      children: [
        PinAppWindow(
          // 标题栏搜索胶囊：真输入框（实时过滤）
          titleBar: PinTitleBar(
            searchController: _query,
            searchFocusNode: _searchFocus,
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PinSidebar(items: _navItems(context)),
              const Expanded(child: _EmptyContent()),
            ],
          ),
        ),
        // 结果浮层（.popover.search-drop）
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(
            child: SearchDrop(
              width: dropWidth,
              hits: _hits,
              selected: _selected,
              query: _query.text.trim(),
              onOpen: _open,
            ),
          ),
        ),
      ],
    );
  }
}

/// 侧栏（与 search.html 一致：清单只有收件箱/工作/生活，标签只有重要/设计）
List<Object> _navItems(BuildContext context) {
  final spec = context.pin;
  return [
    SidebarEntry(
      '今日',
      icon: PinIcons.calendar,
      badge: '5',
      selected: true,
      onTap: () => AppNav.go(context, '/'),
    ),
    SidebarEntry(
      '最近 7 天',
      icon: PinIcons.clock,
      badge: '12',
      onTap: () => AppNav.go(context, '/empty-states'),
    ),
    const SidebarEntry('全部', icon: PinIcons.layers, badge: '38'),
    SidebarEntry(
      '已完成',
      icon: PinIcons.check,
      onTap: () => AppNav.go(context, '/empty-states'),
    ),
    const SidebarHeader('清单'),
    const SidebarEntry('收件箱', dotColor: PinListDots.inbox, badge: '3'),
    const SidebarEntry('工作', dotColor: PinListDots.work, badge: '12'),
    const SidebarEntry('生活', dotColor: PinListDots.life, badge: '9'),
    const SidebarHeader('标签'),
    // nav-hash 色取自语义色（--color-danger-strong / --color-primary-strong）
    SidebarEntry('重要', hashColor: spec.dangerStrong),
    SidebarEntry('设计', hashColor: spec.primaryStrong),
  ];
}

/// 空内容区（<main class="content"></main>；底色沿用内容区 --color-bg）
class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: context.pin.bg);
  }
}

/// 搜索命中

