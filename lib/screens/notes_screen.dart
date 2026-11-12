/// 贴记 PinNote · 便签库（对应 ui/notes.html）
library;

import 'package:flutter/material.dart';

import '../data/demo.dart';
import '../app/navigation.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/interactive.dart';
import '../widgets/sidebar.dart';
import '../widgets/sticky_note.dart';
import '../widgets/task_views.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PinAppWindow(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PinSidebar(items: _navItems(context)),
          Expanded(child: _NotesContent()),
        ],
      ),
    );
  }
}

List<Object> _navItems(BuildContext context) {
  return [
    SidebarEntry(
      '今日',
      icon: PinIcons.calendar,
      badge: '5',
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
    const SidebarEntry('便签库', icon: PinIcons.pin, badge: '8', selected: true),
    const SidebarHeader('清单'),
    const SidebarEntry('收件箱', dotColor: PinListDots.inbox, badge: '3'),
    const SidebarEntry('工作', dotColor: PinListDots.work, badge: '12'),
    const SidebarEntry('生活', dotColor: PinListDots.life, badge: '9'),
    const SidebarEntry('学习', dotColor: PinListDots.study, badge: '6'),
    const SidebarEntry('阅读', dotColor: PinListDots.read, badge: '8'),
    const SidebarHeader('标签'),
    const SidebarEntry('重要', hashColor: Color(0xFFB32E2E)),
    const SidebarEntry('设计', hashColor: Color(0xFF2C52C8)),
    const SidebarEntry('复盘', hashColor: Color(0xFF08716A)),
    const SidebarEntry('新建清单', muted: true),
  ];
}

class _NotesContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      color: spec.bg,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHead(
              title: '便签库',
              subtitle: '8 张便签 · 3 张贴在桌面',
              actions: [
                // 网格 / 列表切换（.seg 内嵌 icon-btn）
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: spec.surface3,
                    borderRadius: BorderRadius.circular(PinRadius.sm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PinIconButton(
                        PinIcons.gridView,
                        size: 28,
                        iconSize: 13,
                        active: true,
                      ),
                      PinIconButton(PinIcons.listView, size: 28, iconSize: 13),
                    ],
                  ),
                ),
                PinButton(
                  '新建便签',
                  icon: PinIcons.plus,
                  onTap: () => AppNav.go(context, '/note-editor'),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                PinSpace.s6,
                10,
                PinSpace.s6,
                PinSpace.s6,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const minCard = 290.0;
                  const gap = PinSpace.s4;
                  final cols = (constraints.maxWidth / (minCard + gap))
                      .floor()
                      .clamp(1, 6);
                  final cardWidth =
                      (constraints.maxWidth - gap * (cols - 1)) / cols;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final note in kDemoNotes)
                        SizedBox(
                          width: cardWidth,
                          child: _NoteCard(note: note),
                        ),
                      SizedBox(width: cardWidth, child: const _AddCard()),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 便签卡片（对应 .ncard）
class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note});

  final DemoNote note;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final scheme = kStickySchemes[note.color]!;
    return HoverBuilder(
      builder: (context, hover, _) {
        return GestureDetector(
          onTap: () => AppNav.go(context, '/note-editor'),
          child: AnimatedContainer(
            duration: PinMotion.dur,
            curve: PinMotion.ease,
            transform: Matrix4.translationValues(0, hover ? -2 : 0, 0),
            child: PinSticky(
              color: note.color,
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
              shadow: hover ? spec.shadowFar : spec.shadowSm,
              // .ncard min-height 188：内容不足时底部行贴底（margin-top auto）
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 188),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 标题行
                      Row(
                        children: [
                          StickyTitle(note.title),
                          if (note.locked) ...[
                            const SizedBox(width: 6),
                            PinIcon(
                              PinIcons.lock,
                              size: 13,
                              color: scheme.ink2,
                            ),
                          ],
                          if (note.pinned) ...[
                            const SizedBox(width: 8),
                            const PinNoteChip('桌面', icon: PinIcons.pin),
                          ],
                          const Spacer(),
                          PinIcon(PinIcons.more, size: 13, color: scheme.ink2),
                        ],
                      ),
                      ...[
                        for (final (label, done) in note.checks)
                          StickyCheckRow(label, done: done),
                        for (final line in note.lines) StickyLine(line),
                      ],
                      const Spacer(),
                      // 底部：标签 + 时间
                      SizedBox(
                        height: 20,
                        child: Row(
                          children: [
                            if (note.tag != null) PinNoteChip(note.tag!),
                            const Spacer(),
                            Text(
                              note.time,
                              style: TextStyle(
                                fontSize: PinFontSize.xs2,
                                color: scheme.ink2,
                                fontFamilyFallback: PinFont.sans,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 新建便签虚线卡（对应 .add-card）
class _AddCard extends StatelessWidget {
  const _AddCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) {
        final color = hover ? spec.primaryStrong : spec.faint;
        return GestureDetector(
          onTap: () => AppNav.go(context, '/note-editor'),
          child: Container(
            height: 188,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PinRadius.md),
              border: Border.all(
                color: hover ? spec.primary : spec.lineStrong,
                width: 1.5,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PinIcon(PinIcons.plus, size: 26, color: color),
                const SizedBox(height: 10),
                Text(
                  '新建便签',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: color,
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
