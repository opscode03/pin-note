/// 贴记 PinNote · 任务编辑弹层（对应 ui/task-edit.html）
///
/// 主窗口（今天列表 + 任务详情列）之上叠蒙层（.scrim）与居中编辑弹层（.edit-pop）：
/// 标题输入态、日期与时间快捷 Chips、迷你月历、时间 / 提醒 / 重复、
/// 优先级四选、标签、底部「删除 / 取消 / 确定」。
library;

import 'package:flutter/material.dart';

import '../data/demo.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../app/app_scope.dart';
import '../widgets/overlays/task_edit_popover.dart';
import '../widgets/chips.dart';
import '../widgets/sidebar.dart';
import '../widgets/task_views.dart';

/// 任务编辑页（task-edit.html：主窗口 + 蒙层 + 居中弹层）
class TaskEditScreen extends StatelessWidget {
  const TaskEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showDetail = width >= 1180; // .app-body.with-detail < 1180 隐藏详情列
    // .edit-pop { width: min(408px, 90vw) }
    final popWidth = width * 0.9 < 408 ? width * 0.9 : 408.0;

    return Stack(
      children: [
        PinAppWindow(
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PinSidebar(items: _navItems(context)),
              const Expanded(child: _TodayContent()),
              if (showDetail) const _DetailPanel(),
            ],
          ),
        ),
        // 蒙层（.scrim：rgba(15, 23, 42, 0.14)，设计稿写死色）
        const Positioned.fill(child: ColoredBox(color: Color(0x240F172A))),
        // 编辑弹层（.edit-pop：left 50% / top 52% 居中）
        Positioned.fill(
          child: Align(
            alignment: const Alignment(0, 0.04), // top: 52%
            child: TaskEditPopover(
              task: TaskScope.of(context).resolveEditable() ??
                  const DemoTask(title: '设计评审材料准备', selected: true),
              width: popWidth,
            ),
          ),
        ),
      ],
    );
  }
}

/// 侧栏（与 task-edit.html 一致：清单只有工作 / 生活，无标签区）
List<Object> _navItems(BuildContext context) {
  return [
    SidebarEntry(
      '今日',
      icon: PinIcons.calendar,
      badge: '5',
      selected: true,
      onTap: () => Navigator.pushNamed(context, '/'),
    ),
    SidebarEntry(
      '最近 7 天',
      icon: PinIcons.clock,
      badge: '12',
      onTap: () => Navigator.pushNamed(context, '/empty-states'),
    ),
    const SidebarEntry('全部', icon: PinIcons.layers, badge: '38'),
    SidebarEntry(
      '已完成',
      icon: PinIcons.check,
      onTap: () => Navigator.pushNamed(context, '/empty-states'),
    ),
    SidebarEntry(
      '便签库',
      icon: PinIcons.pin,
      badge: '8',
      onTap: () => Navigator.pushNamed(context, '/notes'),
    ),
    const SidebarHeader('清单'),
    const SidebarEntry('工作', dotColor: PinListDots.work, badge: '12'),
    const SidebarEntry('生活', dotColor: PinListDots.life, badge: '9'),
  ];
}

/// 今天列表（弹层背后的内容区，与 task-edit.html main.content 一致）
class _TodayContent extends StatelessWidget {
  const _TodayContent();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      color: spec.bg,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHead(title: '今天', subtitle: '11月9日 星期一'),
            GroupHeader('今天', count: 5, color: spec.primaryStrong),
            for (final task in _todayTasks) TaskRow(task: task),
            const SizedBox(height: PinSpace.s5),
          ],
        ),
      ),
    );
  }
}

/// task-edit.html 内容区展示的 3 条任务（首条选中）
const List<DemoTask> _todayTasks = [
  DemoTask(
    title: '设计评审材料准备',
    meta: [
      PinChipMeta('14:00', icon: PinIcons.clock),
      PinChipMeta('#设计', style: PinChipStyle.violet),
    ],
    selected: true,
  ),
  DemoTask(title: '整理 Q4 用户反馈'),
  DemoTask(title: '买猫粮'),
];

/// 任务详情列（.detail；task-edit.html 中未加 flex，底行不沉底）
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Text(
              '任务详情',
              style: spec.t2xs.copyWith(
                color: spec.faint,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              '设计评审材料准备',
              style: spec.tlg.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '创建于 11月7日 09:12 · 修改于 2 小时前',
              style: spec.t2xs.copyWith(color: spec.faint),
            ),
          ),
        ],
      ),
    );
  }
}
