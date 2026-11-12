/// 贴记 PinNote · 今日（对应 ui/home.html）
library;

import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/dialogs.dart';
import '../app/navigation.dart';
import '../data/demo.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/chips.dart';
import '../widgets/controls.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_views.dart';
import '../widgets/toast.dart';

/// 主窗口三栏布局（220 侧栏 / 1fr 内容 / 340 详情，<1180 隐藏详情）
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showDetail = width >= 1180;

    // 徽标 / 分组随任务仓库变化
    return ListenableBuilder(
      listenable: TaskScope.of(context),
      builder: (context, _) {
        return PinAppWindow(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PinSidebar(items: _navItems(context)),
              const Expanded(child: _Content()),
              if (showDetail) const _DetailPanel(),
            ],
          ),
        );
      },
    );
  }
}

List<Object> _navItems(BuildContext context) {
  final repo = TaskScope.of(context);
  return [
    SidebarEntry(
      '今日',
      icon: PinIcons.calendar,
      badge: '${repo.today.length + repo.overdue.length}',
      selected: true,
      onTap: () {},
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
      badge: '${repo.done.length}',
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
    const SidebarEntry('学习', dotColor: PinListDots.study, badge: '6'),
    const SidebarEntry('阅读', dotColor: PinListDots.read, badge: '8'),
    const SidebarHeader('标签'),
    const SidebarEntry('重要', hashColor: Color(0xFFB32E2E)),
    const SidebarEntry('设计', hashColor: Color(0xFF2C52C8)),
    const SidebarEntry('复盘', hashColor: Color(0xFF08716A)),
    const SidebarEntry('新建清单', muted: true),
  ];
}

class _Content extends StatelessWidget {
  const _Content();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final repo = TaskScope.of(context);
    final overdue = repo.overdue;
    final today = repo.today;
    final done = repo.done;

    // 完成进度：子任务与任务数合并的演示口径
    final total = today.length + done.length + overdue.length;
    final doneCount = done.length;

    return Container(
      color: spec.bg,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PageHead(
              title: '今天',
              subtitle: '11月9日 星期一',
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PinRing(
                        value: total == 0 ? 0 : doneCount / total),
                    const SizedBox(width: PinSpace.s2),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '$doneCount/$total '),
                          TextSpan(
                            text: '已完成',
                            style: TextStyle(color: spec.text2),
                          ),
                        ],
                        style: TextStyle(
                          fontSize: PinFontSize.xs,
                          color: spec.text,
                          fontFamilyFallback: PinFont.sans,
                        ),
                      ),
                    ),
                  ],
                ),
                PinButton(
                  '新建任务',
                  icon: PinIcons.plus,
                  onTap: () => showTaskEditDialog<void>(context),
                ),
              ],
            ),
            QuickAdd(
              hint: '添加任务，输入 #标签 · !优先级 · 明天 9:00…',
              onTap: () => showQuickCaptureDialog<void>(context),
            ),
            if (overdue.isNotEmpty) ...[
              GroupHeader('已逾期', count: overdue.length,
                  color: spec.dangerStrong),
              for (final task in overdue)
                TaskRow(
                  task: task,
                  onTap: () => _openEdit(context, task),
                  onToggle: () => _toggle(context, task),
                ),
            ],
            GroupHeader('今天', count: today.length,
                color: spec.primaryStrong),
            for (final task in today)
              TaskRow(
                task: task,
                onTap: () => _openEdit(context, task),
                onToggle: () => _toggle(context, task),
              ),
            GroupHeader('已完成', count: done.length,
                color: spec.successStrong),
            for (final task in done)
              TaskRow(
                task: task,
                onTap: () => _openEdit(context, task),
                onToggle: () => _toggle(context, task),
              ),
            const SizedBox(height: PinSpace.s5),
          ],
        ),
      ),
    );
  }

  /// 打开编辑浮层：先选中（详情面板联动），再弹层
  void _openEdit(BuildContext context, DemoTask task) {
    TaskScope.of(context).select(task.id ?? task.title);
    showTaskEditDialog<void>(context);
  }

  /// 勾选完成 / 撤销：跨组移动 + Toast 反馈（5 秒可撤销）
  void _toggle(BuildContext context, DemoTask task) {
    final repo = TaskScope.of(context);
    repo.toggleDone(task.id ?? task.title);
    final nowDone = !task.done;
    showPinToast(
      context,
      title: nowDone ? '已完成「${task.title}」' : '已恢复「${task.title}」',
      subtitle: nowDone ? '可在已完成分组中查看' : '已移回原分组',
      actionLabel: '撤销',
      onAction: () => repo.toggleDone(task.id ?? task.title),
    );
  }
}

/// 任务详情面板（对应 .detail）：展示仓库当前选中任务
class _DetailPanel extends StatelessWidget {
  const _DetailPanel();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return ListenableBuilder(
      listenable: TaskScope.of(context),
      builder: (context, _) {
        final repo = TaskScope.of(context);
        final task = repo.resolveEditable();
        return Container(
          width: PinSize.detail,
          decoration: BoxDecoration(
            color: spec.surface,
            border: Border(left: BorderSide(color: spec.line)),
          ),
          child: task == null ? const _EmptyDetail() : _DetailBody(task: task),
        );
      },
    );
  }
}

/// 无选中任务
class _EmptyDetail extends StatelessWidget {
  const _EmptyDetail();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        PinIcon(PinIcons.check, size: 26, color: spec.faint),
        const SizedBox(height: PinSpace.s2),
        Text('没有选中的任务', style: spec.tsm.copyWith(color: spec.text2)),
      ],
    );
  }
}

/// 详情主体
class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.task});

  final DemoTask task;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final dateMeta = task.meta.isEmpty ? null : task.meta.first;
    final (subDone, subTotal) = task.progress ?? (0, 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 面板头
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 12, 0),
          child: Row(
            children: [
              Text(
                '任务详情',
                style: TextStyle(
                  fontSize: PinFontSize.xs2,
                  fontWeight: FontWeight.w600,
                  color: spec.faint,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
              const Spacer(),
              const PinIconButton(PinIcons.more, size: 28, iconSize: 15),
              PinIconButton(
                PinIcons.trash,
                size: 28,
                iconSize: 15,
                onTap: () {
                  final repo = TaskScope.of(context);
                  final undo = repo.deleteTask(task.id ?? task.title);
                  showPinToast(
                    context,
                    title: '已删除「${task.title}」',
                    subtitle: '30 天内可在回收站恢复',
                    icon: PinIcons.trash,
                    iconBg: spec.dangerTint,
                    iconColor: spec.dangerStrong,
                    actionLabel: undo != null ? '撤销' : null,
                    onAction: undo?.restore,
                  );
                },
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
          child: Text(
            task.title,
            style: spec.tlg.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        // 元信息卡
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding:
              const EdgeInsets.symmetric(horizontal: PinSpace.s4, vertical: 4),
          decoration: BoxDecoration(
            color: spec.surface,
            borderRadius: BorderRadius.circular(PinRadius.md),
            border: Border.all(color: spec.line),
          ),
          child: Column(
            children: [
              _metaRow(context, PinIcons.calendar, '日期',
                  _valueChip(context, dateMeta)),
              _metaRow(
                context,
                PinIcons.bell,
                '提醒',
                const PinChip('提前 30 分钟'),
              ),
              _metaRow(
                context,
                PinIcons.flag,
                '优先级',
                PinChip(task.priority.label,
                    style: switch (task.priority) {
                      PinPriority.high => PinChipStyle.red,
                      PinPriority.medium => PinChipStyle.amber,
                      PinPriority.low => PinChipStyle.teal,
                      PinPriority.none => PinChipStyle.neutral,
                    }),
              ),
              _metaRow(
                context,
                PinIcons.folder,
                '清单',
                Row(mainAxisSize: MainAxisSize.min, children: [
                  if (task.listColor != null)
                    Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: task.listColor,
                      ),
                    ),
                  const SizedBox(width: 7),
                  Text(task.listName ?? '—',
                      style: TextStyle(
                        fontSize: PinFontSize.xs,
                        color: spec.text,
                        fontFamilyFallback: PinFont.sans,
                      )),
                ]),
              ),
              _metaRow(
                context,
                PinIcons.tag,
                '标签',
                Wrap(
                  spacing: PinSpace.s2,
                  runSpacing: PinSpace.s1,
                  children: [
                    if (task.tags.isEmpty)
                      Text('—',
                          style: TextStyle(
                            fontSize: PinFontSize.xs,
                            color: spec.text2,
                            fontFamilyFallback: PinFont.sans,
                          ))
                    else
                      for (final tag in task.tags)
                        PinChip(tag, style: PinChipStyle.violet),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: PinSpace.s4),
        // 备注
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
          child: Text(
            '备注',
            style: TextStyle(
              fontSize: PinFontSize.xs2,
              fontWeight: FontWeight.w600,
              color: spec.faint,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '重点：竞品对比 · 数据指标 · 下季度规划',
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: spec.text,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ),
        const SizedBox(height: PinSpace.s5),
        // 子任务
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
          child: Row(
            children: [
              Text(
                '子任务',
                style: TextStyle(
                  fontSize: PinFontSize.xs2,
                  fontWeight: FontWeight.w600,
                  color: spec.faint,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
              const Spacer(),
              if (task.progress != null) ...[
                PinProgressBar(value: subTotal == 0 ? 0 : subDone / subTotal,
                    width: 60),
                const SizedBox(width: PinSpace.s2),
                Text(
                  '$subDone/$subTotal',
                  style: TextStyle(
                    fontSize: PinFontSize.xs2,
                    color: spec.text,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration:
              BoxDecoration(border: Border(top: BorderSide(color: spec.line))),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '创建于 11月7日 09:12 · 修改于 2 小时前',
                  style: TextStyle(
                    fontSize: PinFontSize.xs2,
                    color: spec.faint,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ),
              PinIcon(PinIcons.sync, size: 13, color: spec.faint),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metaRow(BuildContext context, PinIconData icon, String k, Widget value) {
    final spec = context.pin;
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          PinIcon(icon, size: 14, color: spec.faint),
          const SizedBox(width: 10),
          SizedBox(
            width: 40,
            child: Text(
              k,
              style: TextStyle(
                fontSize: PinFontSize.xs,
                color: spec.text2,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ),
          const SizedBox(width: 10),
          value,
        ],
      ),
    );
  }

  Widget _valueChip(BuildContext context, PinChipMeta? meta) {
    if (meta == null) {
      return Text('—',
          style: TextStyle(
            fontSize: PinFontSize.xs,
            color: context.pin.text2,
            fontFamilyFallback: PinFont.sans,
          ));
    }
    return PinChip(meta.label, style: meta.style, icon: meta.icon);
  }
}
