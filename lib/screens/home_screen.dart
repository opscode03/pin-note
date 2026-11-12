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
import '../widgets/interactive.dart';
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
                  onTap: () => showTaskEditDialog<void>(context),
                  onToggle: () => _toggle(context, task),
                ),
            ],
            GroupHeader('今天', count: today.length,
                color: spec.primaryStrong),
            for (final task in today)
              TaskRow(
                task: task,
                onTap: () => showTaskEditDialog<void>(context),
                onToggle: () => _toggle(context, task),
              ),
            GroupHeader('已完成', count: done.length,
                color: spec.successStrong),
            for (final task in done)
              TaskRow(
                task: task,
                onTap: () => showTaskEditDialog<void>(context),
                onToggle: () => _toggle(context, task),
              ),
            const SizedBox(height: PinSpace.s5),
          ],
        ),
      ),
    );
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

/// 任务详情面板（对应 .detail）
class _DetailPanel extends StatelessWidget {
  const _DetailPanel();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: PinSize.detail,
      decoration: BoxDecoration(
        color: spec.surface,
        border: Border(left: BorderSide(color: spec.line)),
      ),
      child: Column(
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
                  onTap: () => Navigator.pushNamed(context, '/empty-states'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
            child: Text(
              '设计评审材料准备',
              style: spec.tlg.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const _MetaCard(),
          const SizedBox(height: 16),
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
          const SizedBox(height: 22),
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
                const PinProgressBar(value: 0.5, width: 60),
                const SizedBox(width: PinSpace.s2),
                Text(
                  '2/4',
                  style: TextStyle(
                    fontSize: PinFontSize.xs2,
                    fontWeight: FontWeight.w400,
                    color: spec.text,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ],
            ),
          ),
          const _SubtaskRow('整理竞品分析', done: true),
          const _SubtaskRow('收集 Q3 数据', done: true),
          const _SubtaskRow('制作演示文稿'),
          const _SubtaskRow('请 Anna 核对数据'),
          HoverBuilder(
            builder: (context, hover, _) => GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/task-edit'),
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    PinIcon(
                      PinIcons.plus,
                      size: 13,
                      color: hover ? spec.text : spec.faint,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '添加子任务',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: hover ? spec.text2 : spec.faint,
                        fontFamilyFallback: PinFont.sans,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: spec.line)),
            ),
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
      ),
    );
  }
}

/// 元信息卡（对应 .meta-card）
class _MetaCard extends StatelessWidget {
  const _MetaCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    Widget row(PinIconData icon, String k, Widget value) {
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: PinSpace.s4, vertical: 4),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(color: spec.line),
      ),
      child: Column(
        children: [
          row(
            PinIcons.calendar,
            '日期',
            const PinChip('今天 14:00 - 15:00', icon: PinIcons.calendar),
          ),
          row(PinIcons.bell, '提醒', const PinChip('提前 30 分钟')),
          row(
            PinIcons.flag,
            '优先级',
            const PinChip('高', style: PinChipStyle.red),
          ),
          row(
            PinIcons.folder,
            '清单',
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: PinListDots.work,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  '工作',
                  style: TextStyle(
                    fontSize: PinFontSize.xs,
                    color: spec.text,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ],
            ),
          ),
          row(
            PinIcons.tag,
            '标签',
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PinChip('#设计', style: PinChipStyle.violet),
                SizedBox(width: PinSpace.s2),
                PinChip('#Q4'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 子任务行（对应 .subtask）
class _SubtaskRow extends StatelessWidget {
  const _SubtaskRow(this.label, {this.done = false});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          PinCheckbox(done: done, sm: true),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              color: done ? spec.text2 : spec.text,
              decoration: done ? TextDecoration.lineThrough : null,
              decorationColor: spec.faint,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ],
      ),
    );
  }
}
