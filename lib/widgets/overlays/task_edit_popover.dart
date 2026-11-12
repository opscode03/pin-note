/// 贴记 PinNote · 任务编辑弹层内容（对应 ui/task-edit.html .edit-pop）
///
/// 同时用于：
/// - `/task-edit` 路由屏（展示态）
/// - `showTaskEditDialog`（应用内浮层）
/// 确定 / 取消 / 删除均为 Navigator.pop —— 在浮层中关浮层、在路由屏中退回上一屏。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../buttons.dart';
import '../calendar.dart';
import '../chips.dart';
import '../interactive.dart';

/// 任务编辑弹层内容
/// 编辑弹层（.edit-pop：padding 20、圆角 14、远阴影）
class TaskEditPopover extends StatelessWidget {
  const TaskEditPopover({super.key, required this.width});

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
              const EditFieldLabel('日期与时间', top: 14),
              const Row(
                children: [
                  EditQChip('今天', on: true),
                  SizedBox(width: PinSpace.s2),
                  EditQChip('明天'),
                  SizedBox(width: PinSpace.s2),
                  EditQChip('后天'),
                  SizedBox(width: PinSpace.s2),
                  EditQChip('下周一'),
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
              const Row(
                children: [
                  Expanded(child: EditPrioBox('无')),
                  SizedBox(width: 6),
                  Expanded(child: EditPrioBox('低')),
                  SizedBox(width: 6),
                  Expanded(child: EditPrioBox('中')),
                  SizedBox(width: 6),
                  Expanded(child: EditPrioBox('高', icon: PinIcons.flag, on: true)),
                ],
              ),
              const EditFieldLabel('标签'),
              const Row(
                children: [
                  EditTagChip('#设计', style: PinChipStyle.violet),
                  SizedBox(width: PinSpace.s2),
                  EditTagChip('#Q4', style: PinChipStyle.accent),
                  SizedBox(width: PinSpace.s2),
                  EditTagAdd(),
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
                    const EditDeleteButton(),
                    const Spacer(),
                    PinButton(
                      '取消',
                      variant: PinButtonVariant.secondary,
                      onTap: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: PinSpace.s2),
                    PinButton(
                      '确定',
                      onTap: () => Navigator.pop(context),
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
  const EditQChip(this.label, {super.key, this.on = false});

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
class EditPrioBox extends StatelessWidget {
  const EditPrioBox(this.label, {super.key, this.icon, this.on = false});

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
class EditTagChip extends StatelessWidget {
  const EditTagChip(this.label, {super.key, required this.style});

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
class EditTagAdd extends StatelessWidget {
  const EditTagAdd({super.key});

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
            painter: EditDashedBorderPainter(
              path: editDashedRRectPath(34, 26, 13, 0.65),
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
class EditDeleteButton extends StatelessWidget {
  const EditDeleteButton({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: () => Navigator.pop(context),
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
Path editDashedRRectPath(double w, double h, double radius, double strokeHalf) {
  final inset = strokeHalf;
  return Path()..addRRect(
    RRect.fromRectAndRadius(
      Rect.fromLTWH(inset, inset, w - inset * 2, h - inset * 2),
      Radius.circular(math.max(0, radius - inset)),
    ),
  );
}

/// 虚线描边画笔（Flutter Border 不支持 dashed，按 CSS `dashed` 视觉复刻）
class EditDashedBorderPainter extends CustomPainter {
  const EditDashedBorderPainter({
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
  bool shouldRepaint(EditDashedBorderPainter oldDelegate) =>
      oldDelegate.path != path ||
      oldDelegate.color != color ||
      oldDelegate.width != width;
}
