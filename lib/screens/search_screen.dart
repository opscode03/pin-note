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
import '../data/demo.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/chips.dart';
import '../widgets/controls.dart';
import '../widgets/interactive.dart';
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
  List<_SearchHit> _hits = const [];

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
    final q = _query.text.trim().toLowerCase();
    final hits = <_SearchHit>[];
    // 任务（仓库实时）
    for (final t in [...repo.today, ...repo.overdue, ...repo.done]) {
      if (q.isEmpty || t.title.toLowerCase().contains(q)) {
        hits.add(_SearchHit.task(t));
      }
    }
    // 便签（演示数据）
    for (final n in kDemoNotes) {
      if (q.isEmpty || n.title.toLowerCase().contains(q)) {
        hits.add(_SearchHit.note(n));
      }
    }
    // 标签（任务标签聚合）
    final tagSet = <String>{for (final t in repo.tasks) ...t.tags};
    for (final tag in tagSet) {
      if (q.isEmpty || tag.toLowerCase().contains(q)) {
        hits.add(_SearchHit.tag(tag));
      }
    }
    setState(() {
      _hits = hits;
      _selected = 0;
    });
  }

  void _open(_SearchHit hit) {
    switch (hit.kind) {
      case _HitKind.task:
        showTaskEditDialog<void>(context, task: hit.task);
      case _HitKind.note:
        AppNav.go(context, '/note-editor');
      case _HitKind.tag:
        AppNav.go(context, '/notes');
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
            child: _SearchDrop(
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

class _SearchHit {
  const _SearchHit.task(this.task)
    : kind = _HitKind.task,
      note = null,
      tag = null;
  const _SearchHit.note(this.note)
    : kind = _HitKind.note,
      task = null,
      tag = null;
  const _SearchHit.tag(this.tag)
    : kind = _HitKind.tag,
      task = null,
      note = null;

  final _HitKind kind;
  final DemoTask? task;
  final DemoNote? note;
  final String? tag;
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
    SidebarEntry(
      '便签库',
      icon: PinIcons.pin,
      badge: '8',
      onTap: () => AppNav.go(context, '/notes'),
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
enum _HitKind { task, note, tag }

/// 搜索结果浮层（.search-drop：padding 10）
class _SearchDrop extends StatelessWidget {
  const _SearchDrop({
    required this.width,
    required this.hits,
    required this.selected,
    required this.query,
    required this.onOpen,
  });

  final double width;
  final List<_SearchHit> hits;
  final int selected;
  final String query;
  final ValueChanged<_SearchHit> onOpen;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.lg),
        border: Border.all(color: spec.line),
        boxShadow: spec.shadowFar,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hits.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 22),
              child: Text(
                query.isEmpty ? '输入关键词，搜索任务与便签…' : '没有找到「$query」相关的结果',
                style: spec.tsm.copyWith(color: spec.faint),
              ),
            )
          else
            _grouped(context),
          // 底部快捷键提示（.sd-foot）
          Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: spec.line)),
            ),
            child: const Row(
              children: [
                _FootHint(['↑', '↓'], '选择'),
                SizedBox(width: PinSpace.s4),
                _FootHint(['Enter'], '打开'),
                SizedBox(width: PinSpace.s4),
                _FootHint(['Esc'], '关闭'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _grouped(BuildContext context) {
    final children = <Widget>[];
    var lastKind = _HitKind.task;
    var groupCount = 0;

    // 分组渲染：任务 / 便签 / 清单与标签
    String labelFor(_HitKind k) => switch (k) {
      _HitKind.task => '任务',
      _HitKind.note => '便签',
      _HitKind.tag => '清单与标签',
    };

    for (var i = 0; i < hits.length; i++) {
      final hit = hits[i];
      if (i == 0 || hit.kind != lastKind) {
        if (i > 0) {
          children.add(_GroupLabel('${labelFor(lastKind)} · $groupCount'));
        }
        lastKind = hit.kind;
        groupCount = 0;
      }
      groupCount += 1;
      children.add(_row(context, hit, i, query));
    }
    if (hits.isNotEmpty) {
      children.add(_GroupLabel('${labelFor(lastKind)} · $groupCount'));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _row(BuildContext context, _SearchHit hit, int index, String query) {
    final spec = context.pin;
    final focus = index == selected;
    switch (hit.kind) {
      case _HitKind.task:
        final t = hit.task!;
        return _ResultRow(
          focus: focus,
          onTap: () => onOpen(hit),
          leading: PinCheckbox(done: t.done),
          title: PinHighlightText(t.title, query: query),
          trailing: _MetaText(
            '${t.done ? '已完成' : (t.listName ?? '任务')} · ${t.priority.label}',
          ),
        );
      case _HitKind.note:
        final n = hit.note!;
        return _ResultRow(
          focus: focus,
          onTap: () => onOpen(hit),
          leading: PinIcon(PinIcons.note, size: 16, color: spec.text2),
          title: PinHighlightText(n.title, query: query),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinNoteChipOf(n.color),
              const SizedBox(width: PinSpace.s2),
              _MetaText(n.time),
            ],
          ),
        );
      case _HitKind.tag:
        final tag = hit.tag!;
        return _ResultRow(
          focus: focus,
          onTap: () => onOpen(hit),
          leading: PinIcon(PinIcons.tag, size: 16, color: spec.violetStrong),
          title: Text(
            tag,
            style: spec.tsm.copyWith(
              color: spec.violetStrong,
              fontWeight: FontWeight.w700,
            ),
          ),
          title2: Text(
            '— 查看该标签下的内容',
            style: spec.tsm.copyWith(color: spec.text2),
          ),
          trailing: const _MetaText('标签'),
        );
    }
  }
}

/// 按便签色渲染的色名 Chip（搜索结果里的「桌面贴」胶囊）
class PinNoteChipOf extends StatelessWidget {
  const PinNoteChipOf(this.color, {super.key});

  final StickyColor color;

  @override
  Widget build(BuildContext context) {
    return const PinChip('桌面贴', icon: PinIcons.pin, style: PinChipStyle.accent);
  }
}

/// 分组标题（.sd-group：margin 10 14 4、11px 加粗弱化色）
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
      child: Text(
        label,
        style: spec.t2xs.copyWith(
          color: spec.faint,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// 11px 弱化元信息（.sd-meta）
class _MetaText extends StatelessWidget {
  const _MetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.pin.t2xs.copyWith(color: context.pin.faint),
    );
  }
}

/// 结果行（.sd-row：高 48、padding 0 14、圆角 8；focus 行选中底色）
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.leading,
    required this.title,
    required this.trailing,
    required this.onTap,
    this.title2,
    this.focus = false,
  });

  final Widget leading;
  final Widget title;
  final Widget? title2;
  final Widget trailing;
  final VoidCallback onTap;
  final bool focus;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: focus
                ? spec.selBg
                : (hover ? spec.hover : Colors.transparent),
            borderRadius: BorderRadius.circular(PinRadius.sm),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: PinSpace.s3),
              title,
              if (title2 != null) ...[
                const SizedBox(width: PinSpace.s3),
                title2!,
              ],
              const Spacer(),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// 底部快捷键提示项（.sd-foot 里的 span：kbd + 说明文字）
class _FootHint extends StatelessWidget {
  const _FootHint(this.keys, this.label);

  final List<String> keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PinKbd(keys),
        const SizedBox(width: 4),
        Text(label, style: spec.t2xs.copyWith(color: spec.faint)),
      ],
    );
  }
}
