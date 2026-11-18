/// 贴记 PinNote · 搜索下拉结果（对应 ui/search.html .popover.search-drop）
///
/// 供搜索浮层（[showSearchOverlay]）与 `/search` 页面共用：
/// 结果模型（[SearchHit]）、过滤（[buildSearchHits]）与下拉面板（[SearchDrop]）。
library;

import 'package:flutter/material.dart';

import '../../data/demo.dart';
import '../../data/task_repository.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'chips.dart';
import 'controls.dart';
import 'interactive.dart';

/// 结果类型
enum SearchKind { task, tag }

/// 一条搜索结果
class SearchHit {
  const SearchHit.task(this.task) : kind = SearchKind.task, tag = null;
  const SearchHit.tag(this.tag) : kind = SearchKind.tag, task = null;

  final SearchKind kind;
  final DemoTask? task;
  final String? tag;
}

/// 仓库实时过滤：任务（今天/逾期/已完成）+ 标签聚合
List<SearchHit> buildSearchHits(TaskRepository repo, String query) {
  final q = query.trim().toLowerCase();
  final hits = <SearchHit>[];
  for (final t in [...repo.today, ...repo.overdue, ...repo.done]) {
    if (q.isEmpty || t.title.toLowerCase().contains(q)) {
      hits.add(SearchHit.task(t));
    }
  }
  final tagSet = <String>{for (final t in repo.tasks) ...t.tags};
  for (final tag in tagSet) {
    if (q.isEmpty || tag.toLowerCase().contains(q)) {
      hits.add(SearchHit.tag(tag));
    }
  }
  return hits;
}

/// 搜索下拉面板（.popover.search-drop：min(600px, 62vw)、圆角 lg、远阴影）
class SearchDrop extends StatelessWidget {
  const SearchDrop({
    required this.width,
    required this.hits,
    required this.selected,
    required this.query,
    required this.onOpen,
    super.key,
  });

  final double width;
  final List<SearchHit> hits;
  final int selected;
  final String query;
  final ValueChanged<SearchHit> onOpen;

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
                query.isEmpty ? '输入关键词，搜索任务…' : '没有找到「$query」相关的结果',
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
                FootHint(['↑', '↓'], '选择'),
                SizedBox(width: PinSpace.s4),
                FootHint(['Enter'], '打开'),
                SizedBox(width: PinSpace.s4),
                FootHint(['Esc'], '关闭'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _grouped(BuildContext context) {
    final children = <Widget>[];
    var lastKind = SearchKind.task;
    var groupCount = 0;

    // 分组渲染：任务 / 清单与标签
    String labelFor(SearchKind k) => switch (k) {
          SearchKind.task => '任务',
          SearchKind.tag => '清单与标签',
        };

    for (var i = 0; i < hits.length; i++) {
      final hit = hits[i];
      if (i == 0 || hit.kind != lastKind) {
        if (i > 0) {
          children.add(GroupLabel('${labelFor(lastKind)} · $groupCount'));
        }
        lastKind = hit.kind;
        groupCount = 0;
      }
      groupCount += 1;
      children.add(_row(context, hit, i, query));
    }
    if (hits.isNotEmpty) {
      children.add(GroupLabel('${labelFor(lastKind)} · $groupCount'));
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _row(BuildContext context, SearchHit hit, int index, String query) {
    final spec = context.pin;
    final focus = index == selected;
    switch (hit.kind) {
      case SearchKind.task:
        final t = hit.task!;
        return ResultRow(
          focus: focus,
          onTap: () => onOpen(hit),
          leading: PinCheckbox(done: t.done),
          title: PinHighlightText(t.title, query: query),
          trailing: MetaText(
            '${t.done ? '已完成' : (t.listName ?? '任务')} · ${t.priority.label}',
          ),
        );
      case SearchKind.tag:
        final tag = hit.tag!;
        return ResultRow(
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
          trailing: const MetaText('标签'),
        );
    }
  }
}

/// 分组标题（.sd-group：margin 10 14 4、11px 加粗弱化色）
class GroupLabel extends StatelessWidget {
  const GroupLabel(this.label, {super.key});

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
class MetaText extends StatelessWidget {
  const MetaText(this.text, {super.key});

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
class ResultRow extends StatelessWidget {
  const ResultRow({
    required this.leading,
    required this.title,
    required this.trailing,
    required this.onTap,
    this.title2,
    this.focus = false,
    super.key,
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
class FootHint extends StatelessWidget {
  const FootHint(this.keys, this.label, {super.key});

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
