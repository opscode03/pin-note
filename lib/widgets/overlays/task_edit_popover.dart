/// 贴记 PinNote · 任务编辑弹层内容（对应 ui/task-edit.html .edit-pop）
///
/// 同时用于：
/// - `/task-edit` 路由屏（展示态）
/// - `showTaskEditDialog`（应用内浮层）
/// 「确定」保存到 TaskRepository、「删除」可撤销；取消 / Esc / 蒙层 = pop 不保存。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../data/demo.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../buttons.dart';
import '../calendar.dart';
import '../chips.dart';
import '../interactive.dart';
import '../toast.dart';

/// 标签候选池（「+」按钮按序取未使用的）
const List<String> kTagPool = ['#重要', '#设计', '#复盘', '#Q4', '#Q3'];

/// 任务编辑弹层内容
class TaskEditPopover extends StatefulWidget {
  const TaskEditPopover({super.key, required this.task, required this.width});

  final DemoTask task;
  final double width;

  @override
  State<TaskEditPopover> createState() => _TaskEditPopoverState();
}

class _TaskEditPopoverState extends State<TaskEditPopover> {
  late final TextEditingController _title;
  late PinPriority _priority;
  late List<String> _tags;
  int _dateIndex = 0;

  @override
  void initState() {
    super.initState();
    _title = TextEditingController(text: widget.task.title);
    _priority = widget.task.priority;
    _tags = List.of(widget.task.tags);
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  void _save(BuildContext context) {
    final title = _title.text.trim();
    TaskScope.of(context).updateTask(
      widget.task.id ?? widget.task.title,
      title: title.isEmpty ? widget.task.title : title,
      priority: _priority,
      tags: _tags,
    );
    showPinToast(context, title: '已保存修改', subtitle: title.isEmpty ? widget.task.title : title);
    Navigator.pop(context);
  }

  void _delete(BuildContext context) {
    final repo = TaskScope.of(context);
    final undo = repo.deleteTask(widget.task.id ?? widget.task.title);
    showPinToast(
      context,
      title: '已删除「${widget.task.title}」',
      subtitle: '30 天内可在回收站恢复',
      icon: PinIcons.trash,
      iconBg: context.pin.dangerTint,
      iconColor: context.pin.dangerStrong,
      actionLabel: undo != null ? '撤销' : null,
      onAction: undo?.restore,
    );
    Navigator.pop(context);
  }

  void _addTag() {
    final next = kTagPool.firstWhere(
      (t) => !_tags.contains(t),
      orElse: () => '',
    );
    if (next.isEmpty) return;
    setState(() => _tags.add(next));
  }

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    // .edit-pop 定宽但内容可滚动：矮窗口（<约 720 高）下不裁内容，
    // 最大高度跟随视口（对应 CSS 中弹层高于视口时浏览器自然裁切的行为取更优解）
    final maxHeight = MediaQuery.sizeOf(context).height - 64;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        width: widget.width,
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
              // 标题输入框（.field.ep-title-field：高 40、13px）
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
                    Expanded(
                      child: Material(
                        type: MaterialType.transparency,
                        child: TextField(
                          controller: _title,
                          style: spec.tsm,
                          cursorColor: spec.primary,
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 1.5, height: 16, color: spec.primary),
                  ],
                ),
              ),
              const EditFieldLabel('日期与时间', top: 14),
              Row(
                children: [
                  for (var i = 0; i < kDateChips.length; i++) ...[
                    if (i > 0) const SizedBox(width: PinSpace.s2),
                    EditQChip(kDateChips[i], on: _dateIndex == i,
                        onTap: () => setState(() => _dateIndex = i)),
                  ],
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
              const EditFieldLabel('优先级'),
              Row(
                children: [
                  for (final p in PinPriority.values) ...[
                    if (p != PinPriority.none) const SizedBox(width: 6),
                    Expanded(
                      child: EditPrioBox(
                        p.label,
                        icon: p == PinPriority.high ? PinIcons.flag : null,
                        on: _priority == p,
                        onTap: () => setState(() => _priority = p),
                      ),
                    ),
                  ],
                ],
              ),
              const EditFieldLabel('标签'),
              Wrap(
                spacing: PinSpace.s2,
                runSpacing: PinSpace.s2,
                children: [
                  for (var i = 0; i < _tags.length; i++)
                    EditTagChip(
                      _tags[i],
                      style: i.isEven ? PinChipStyle.violet : PinChipStyle.accent,
                      onRemove: () => setState(() => _tags.removeAt(i)),
                    ),
                  EditTagAdd(onTap: _addTag),
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
                    EditDeleteButton(onTap: () => _delete(context)),
                    const Spacer(),
                    PinButton(
                      '取消',
                      variant: PinButtonVariant.secondary,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: PinSpace.s2),
                    PinButton('确定', onTap: () => _save(context)),
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

/// 日期快捷选项（.qchip）
const List<String> kDateChips = ['今天', '明天', '后天', '下周一'];

/// 弹层小节标题（.ep-label：margin 16 0 7、11px 加粗弱化色）
class EditFieldLabel extends StatelessWidget {
  const EditFieldLabel(this.label, {super.key, this.top = 16});

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
class EditQChip extends StatelessWidget {
  const EditQChip(this.label, {super.key, this.on = false, this.onTap});

  final String label;
  final bool on;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: onTap,
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
class EditPrioBox extends StatelessWidget {
  const EditPrioBox(this.label, {super.key, this.icon, this.on = false, this.onTap});

  final String label;
  final PinIconData? icon;
  final bool on;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 32,
          decoration: BoxDecoration(
            color: on ? spec.dangerTint : spec.surface3,
            borderRadius: BorderRadius.circular(PinRadius.sm),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                PinIcon(icon!, size: 11, color: on ? spec.dangerStrong : spec.text2),
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
class EditTagChip extends StatelessWidget {
  const EditTagChip(
    this.label, {
    super.key,
    required this.style,
    this.onRemove,
  });

  final String label;
  final PinChipStyle style;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final Color bg;
    final Color fg;
    switch (style) {
      case PinChipStyle.accent:
        bg = spec.primaryTint;
        fg = spec.primaryStrong;
      case PinChipStyle.red:
        bg = spec.dangerTint;
        fg = spec.dangerStrong;
      case PinChipStyle.amber:
        bg = spec.warningTint;
        fg = spec.warningStrong;
      case PinChipStyle.green:
        bg = spec.successTint;
        fg = spec.successStrong;
      case PinChipStyle.violet:
        bg = spec.violetTint;
        fg = spec.violetStrong;
      case PinChipStyle.teal:
        bg = spec.tealTint;
        fg = spec.tealStrong;
      case PinChipStyle.neutral:
        bg = spec.surface3;
        fg = spec.text2;
    }
    return Container(
      height: 26,
      padding: const EdgeInsets.only(left: 10, right: 8),
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
              fontWeight: FontWeight.w600,
              color: fg,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: PinIcon(PinIcons.close, size: 7, color: fg),
          ),
        ],
      ),
    );
  }
}

/// 添加标签（.tag-add：34×26、虚线描边、加号）
class EditTagAdd extends StatelessWidget {
  const EditTagAdd({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) {
        final color = hover ? spec.primary : spec.lineStrong;
        return GestureDetector(
          onTap: onTap,
          child: CustomPaint(
            painter: EditDashedBorderPainter(
              radius: PinRadius.full,
              color: color,
              strokeWidth: 1.3,
            ),
            child: Container(
              width: 34,
              height: 26,
              alignment: Alignment.center,
              child: PinIcon(
                PinIcons.plus,
                size: 11,
                color: hover ? spec.primaryStrong : spec.faint,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// 虚线描边画笔（Flutter Border 不支持 dashed，按 CSS `dashed` 视觉复刻）
class EditDashedBorderPainter extends CustomPainter {
  const EditDashedBorderPainter({
    required this.radius,
    required this.color,
    required this.strokeWidth,
  });

  final double radius;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final path = editDashedRRectPath(
      size.width,
      size.height,
      radius,
      strokeWidth / 2,
    );
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color;
    for (final metric in path.computeMetrics()) {
      var start = 0.0;
      while (start < metric.length) {
        final end = math.min(start + 4, metric.length);
        canvas.drawPath(metric.extractPath(start, end), paint);
        start = end + 3;
      }
    }
  }

  @override
  bool shouldRepaint(EditDashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// 删除（.ep-del：旗标红、12px）
class EditDeleteButton extends StatelessWidget {
  const EditDeleteButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        child: Container(
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
Path editDashedRRectPath(double w, double h, double radius, double strokeHalf) {
  final inset = strokeHalf;
  return Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(inset, inset, w - inset * 2, h - inset * 2),
        Radius.circular(math.max(0, radius - inset)),
      ),
    );
}
