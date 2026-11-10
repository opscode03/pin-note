/// 贴记 PinNote · 控件（对应 app.css .cb / .radio / .switch / .pbar / .ring / .seg）
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'interactive.dart';

/// 圆形复选框（对应 .cb，完成态绿色 + 白色对勾）
class PinCheckbox extends StatelessWidget {
  const PinCheckbox({this.done = false, this.sm = false, super.key});

  final bool done;
  final bool sm;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final size = sm ? 15.0 : 18.0;
    final hover = HoverScope.of(context);
    final borderColor = done
        ? spec.success
        : (hover ? spec.primary : spec.lineStrong);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: done ? spec.success : Colors.transparent,
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: done
          ? Center(
              child: PinIcon(
                PinIcons.check,
                size: sm ? 8 : 10,
                color: Colors.white,
              ),
            )
          : null,
    );
  }
}

/// 圆形单选（对应 .radio）
class PinRadio extends StatelessWidget {
  const PinRadio({this.on = false, super.key});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: 17,
      height: 17,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: on ? spec.primary : spec.lineStrong,
          width: 1.5,
        ),
      ),
      child: on
          ? Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: spec.primary,
                ),
              ),
            )
          : null,
    );
  }
}

/// 开关（对应 .switch，40×22）
class PinSwitch extends StatelessWidget {
  const PinSwitch({this.on = false, super.key});

  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return AnimatedContainer(
      duration: PinMotion.dur,
      curve: PinMotion.ease,
      width: 40,
      height: 22,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PinRadius.full),
        color: on ? spec.primary : spec.lineStrong,
      ),
      child: AnimatedAlign(
        duration: PinMotion.dur,
        curve: PinMotion.ease,
        alignment: on ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.all(3),
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 1),
                blurRadius: 2,
                color: Color(0x33000000),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 细进度条（对应 .pbar；默认 44×4，lg 120×6）
class PinProgressBar extends StatelessWidget {
  const PinProgressBar({
    required this.value,
    this.lg = false,
    this.width,
    super.key,
  });

  final double value; // 0.0 ~ 1.0
  final bool lg;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: width ?? (lg ? 120 : 44),
      height: lg ? 6 : 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: spec.line,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: spec.primary,
            ),
          ),
        ),
      ),
    );
  }
}

/// 进度环（对应 .ring；默认 26，lg 34；conic-gradient → 扫描弧）
class PinRing extends StatelessWidget {
  const PinRing({required this.value, this.lg = false, super.key});

  final double value; // 0.0 ~ 1.0
  final bool lg;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final size = lg ? 34.0 : 26.0;
    final inner = lg ? 24.0 : 18.0;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value: value.clamp(0.0, 1.0),
          track: spec.line,
          color: spec.primary,
        ),
        child: Center(
          child: Container(
            width: inner,
            height: inner,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spec.surface,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.track, required this.color});

  final double value;
  final Color track;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2;
    canvas.drawCircle(c, r, Paint()..color = track);
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      2 * math.pi * value,
      true,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value || oldDelegate.color != color;
}

/// 分段控件（对应 .seg / .seg-item）
class PinSeg extends StatelessWidget {
  const PinSeg({
    required this.items,
    required this.onIndex,
    this.onChanged,
    super.key,
  });

  final List<String> items;
  final int onIndex;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: spec.surface3,
        borderRadius: BorderRadius.circular(PinRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++)
            _SegItem(
              label: items[i],
              on: i == onIndex,
              onTap: () => onChanged?.call(i),
            ),
        ],
      ),
    );
  }
}

class _SegItem extends StatefulWidget {
  const _SegItem({required this.label, required this.on, this.onTap});

  final String label;
  final bool on;
  final VoidCallback? onTap;

  @override
  State<_SegItem> createState() => _SegItemState();
}

class _SegItemState extends State<_SegItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final on = widget.on;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: PinMotion.dur,
          curve: PinMotion.ease,
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: on ? spec.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: on ? spec.shadowSm : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                fontSize: PinFontSize.xs,
                fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                color: on ? spec.text : (_hover ? spec.text : spec.text2),
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
