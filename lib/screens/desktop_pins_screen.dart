/// 贴记 PinNote · 桌面贴总览（对应 ui/desktop-pins.html）
///
/// 模拟 Windows 桌面：壁纸 + 桌面贴（胶带/图钉便签、待办卡、倒计时）+ 任务栏。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/chips.dart';
import '../widgets/controls.dart';
import '../widgets/interactive.dart';
import '../widgets/scene.dart';
import '../widgets/sticky_note.dart';

class DesktopPinsScreen extends StatelessWidget {
  const DesktopPinsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WallpaperScene(
      variant: 'a',
      child: Stack(
        children: [
          // 回收站
          const Positioned(left: 36, top: 26, child: _Bin()),
          // 网格吸附区 + 拖拽虚影
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, c) {
                return Stack(
                  children: [
                    Positioned(
                      left: c.maxWidth * 0.56,
                      top: c.maxHeight * 0.50,
                      width: c.maxWidth * 0.31,
                      height: c.maxHeight * 0.40,
                      child: const _SnapZone(),
                    ),
                    Positioned(
                      left: c.maxWidth * 0.625,
                      top: c.maxHeight * 0.58,
                      child: const _DragGhost(width: 235, height: 200),
                    ),
                  ],
                );
              },
            ),
          ),
          // 柠檬黄 · 胶带便签
          _ScenePosition(
            leftPct: 0.045,
            topPct: 0.12,
            width: 280,
            rotateDeg: -2,
            draggable: true,
            child: _BirthdayNote(),
          ),
          // 今日待办卡
          const _ScenePosition(
            leftPct: 0.29,
            topPct: 0.085,
            width: 296,
            child: _TodayCard(),
          ),
          // 樱花粉 · 图钉便签（品牌口号）
          const _ScenePosition(
            leftPct: 0.57,
            topPct: 0.11,
            width: 248,
            rotateDeg: 3,
            child: _QuoteNote(),
          ),
          // 倒计时卡
          const _ScenePosition(
            leftPct: 0.765,
            topPct: 0.12,
            width: 212,
            child: _CountdownCard(),
          ),
          // 薄荷绿 · 图钉便签（健身打卡）
          const _ScenePosition(
            leftPct: 0.26,
            topPct: 0.55,
            width: 280,
            rotateDeg: -1.5,
            child: _FitnessNote(),
          ),
          // 柠檬黄 · 胶带便签（午饭灵感，悬浮）
          const _ScenePosition(
            leftPct: 0.595,
            topPct: 0.52,
            width: 235,
            rotateDeg: 4,
            child: _LunchNote(),
          ),
          // 任务栏
          const PinTaskbar(activeAppIndex: 2),
        ],
      ),
    );
  }
}

/// 按百分比定位 + 可旋转的场景元素（[draggable] 时可拖拽移动）
class _ScenePosition extends StatelessWidget {
  const _ScenePosition({
    required this.leftPct,
    required this.topPct,
    required this.width,
    required this.child,
    this.rotateDeg,
    this.draggable = false,
  });

  final double leftPct;
  final double topPct;
  final double width;
  final double? rotateDeg;
  final Widget child;
  final bool draggable;

  @override
  Widget build(BuildContext context) {
    Widget w = SizedBox(width: width, child: child);
    if (rotateDeg != null) {
      w = Transform.rotate(
        angle: rotateDeg! * math.pi / 180,
        alignment: Alignment.center,
        child: w,
      );
    }
    if (draggable) {
      w = _DraggableSceneElement(child: w);
    }
    return Positioned.fill(
      child: Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: EdgeInsets.only(
            left: MediaQuery.sizeOf(context).width * leftPct,
            top: MediaQuery.sizeOf(context).height * topPct,
          ),
          child: w,
        ),
      ),
    );
  }
}

/// 可拖拽场景元素：Pan 手势累积偏移，move 光标
class _DraggableSceneElement extends StatefulWidget {
  const _DraggableSceneElement({required this.child});

  final Widget child;

  @override
  State<_DraggableSceneElement> createState() => _DraggableSceneElementState();
}

class _DraggableSceneElementState extends State<_DraggableSceneElement> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.move,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _offset += d.delta),
        child: Transform.translate(offset: _offset, child: widget.child),
      ),
    );
  }
}

/// 回收站图标
class _Bin extends StatelessWidget {
  const _Bin();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PinIcon(PinIcons.trash, size: 26, color: Color(0xE6D2D9E4)),
        const SizedBox(height: 6),
        Text(
          '回收站',
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            color: const Color(0xFFD2D9E4).withValues(alpha: 0.9),
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}

/// 网格吸附区（对应 .snap）
class _SnapZone extends StatelessWidget {
  const _SnapZone();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PinRadius.md),
        // radial-gradient(rgba(255,255,255,.14) 1px, transparent 1px) 22px
        color: const Color(0x00000000),
      ),
      child: CustomPaint(
        painter: _DotPainter(
          dot: Colors.white.withValues(alpha: 0.14),
          spacing: 22,
        ),
      ),
    );
  }
}

class _DotPainter extends CustomPainter {
  const _DotPainter({required this.dot, required this.spacing});

  final Color dot;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dot;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotPainter oldDelegate) =>
      oldDelegate.dot != dot || oldDelegate.spacing != spacing;
}

/// 拖拽虚影（对应 .ghost）
class _DragGhost extends StatelessWidget {
  const _DragGhost({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
    );
  }
}

/// 「给妈妈订生日蛋糕」便签
class _BirthdayNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const PinSticky(
      color: StickyColor.lemon,
      tape: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickyTitle('给妈妈订生日蛋糕'),
          StickyLine('本周五之前 · 8 寸 · 少糖'),
          StickyLine('卡片写：『岁岁平安』'),
          SizedBox(height: 16),
          PinNoteChip('11月13日 周五', icon: PinIcons.clock),
        ],
      ),
    );
  }
}

/// 今日待办白卡（对应 .tcard）
class _TodayCard extends StatelessWidget {
  const _TodayCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: () => AppNav.go(context, '/'),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 15, 18, 15),
          decoration: BoxDecoration(
            color: spec.surface,
            borderRadius: BorderRadius.circular(PinRadius.md),
            border: Border.all(color: const Color(0xFFE8ECF2)),
            boxShadow: spec.shadowFar,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '今日待办',
                    style: spec.tmd.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  const PinRing(value: 0.25),
                  const SizedBox(width: PinSpace.s2),
                  Text(
                    '1/4',
                    style: TextStyle(
                      fontSize: PinFontSize.xs2,
                      color: spec.text2,
                      fontFamilyFallback: PinFont.sans,
                    ),
                  ),
                ],
              ),
              const _TodoRow('回复张总邮件', done: true),
              const _TodoRow('设计评审材料准备', trailingChip: '14:00'),
              const _TodoRow('整理 Q4 用户反馈', trailingChip: '16:30'),
              const _TodoRow('买猫粮'),
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.only(top: 11),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: spec.line,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    PinIcon(PinIcons.plus, size: 11, color: spec.faint),
                    const SizedBox(width: 7),
                    Text(
                      '添加任务',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: spec.faint,
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
    );
  }
}

class _TodoRow extends StatelessWidget {
  const _TodoRow(this.label, {this.done = false, this.trailingChip});

  final String label;
  final bool done;
  final String? trailingChip;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      margin: const EdgeInsets.only(top: 11),
      child: Row(
        children: [
          PinCheckbox(done: done, sm: true),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                color: done ? spec.text2 : spec.text,
                decoration: done ? TextDecoration.lineThrough : null,
                decorationColor: spec.faint,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ),
          if (trailingChip != null) ...[
            const SizedBox(width: 8),
            PinChip(trailingChip!),
          ],
        ],
      ),
    );
  }
}

/// 品牌口号便签
class _QuoteNote extends StatelessWidget {
  const _QuoteNote();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppNav.go(context, '/pin-controls'),
      child: const PinSticky(
        color: StickyColor.cherry,
        tack: true,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StickyTitle('『把重要的事，', fontSize: PinFontSize.lg),
            StickyTitle('贴在眼前。』', fontSize: PinFontSize.lg),
            SizedBox(height: 14),
            StickyLine('— 品牌口号草稿 · 11月2日'),
          ],
        ),
      ),
    );
  }
}

/// 倒计时毛玻璃卡（对应 .count）
class _CountdownCard extends StatelessWidget {
  const _CountdownCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xC710141E), // rgba(16,20,30,.78)
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(color: const Color(0x1FFFFFFF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PinRadius.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  '产品发布会',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFD0D8E6),
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
                Spacer(),
                Text(
                  '11月21日 周六',
                  style: TextStyle(
                    fontSize: PinFontSize.xs2,
                    color: Color(0xFFA6AEBE),
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '12',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w700,
                    height: 1,
                    color: Color(0xFFE8ECF4),
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  '天',
                  style: TextStyle(
                    fontSize: PinFontSize.xs,
                    color: Color(0xFFA8B0C0),
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 5,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                color: Colors.white.withValues(alpha: 0.16),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.42,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 健身打卡便签（含周打卡圈）
class _FitnessNote extends StatelessWidget {
  const _FitnessNote();

  @override
  Widget build(BuildContext context) {
    return const PinSticky(
      color: StickyColor.mint,
      tack: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickyTitle('健身打卡'),
          StickyCheckRow('跑步 5 公里', done: true),
          StickyCheckRow('力量训练 45 分钟'),
          StickyCheckRow('拉伸 10 分钟'),
          _WeekRow(),
        ],
      ),
    );
  }
}

/// 周打卡圈（对应 .week）
class _WeekRow extends StatelessWidget {
  const _WeekRow();

  @override
  Widget build(BuildContext context) {
    final scheme = kStickySchemes[StickyColor.mint]!;
    const days = ['一', '二', '三', '四', '五', '六', '日'];
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < 3 ? scheme.ink : Colors.transparent,
                border: Border.all(color: scheme.ink2, width: 1.2),
              ),
              child: Text(
                days[i],
                style: TextStyle(
                  fontSize: PinFontSize.xs2,
                  color: i < 3 ? scheme.bg : scheme.ink2,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 午饭灵感便签
class _LunchNote extends StatelessWidget {
  const _LunchNote();

  @override
  Widget build(BuildContext context) {
    return const PinSticky(
      color: StickyColor.lemon,
      tape: true,
      lift: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StickyTitle('午饭灵感'),
          StickyLine('楼下新开的云南米线馆'),
          StickyLine('周五和 Anna 一起去'),
        ],
      ),
    );
  }
}
