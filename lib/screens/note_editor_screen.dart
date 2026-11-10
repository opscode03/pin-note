/// 贴记 PinNote · 便签编辑（对应 ui/note-editor.html）
///
/// 画布页（.canvas-page）：左侧柠檬黄便签编辑窗（头部动作、格式工具栏、
/// 标题、4 条清单、高亮块、#工作 标签、自动保存脚注），
/// 右侧两行标注 + 「便签颜色」面板卡（8 色色板 + 自定义）。
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/interactive.dart';
import '../widgets/sticky_note.dart';

/// 便签编辑页（note-editor.html：data-color="lemon" 的编辑窗）
class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return CanvasPage(
      children: [
        // .editor-wrap：flex-wrap、align-items center、gap 26
        // （窗口较窄时右侧颜色面板换行到便签下方，对应 HTML flex-wrap: wrap）
        ConstrainedBox(
          constraints: BoxConstraints(minHeight: height - 80),
          child: const Center(
            child: Wrap(
              spacing: 26,
              runSpacing: 26,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [_NoteWindow(), _SideColumn()],
            ),
          ),
        ),
      ],
    );
  }
}

/// 编辑窗便签色（note-editor.html data-color="lemon"）
StickyScheme get _noteScheme => kStickySchemes[StickyColor.lemon]!;

/// color-mix(in srgb, var(--note-bg) n%, #fff) → 便签底色与白按比例混合
Color _mixNoteBg(double n) =>
    Color.lerp(_noteScheme.bg, Colors.white, 1 - n / 100)!;

/// 便签编辑窗（.sticky.note-win：宽 470、圆角 14、远阴影、padding 18 20）
class _NoteWindow extends StatelessWidget {
  const _NoteWindow();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final scheme = _noteScheme;
    return SizedBox(
      width: 470,
      child: PinSticky(
        color: StickyColor.lemon,
        radius: PinRadius.lg,
        shadow: spec.shadowFar,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _NoteHead(),
            ),
            const SizedBox(height: 14), // .toolbar margin-top 14（全出血）
            const _Toolbar(),
            const SizedBox(height: 6), // .toolbar margin-bottom 6
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题（.ed-title：18px 加粗、margin-top 12）
                  Padding(
                    padding: const EdgeInsets.only(top: PinSpace.s3),
                    child: Text(
                      '周报要点',
                      style: context.pin.txl.copyWith(
                        fontWeight: FontWeight.w700,
                        color: scheme.ink,
                      ),
                    ),
                  ),
                  const _CheckRow('竞品动态梳理', done: true),
                  const _CheckRow('数据指标核对', done: true),
                  const _CheckRow('Q4 目标对齐'),
                  const _CheckRow('风险与依赖盘点'),
                  // 高亮块（.ed-hl：margin-top 16、padding 3 9、圆角 6）
                  Padding(
                    padding: const EdgeInsets.only(top: PinSpace.s4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _mixNoteBg(35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '下季度 OKR 草案需 Anna 确认',
                        style: context.pin.tsm.copyWith(color: scheme.ink),
                      ),
                    ),
                  ),
                  // 标签（.ed-tag：margin-top 16）
                  const Padding(
                    padding: EdgeInsets.only(top: PinSpace.s4),
                    child: _NoteTag(),
                  ),
                  // 脚注（.ed-foot：margin-top 22、11px）
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Row(
                      children: [
                        PinIcon(PinIcons.sync, size: 12, color: scheme.ink2),
                        const SizedBox(width: PinSpace.s2),
                        Text(
                          '已自动保存 · 上次编辑 2 分钟前',
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
          ],
        ),
      ),
    );
  }
}

/// 窗头（.nw-head：kind + 两个 pill + 右侧窗控）
class _NoteHead extends StatelessWidget {
  const _NoteHead();

  @override
  Widget build(BuildContext context) {
    final scheme = _noteScheme;
    return Row(
      children: [
        Text(
          '便签',
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            color: scheme.ink2,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
        const SizedBox(width: PinSpace.s2),
        // pill-primary：贴到桌面（→ desktop-pins.html）
        _NotePill(
          onTap: () => Navigator.pushNamed(context, '/desktop-pins'),
          icon: PinIcons.pin,
          label: '贴到桌面',
        ),
        const SizedBox(width: PinSpace.s2),
        // pill-outline：置顶（→ pin-controls.html）
        _NotePill(
          onTap: () => Navigator.pushNamed(context, '/pin-controls'),
          icon: PinIcons.layers,
          label: '置顶',
          outline: true,
        ),
        const Spacer(),
        const _NoteWindowButton(PinIcons.minus), // href="#"，无跳转
        _NoteWindowButton(
          PinIcons.close,
          onTap: () => Navigator.pushNamed(context, '/notes'),
        ),
      ],
    );
  }
}

/// 窗头 pill（.pill：高 26、radius 13、12px 加粗；primary 实心 / outline 描边）
class _NotePill extends StatelessWidget {
  const _NotePill({
    required this.icon,
    required this.label,
    required this.onTap,
    this.outline = false,
  });

  final PinIconData icon;
  final String label;
  final VoidCallback onTap;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final scheme = _noteScheme;
    final fg = outline ? _noteScheme.ink : Colors.white;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: outline ? _mixNoteBg(45) : context.pin.primary,
            borderRadius: BorderRadius.circular(PinRadius.full),
            border: outline ? Border.all(color: scheme.line) : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              PinIcon(icon, size: 11, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: PinFontSize.xs,
                  fontWeight: FontWeight.w600,
                  color: fg,
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

/// 窗控图标按钮（.nw-head .icon-btn：26×26，hover 便签底变浅）
class _NoteWindowButton extends StatelessWidget {
  const _NoteWindowButton(this.icon, {this.onTap});

  final PinIconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = _noteScheme;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: hover ? _mixNoteBg(40) : Colors.transparent,
            borderRadius: BorderRadius.circular(PinRadius.sm),
          ),
          child: Center(
            child: PinIcon(
              icon,
              size: 13,
              color: hover ? scheme.ink : scheme.ink2,
            ),
          ),
        ),
      ),
    );
  }
}

/// 格式工具栏（.toolbar：上下描边、70% 便签底、全出血、按钮间距 1px）
class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    final scheme = _noteScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
      decoration: BoxDecoration(
        color: _mixNoteBg(70),
        border: Border(
          top: BorderSide(color: scheme.line),
          bottom: BorderSide(color: scheme.line),
        ),
      ),
      child: const Row(
        children: [
          _ToolBtn(label: 'B'),
          SizedBox(width: 1),
          _ToolBtn(label: 'I', italic: true),
          SizedBox(width: 1),
          _ToolBtn(label: 'U', underline: true),
          SizedBox(width: 1),
          _ToolBtn(label: 'S', strike: true),
          _ToolSep(),
          _ToolBtn(label: 'H1', fontSize: PinFontSize.xs2),
          SizedBox(width: 1),
          _ToolBtn(label: 'H2', fontSize: PinFontSize.xs2),
          _ToolSep(),
          _ToolBtn(icon: PinIcons.listCheck, on: true),
          SizedBox(width: 1),
          _ToolBtn(icon: PinIcons.listBullet),
          _ToolSep(),
          _ToolBtn(icon: PinIcons.highlight),
          SizedBox(width: 1),
          _ToolBtn(icon: PinIcons.image),
          _ToolSep(),
          _ToolBtn(icon: PinIcons.more),
        ],
      ),
    );
  }
}

/// 工具栏按钮（.tb-btn：min-width 30、高 30、圆角 7；on 态底色更实）
class _ToolBtn extends StatelessWidget {
  const _ToolBtn({
    this.label,
    this.icon,
    this.fontSize,
    this.italic = false,
    this.underline = false,
    this.strike = false,
    this.on = false,
  });

  final String? label;
  final PinIconData? icon;
  final double? fontSize;
  final bool italic;
  final bool underline;
  final bool strike;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final scheme = _noteScheme;
    return HoverBuilder(
      builder: (context, hover, _) {
        final bg = on
            ? _mixNoteBg(25)
            : (hover ? _mixNoteBg(38) : Colors.transparent);
        final fg = on || hover ? scheme.ink : scheme.ink2;
        return GestureDetector(
          onTap: () {},
          child: Container(
            height: 30,
            constraints: const BoxConstraints(minWidth: 30),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(7),
            ),
            child: Center(
              child: icon != null
                  ? PinIcon(icon!, size: 15, color: fg)
                  : Text(
                      label!,
                      style: TextStyle(
                        fontSize: fontSize ?? PinFontSize.sm,
                        fontWeight: FontWeight.w700,
                        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                        decoration: underline
                            ? TextDecoration.underline
                            : (strike ? TextDecoration.lineThrough : null),
                        color: fg,
                        fontFamilyFallback: PinFont.sans,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}

/// 工具栏分隔线（.tb-sep：1×16、margin 0 6）
class _ToolSep extends StatelessWidget {
  const _ToolSep();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: _noteScheme.line,
    );
  }
}

/// 清单行（.ed-check：16px 圆形复选框 + 13px 文本；done 划线）
class _CheckRow extends StatelessWidget {
  const _CheckRow(this.label, {this.done = false});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final scheme = _noteScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 13),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? scheme.ink : Colors.transparent,
              border: Border.all(
                // border-color: color-mix(in srgb, var(--note-ink) 42%, var(--note-bg))
                color: Color.lerp(scheme.bg, scheme.ink, 0.42)!,
                width: 1.5,
              ),
            ),
            child: done
                ? Center(
                    // 勾的颜色为便签底色（.ed-check .cb color: var(--note-bg)）
                    child: PinIcon(PinIcons.check, size: 10, color: scheme.bg),
                  )
                : null,
          ),
          const SizedBox(width: PinSpace.s3),
          Text(
            label,
            style: context.pin.tsm.copyWith(
              color: scheme.ink,
              decoration: done ? TextDecoration.lineThrough : null,
              // text-decoration-color: color-mix(in srgb, var(--note-ink) 55%, var(--note-bg))
              decorationColor: Color.lerp(scheme.bg, scheme.ink, 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

/// 标签（.ed-tag：高 22、radius full、42% 便签底 + 8px 关闭叉）
class _NoteTag extends StatelessWidget {
  const _NoteTag();

  @override
  Widget build(BuildContext context) {
    final scheme = _noteScheme;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: () {},
        child: Container(
          height: 22,
          padding: const EdgeInsets.fromLTRB(11, 0, 10, 0),
          decoration: BoxDecoration(
            color: _mixNoteBg(42),
            borderRadius: BorderRadius.circular(PinRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('#工作', style: context.pin.txs.copyWith(color: scheme.ink)),
              const SizedBox(width: 6),
              PinIcon(PinIcons.close, size: 8, color: scheme.ink2),
            ],
          ),
        ),
      ),
    );
  }
}

/// 右侧列（.side-col：两行标注 + 颜色面板卡）
class _SideColumn extends StatelessWidget {
  const _SideColumn();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Anno('一键贴到桌面，常驻壁纸层'),
        const SizedBox(height: PinSpace.s3),
        const _Anno('8 种便签色 · 支持自定义'),
        const SizedBox(
          height: 22,
        ), // .side-col gap 12 + color-pop margin-top 10
        Artboard(
          width: 252,
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '便签颜色',
                style: spec.tsm.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
              // 色板网格（.sw-grid：4 列 × 48、间距 10）
              const Row(
                children: [
                  _SwatchCell(StickyColor.lemon, on: true),
                  SizedBox(width: 10),
                  _SwatchCell(StickyColor.apricot),
                  SizedBox(width: 10),
                  _SwatchCell(StickyColor.cherry),
                  SizedBox(width: 10),
                  _SwatchCell(StickyColor.mint),
                ],
              ),
              const SizedBox(height: 10),
              const Row(
                children: [
                  _SwatchCell(StickyColor.sky),
                  SizedBox(width: 10),
                  _SwatchCell(StickyColor.lavender),
                  SizedBox(width: 10),
                  _SwatchCell(StickyColor.paper),
                  SizedBox(width: 10),
                  _SwatchCell(StickyColor.night),
                ],
              ),
              const SizedBox(height: 10),
              const _CustomSwatch(),
              const SizedBox(height: 14),
              // 底部自定义入口
              Row(
                children: [
                  const _CustomSwatch(size: 34, iconSize: 13),
                  const SizedBox(width: 10),
                  Text('自定义颜色', style: spec.txs.copyWith(color: spec.text2)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 标注（.anno：6px 主色圆点 + 说明；文字为设计稿固定色 #5A6474）
class _Anno extends StatelessWidget {
  const _Anno(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.pin.primary,
          ),
        ),
        const SizedBox(width: PinSpace.s2),
        Text(
          text,
          style: const TextStyle(
            fontSize: PinFontSize.xs,
            color: Color(0xFF5A6474),
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}

/// 色板格（.sw：40×40、圆角 10；on 态 outline 2px primary + 右下 16px 圆点）
class _SwatchCell extends StatelessWidget {
  const _SwatchCell(this.color, {this.on = false});

  final StickyColor color;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final scheme = kStickySchemes[color]!;
    // HTML .sw-grid 单元 48px（4×48+3×10=222 会溢出 252 卡片内宽 216，
    // CSS 中表现为静默溢出）；Flutter 取 46 使网格恰好放下
    return SizedBox(
      width: 46,
      height: 40,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: scheme.bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: scheme.line),
            ),
          ),
          if (on)
            // outline 2px + offset 2.5px → 外扩 49 的圆角描边（圆角随偏移放大）
            Positioned(
              left: -4.5,
              top: -4.5,
              child: Container(
                width: 49,
                height: 49,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: spec.primary, width: 2),
                ),
              ),
            ),
          if (on)
            // .sw.on::after：right/bottom -4 的 16px 主色圆点
            Positioned(
              left: 28,
              top: 28,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: spec.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 自定义色格（.sw-custom：虚线描边 + 加号；默认 40，底部入口 34）
class _CustomSwatch extends StatelessWidget {
  const _CustomSwatch({this.size = 40, this.iconSize = 16});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: () {},
        child: SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            painter: _DashedRectPainter(
              size: size,
              color: spec.lineStrong,
              width: 1.5,
            ),
            child: Center(
              child: PinIcon(PinIcons.plus, size: iconSize, color: spec.faint),
            ),
          ),
        ),
      ),
    );
  }
}

/// 虚线圆角描边画笔（Flutter Border 不支持 dashed，按 CSS `dashed` 视觉复刻）
class _DashedRectPainter extends CustomPainter {
  const _DashedRectPainter({
    required this.size,
    required this.color,
    required this.width,
  });

  final double size;
  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    final inset = width / 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(10 - inset)));
    for (final metric in path.computeMetrics()) {
      var start = 0.0;
      while (start < metric.length) {
        final end = start + 4 > metric.length ? metric.length : start + 4;
        canvas.drawPath(metric.extractPath(start, end), p);
        start = end + 3;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRectPainter oldDelegate) =>
      oldDelegate.size != size ||
      oldDelegate.color != color ||
      oldDelegate.width != width;
}
