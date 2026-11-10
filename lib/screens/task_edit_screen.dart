/// 贴记 PinNote · 任务编辑弹层（对应 ui/task-edit.html）
///
/// 主窗口（今天列表 + 任务详情列）之上叠蒙层（.scrim）与居中编辑弹层（.edit-pop）：
/// 标题输入态、日期与时间快捷 Chips、迷你月历、时间 / 提醒 / 重复、
/// 优先级四选、标签、底部「删除 / 取消 / 确定」。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/demo.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/calendar.dart';
import '../widgets/chips.dart';
import '../widgets/interactive.dart';
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
            child: _EditPopover(width: popWidth),
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

/// 编辑弹层（.edit-pop：padding 20、圆角 14、远阴影）
class _EditPopover extends StatelessWidget {
  const _EditPopover({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    // .edit-pop 定宽但内容可滚动：矮窗口（<约 720 高）下不裁内容，
    // 最大高度跟随视口（对应 CSS 中弹层高于视口时浏览器自然裁切的行为取更优解）
    final maxHeight = MediaQuery.sizeOf(context).height - 64;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: spec.surface,
          borderRadius: BorderRadius.circular(PinRadius.lg),
          border: Border.all(color: spec.line),
          boxShadow: spec.shadowFar,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 标题输入框（.field.ep-title-field：高 40、13px，聚焦光标）
              Container(
                height: 40,
                padding: const EdgeInsets.symmetric(horizontal: PinSpace.s3),
                decoration: BoxDecoration(
                  color: spec.surface,
                  borderRadius: BorderRadius.circular(PinRadius.sm),
                  border: Border.all(color: spec.lineStrong),
                ),
                child: Row(
                  children: [
                    Text('设计评审材料准备', style: spec.tsm),
                    // .field gap 8px + 光标 margin-left 4px
                    const SizedBox(width: 12),
                    Container(width: 1.5, height: 16, color: spec.primary),
                  ],
                ),
              ),
              const _FieldLabel('日期与时间', top: 14),
              const Row(
                children: [
                  _QChip('今天', on: true),
                  SizedBox(width: PinSpace.s2),
                  _QChip('明天'),
                  SizedBox(width: PinSpace.s2),
                  _QChip('后天'),
                  SizedBox(width: PinSpace.s2),
                  _QChip('下周一'),
                ],
              ),
              // 迷你月历（.cal，2026 年 11 月：前置 10 月 26-31、今天 9 日）
              const SizedBox(height: PinSpace.s3),
              const MiniCalendar(
                year: 2026,
                month: 11,
                leadingBlanks: 6,
                dayCount: 30,
                today: 9,
              ),
              // 时间 / 提醒 / 重复（.time-row：flex-wrap，窄弹层内自动换行）
              const SizedBox(height: 10),
              const Wrap(
                spacing: PinSpace.s2,
                runSpacing: PinSpace.s2,
                children: [
                  PinChip(
                    '14:00 - 15:00',
                    icon: PinIcons.clock,
                    size: PinChipSize.lg,
                  ),
                  PinChip(
                    '提前 30 分钟',
                    icon: PinIcons.bell,
                    size: PinChipSize.lg,
                  ),
                  PinChip(
                    '每天',
                    icon: PinIcons.repeat,
                    style: PinChipStyle.teal,
                    size: PinChipSize.lg,
                  ),
                ],
              ),
              const _FieldLabel('优先级'),
              const Row(
                children: [
                  Expanded(child: _PrioBox('无')),
                  SizedBox(width: 6),
                  Expanded(child: _PrioBox('低')),
                  SizedBox(width: 6),
                  Expanded(child: _PrioBox('中')),
                  SizedBox(width: 6),
                  Expanded(child: _PrioBox('高', icon: PinIcons.flag, on: true)),
                ],
              ),
              const _FieldLabel('标签'),
              const Row(
                children: [
                  _TagChip('#设计', style: PinChipStyle.violet),
                  SizedBox(width: PinSpace.s2),
                  _TagChip('#Q4', style: PinChipStyle.accent),
                  SizedBox(width: PinSpace.s2),
                  _TagAdd(),
                ],
              ),
              // 底部（.ep-foot：margin-top 18、上分割线）
              Container(
                margin: const EdgeInsets.only(top: 18),
                padding: const EdgeInsets.only(top: 14),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: spec.line)),
                ),
                child: Row(
                  children: [
                    const _DeleteButton(),
                    const Spacer(),
                    PinButton(
                      '取消',
                      variant: PinButtonVariant.secondary,
                      onTap: () => Navigator.pushNamed(context, '/'),
                    ),
                    const SizedBox(width: PinSpace.s2),
                    PinButton(
                      '确定',
                      onTap: () => Navigator.pushNamed(context, '/'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 弹层小节标题（.ep-label：margin 16 0 7、11px 加粗弱化色）
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.label, {this.top = 16});

  final String label;
  final double top;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Padding(
      padding: EdgeInsets.fromLTRB(0, top, 0, 7),
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

/// 日期快捷 Chip（.qchip：高 26、radius 13；on 态主色 tint）
class _QChip extends StatelessWidget {
  const _QChip(this.label, {this.on = false});

  final String label;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: () {},
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: on ? spec.primaryTint : spec.surface3,
            borderRadius: BorderRadius.circular(PinRadius.full),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: PinFontSize.xs,
              fontWeight: on ? FontWeight.w700 : FontWeight.w400,
              color: on ? spec.primaryStrong : spec.text2,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ),
      ),
    );
  }
}

/// 优先级选项（.prio：撑满、高 32；on 态红色 tint + 旗标）
class _PrioBox extends StatelessWidget {
  const _PrioBox(this.label, {this.icon, this.on = false});

  final String label;
  final PinIconData? icon;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: () {},
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: on ? spec.dangerTint : spec.surface3,
            borderRadius: BorderRadius.circular(PinRadius.sm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                PinIcon(icon!, size: 11, color: spec.dangerStrong),
                const SizedBox(width: 5),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: PinFontSize.xs,
                  fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                  color: on ? spec.dangerStrong : spec.text2,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 标签 Chip（.chip-lg + 7px 关闭叉；PinChip 不支持自定义叉号尺寸，按 HTML 复刻）
class _TagChip extends StatelessWidget {
  const _TagChip(this.label, {required this.style});

  final String label;
  final PinChipStyle style;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final Color bg;
    final Color fg;
    switch (style) {
      case PinChipStyle.accent:
        bg = spec.primaryTint;
        fg = spec.primaryStrong;
      case PinChipStyle.violet:
        bg = spec.violetTint;
        fg = spec.violetStrong;
      default:
        bg = spec.surface3;
        fg = spec.text2;
    }
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: () {},
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(PinRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: PinFontSize.xs,
                  color: fg,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
              const SizedBox(width: 6),
              PinIcon(PinIcons.close, size: 7, color: fg), // .chip .x { 7px }
            ],
          ),
        ),
      ),
    );
  }
}

/// 添加标签（.tag-add：34×26、虚线描边、加号）
class _TagAdd extends StatelessWidget {
  const _TagAdd();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: () {},
        child: SizedBox(
          width: 34,
          height: 26,
          child: CustomPaint(
            painter: _DashedBorderPainter(
              path: _dashedRRectPath(34, 26, 13, 0.65),
              color: spec.lineStrong,
              width: 1.3,
            ),
            child: Center(
              child: PinIcon(PinIcons.plus, size: 11, color: spec.faint),
            ),
          ),
        ),
      ),
    );
  }
}

/// 删除（.ep-del：旗标红、12px）
class _DeleteButton extends StatelessWidget {
  const _DeleteButton();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/empty-states'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinIcon(
                PinIcons.trash,
                size: 12,
                color: hover ? spec.danger : spec.dangerStrong,
              ),
              const SizedBox(width: 6),
              Text(
                '删除',
                style: TextStyle(
                  fontSize: PinFontSize.xs,
                  color: hover ? spec.danger : spec.dangerStrong,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 计算内缩后的虚线圆角矩形路径（描边宽一半内缩，保证不出界）
Path _dashedRRectPath(double w, double h, double radius, double strokeHalf) {
  final inset = strokeHalf;
  return Path()..addRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, w - inset * 2, h - inset * 2),
      Radius.circular(math.max(0, radius - inset)),
    ),
  );
}

/// 虚线描边画笔（Flutter Border 不支持 dashed，按 CSS `dashed` 视觉复刻）
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.path,
    required this.color,
    required this.width,
  });

  final Path path;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    for (final metric in path.computeMetrics()) {
      var start = 0.0;
      while (start < metric.length) {
        final end = math.min(start + 4, metric.length);
        canvas.drawPath(metric.extractPath(start, end), p);
        start = end + 3;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      oldDelegate.path != path ||
      oldDelegate.color != color ||
      oldDelegate.width != width;
}
