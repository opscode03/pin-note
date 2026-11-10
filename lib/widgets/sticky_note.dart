/// 贴记 PinNote · 便签（对应 app.css .sticky 与 tokens.css --sticky-*）
///
/// 8 色（lemon/apricot/cherry/mint/sky/lavender/paper/night）、
/// 胶带（tape）、图钉（tack）、右下折角、便签色 Chip、清单行。
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';

/// 便签容器：底色、描边、折角、胶带 / 图钉装饰
class PinSticky extends StatelessWidget {
  const PinSticky({
    required this.color,
    required this.child,
    this.tape = false,
    this.tack = false,
    this.lift = false,
    this.padding = const EdgeInsets.all(18),
    this.radius = PinRadius.md,
    this.shadow,
    super.key,
  });

  final StickyColor color;
  final Widget child;
  final bool tape;
  final bool tack;
  final bool lift;
  final EdgeInsetsGeometry padding;
  final double radius;
  final List<BoxShadow>? shadow;

  StickyScheme get scheme => kStickySchemes[color]!;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final shadows = shadow ?? (lift ? spec.shadowLift : spec.shadowSm);

    return StickyScope(
      scheme: scheme,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: scheme.bg,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: scheme.line),
              boxShadow: shadows,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: tack ? 2 : 0),
                    child: child,
                  ),
                  // 右下折角 ::after
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: CustomPaint(
                      size: const Size(16, 16),
                      painter: _FoldPainter(scheme.fold),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (tape) const _Tape(),
          if (tack) const _Tack(),
        ],
      ),
    );
  }
}

class _FoldPainter extends CustomPainter {
  const _FoldPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_FoldPainter oldDelegate) => oldDelegate.color != color;
}

/// 半透明胶带（.sticky.tape::before）
class _Tape extends StatelessWidget {
  const _Tape();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -9,
      left: 0,
      right: 0,
      child: Center(
        child: Transform.rotate(
          angle: -1.5 * 3.1415926 / 180,
          child: Container(
            width: 72,
            height: 18,
            decoration: BoxDecoration(
              color: PinDecor.tape,
              borderRadius: BorderRadius.circular(2),
              boxShadow: const [
                BoxShadow(
                  offset: Offset(0, 1),
                  blurRadius: 2,
                  color: Color(0x140F172A), // rgba(15,23,42,.08)
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 红色图钉（.sticky.tack::before）
class _Tack extends StatelessWidget {
  const _Tack();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 15,
          height: 15,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              center: Alignment(-0.4, -0.4),
              radius: 1.1,
              colors: [Color(0xFFE46B6B), PinDecor.tackRed],
            ),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 2),
                blurRadius: 4,
                color: Color(0x59080E1C), // rgba(8,14,28,.35)
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 便签标题（.sticky-title）
class StickyTitle extends StatelessWidget {
  const StickyTitle(this.text, {this.fontSize, super.key});

  final String text;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final scheme = _schemeOf(context);
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize ?? PinFontSize.md,
        fontWeight: FontWeight.w700,
        color: scheme.ink,
        fontFamilyFallback: PinFont.sans,
      ),
    );
  }
}

/// 便签正文行（.s-line）
class StickyLine extends StatelessWidget {
  const StickyLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = _schemeOf(context);
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          height: 1.5,
          color: scheme.ink2,
          fontFamilyFallback: PinFont.sans,
        ),
      ),
    );
  }
}

/// 便签清单行（.s-check）
class StickyCheckRow extends StatelessWidget {
  const StickyCheckRow(this.text, {this.done = false, super.key});

  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = _schemeOf(context);
    final cbBorder = Color.lerp(scheme.ink, scheme.bg, 0.6)!;
    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? scheme.ink : Colors.transparent,
              border: Border.all(
                color: done ? scheme.ink : cbBorder,
                width: 1.5,
              ),
            ),
            child: done
                ? Center(
                    child: PinIcon(PinIcons.check, size: 8, color: scheme.bg),
                  )
                : null,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: done ? scheme.ink : scheme.ink2,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: Color.lerp(scheme.ink, scheme.bg, 0.45),
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 便签色小胶囊（.note-chip：底 = 45% 便签色 + 55% 白）
class PinNoteChip extends StatelessWidget {
  const PinNoteChip(this.label, {this.icon, super.key});

  final String label;
  final PinIconData? icon;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final scheme = _schemeOf(context);
    final bg = Color.lerp(scheme.bg, Colors.white, 0.55)!;
    return Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PinRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            PinIcon(icon!, size: 10, color: spec.primaryStrong),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: PinFontSize.xs2,
              fontWeight: FontWeight.w600,
              color: scheme.ink,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ],
      ),
    );
  }
}

/// 从组件树里最近的 PinSticky 取便签色方案
StickyScheme _schemeOf(BuildContext context) {
  final marker = context
      .dependOnInheritedWidgetOfExactType<_StickySchemeScope>();
  assert(marker != null, 'StickyTitle / StickyLine 需要放在 PinSticky 内');
  return marker!.scheme;
}

/// 便签色传播（PinSticky 的后代通过它拿到 scheme）
class _StickySchemeScope extends InheritedWidget {
  const _StickySchemeScope({required this.scheme, required super.child});

  final StickyScheme scheme;

  @override
  bool updateShouldNotify(_StickySchemeScope oldWidget) =>
      oldWidget.scheme != scheme;
}

/// 供 PinSticky 挂载 scheme（内部使用）
class StickyScope extends StatelessWidget {
  const StickyScope({required this.scheme, required this.child, super.key});

  final StickyScheme scheme;
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _StickySchemeScope(scheme: scheme, child: child);
}
