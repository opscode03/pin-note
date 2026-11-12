/// 贴记 PinNote · 任务视图组件（对应 app.css .page-head / .quick-add / .group-h / .task）
library;

import 'package:flutter/material.dart';

import '../data/demo.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'chips.dart';
import 'controls.dart';
import 'interactive.dart';

/// 页头（对应 .page-head：标题 + 日期 + 右侧动作）
class PageHead extends StatelessWidget {
  const PageHead({required this.title, this.subtitle, this.actions, super.key});

  final String title;
  final String? subtitle;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        PinSpace.s6,
        PinSpace.s5,
        PinSpace.s6,
        4,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: spec.t2xl.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.22,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: PinSpace.s3),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                subtitle!,
                style: spec.txs.copyWith(color: spec.text2),
              ),
            ),
          ],
          const Spacer(),
          if (actions != null) ...[
            for (var i = 0; i < actions!.length; i++) ...[
              if (i > 0) const SizedBox(width: PinSpace.s3),
              actions![i],
            ],
          ],
        ],
      ),
    );
  }
}

/// 快速添加（对应 .quick-add）
class QuickAdd extends StatelessWidget {
  const QuickAdd({required this.hint, this.onTap, super.key});

  final String hint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          margin: const EdgeInsets.fromLTRB(
            PinSpace.s6,
            PinSpace.s3,
            PinSpace.s6,
            4,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: spec.surface,
            borderRadius: BorderRadius.circular(PinRadius.md),
            border: Border.all(color: hover ? spec.primary : spec.line),
          ),
          child: Row(
            children: [
              const PinCheckbox(),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  hint,
                  style: spec.tsm.copyWith(color: spec.faint),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 10),
              PinIcon(PinIcons.enter, color: spec.text2),
            ],
          ),
        ),
      ),
    );
  }
}

/// 分组标题（对应 .group-h：文字 + 撑满的细线）
class GroupHeader extends StatelessWidget {
  const GroupHeader(
    this.label, {
    required this.count,
    required this.color,
    super.key,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Padding(
      padding: const EdgeInsets.fromLTRB(PinSpace.s6, 20, PinSpace.s6, 6),
      child: Row(
        children: [
          Text(
            label,
            style: spec.txs.copyWith(fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 7),
          Text(
            '$count',
            style: spec.txs.copyWith(fontWeight: FontWeight.w600, color: color),
          ),
          const SizedBox(width: 7),
          Expanded(child: Divider(height: 1, thickness: 1, color: spec.line)),
        ],
      ),
    );
  }
}

/// 任务行（对应 .task）
class TaskRow extends StatelessWidget {
  const TaskRow({
    required this.task,
    this.onTap,
    this.onToggle,
    this.trailing,
    super.key,
  });

  final DemoTask task;
  final VoidCallback? onTap;

  /// 勾选区独立命中：点击复选框 = 完成 / 撤销（不进编辑弹层）
  final VoidCallback? onToggle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) {
        final selected = task.selected;
        final bg = selected
            ? spec.selBg
            : (hover ? spec.hover : Colors.transparent);
        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: PinSpace.s5),
            padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(PinRadius.md),
            ),
            foregroundDecoration: selected
                ? BoxDecoration(
                    borderRadius: BorderRadius.circular(PinRadius.md),
                  )
                : null,
            child: IntrinsicHeight(
              child: Stack(
                children: [
                  if (selected)
                    Positioned(
                      left: -12,
                      top: 10,
                      bottom: 10,
                      child: Container(
                        width: 3,
                        decoration: BoxDecoration(
                          color: spec.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: onToggle,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: PinCheckbox(done: task.done),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: _main(context)),
                      if (trailing != null || task.listName != null)
                        Center(child: trailing ?? _listName(context)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _main(BuildContext context) {
    final spec = context.pin;
    final children = <Widget>[
      Text(
        task.title,
        style: spec.tsm.copyWith(
          height: 1.4,
          color: task.done ? spec.text2 : spec.text,
          decoration: task.done ? TextDecoration.lineThrough : null,
          decorationColor: spec.faint,
        ),
      ),
    ];
    final meta = <Widget>[];
    for (final m in task.meta) {
      meta.add(PinChip(m.label, style: m.style, icon: m.icon));
    }
    if (task.flagHigh) {
      meta.add(PinFlag('高', color: spec.dangerStrong));
    }
    if (task.progress != null) {
      final (done, total) = task.progress!;
      meta.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PinProgressBar(value: done / total),
            const SizedBox(width: 6),
            Text(
              '$done/$total',
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
    if (meta.isNotEmpty) {
      children.add(const SizedBox(height: 5));
      children.add(
        Wrap(spacing: PinSpace.s2, runSpacing: PinSpace.s1, children: meta),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  Widget _listName(BuildContext context) {
    final spec = context.pin;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (task.listColor != null) ...[
          Container(
            width: 9,
            height: 9,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.listColor,
            ),
          ),
          const SizedBox(width: 2),
        ],
        Text(
          task.listName ?? '',
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            color: spec.text2,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}
