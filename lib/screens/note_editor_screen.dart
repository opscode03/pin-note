/// 贴记 PinNote · 便签编辑页（对应 ui/note-editor.html）
///
/// 便签仓库驱动：标题 / 勾选项 / 颜色可编辑并持久化；
/// 右侧两行标注 + 「便签颜色」面板卡（8 色色板 + 自定义）。
library;

import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/navigation.dart';
import '../data/demo.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/interactive.dart';
import '../widgets/sticky_note.dart';

/// 便签色 → scheme
StickyScheme noteSchemeOf(StickyColor c) => kStickySchemes[c]!;

/// color-mix(in srgb, var(--note-bg) n%, #fff) → 便签底色与白按比例混合
Color mixNoteBg(StickyScheme scheme, double n) =>
    Color.lerp(scheme.bg, Colors.white, 1 - n / 100)!;

/// 便签编辑页（note-editor.html：data-color 的编辑窗）
class NoteEditorScreen extends StatelessWidget {
  const NoteEditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return ListenableBuilder(
      listenable: NoteScope.of(context),
      builder: (context, _) {
        final note = NoteScope.of(context).selected;
        final effective = note ??
            const DemoNote(
              id: '新便签',
              title: '新便签',
              color: StickyColor.lemon,
              time: '刚刚',
            );
        // .editor-wrap：flex-wrap、align-items center、gap 26
        // （窗口较窄时右侧颜色面板换行到便签下方，对应 HTML flex-wrap: wrap）
        return CanvasPage(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: height - 80),
              child: Center(
                child: Wrap(
                  spacing: 26,
                  runSpacing: 26,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _NoteWindow(note: effective),
                    _SideColumn(note: effective),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 编辑窗便签窗体（.sticky.note-win：宽 470、圆角 14、远阴影）
class _NoteWindow extends StatelessWidget {
  const _NoteWindow({required this.note});

  final DemoNote note;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final scheme = noteSchemeOf(note.color);
    final repo = NoteScope.of(context);
    return SizedBox(
      width: 470,
      child: PinSticky(
        color: note.color,
        radius: PinRadius.lg,
        shadow: spec.shadowFar,
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _NoteHead(scheme: scheme),
            ),
            const SizedBox(height: 14), // .toolbar margin-top 14（全出血）
            _Toolbar(scheme: scheme),
            const SizedBox(height: 6), // .toolbar margin-bottom 6
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 标题（.ed-title：18px 加粗、margin-top 12）
                  Padding(
                    padding: const EdgeInsets.only(top: PinSpace.s3),
                    child: SizedBox(
                      width: double.infinity,
                      child: Material(
                        type: MaterialType.transparency,
                        child: TextField(
                          controller: TextEditingController(text: note.title),
                          onChanged: (v) =>
                              repo.update(note.id ?? note.title, title: v),
                          style: context.pin.txl.copyWith(
                            fontWeight: FontWeight.w700,
                            color: scheme.ink,
                          ),
                          cursorColor: spec.primary,
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 清单项（.ed-check）
                  for (var i = 0; i < note.checks.length; i++)
                    _CheckRow(
                      note.checks[i].$1,
                      done: note.checks[i].$2,
                      scheme: scheme,
                      onTap: () => repo.toggleCheck(note.id ?? note.title, i),
                      onRemove: () =>
                          repo.removeCheck(note.id ?? note.title, i),
                    ),
                  // 添加清单项
                  _AddCheckRow(noteId: note.id ?? note.title),
                  // 高亮块（.ed-hl：margin-top 16、padding 3 9、圆角 6）
                  Padding(
                    padding: const EdgeInsets.only(top: PinSpace.s4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: mixNoteBg(scheme, 35),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '下季度 OKR 草案需 Anna 确认',
                        style: context.pin.tsm.copyWith(color: scheme.ink),
                      ),
                    ),
                  ),
                  // 标签（.ed-tag：margin-top 16）
                  Padding(
                    padding: const EdgeInsets.only(top: PinSpace.s4),
                    child: _NoteTag(scheme: scheme),
                  ),
                  // 脚注（.ed-foot：margin-top 22、11px）
                  Padding(
                    padding: const EdgeInsets.only(top: 22),
                    child: Row(
                      children: [
                        PinIcon(PinIcons.sync, size: 12, color: scheme.ink2),
                        const SizedBox(width: PinSpace.s2),
                        Text(
                          '已自动保存 · ${note.time}',
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
  const _NoteHead({required this.scheme});

  final StickyScheme scheme;

  @override
  Widget build(BuildContext context) {
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
          onTap: () => AppNav.go(context, '/desktop-pins'),
          icon: PinIcons.pin,
          label: '贴到桌面',
          scheme: scheme,
        ),
        const SizedBox(width: PinSpace.s2),
        // pill-outline：置顶（→ pin-controls.html）
        _NotePill(
          onTap: () => AppNav.go(context, '/pin-controls'),
          icon: PinIcons.layers,
          label: '置顶',
          outline: true,
          scheme: scheme,
        ),
        const Spacer(),
        _NoteWindowButton(PinIcons.minus, scheme: scheme), // href="#"，无跳转
        _NoteWindowButton(
          PinIcons.close,
          onTap: () => AppNav.go(context, '/notes'),
          scheme: scheme,
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
    required this.scheme,
    this.outline = false,
  });

  final PinIconData icon;
  final String label;
  final VoidCallback onTap;
  final StickyScheme scheme;
  final bool outline;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final fg = outline ? scheme.ink : Colors.white;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 26,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: outline ? mixNoteBg(scheme, 45) : spec.primary,
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
  const _NoteWindowButton(this.icon, {this.onTap, required this.scheme});

  final PinIconData icon;
  final VoidCallback? onTap;
  final StickyScheme scheme;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: hover ? mixNoteBg(scheme, 40) : Colors.transparent,
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
  const _Toolbar({required this.scheme});

  final StickyScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 7),
      decoration: BoxDecoration(
        color: mixNoteBg(scheme, 70),
        border: Border(
          top: BorderSide(color: scheme.line),
          bottom: BorderSide(color: scheme.line),
        ),
      ),
      child: Row(
        children: [
          _ToolBtn(label: 'B', scheme: scheme),
          const SizedBox(width: 1),
          _ToolBtn(label: 'I', italic: true, scheme: scheme),
          const SizedBox(width: 1),
          _ToolBtn(label: 'U', underline: true, scheme: scheme),
          const SizedBox(width: 1),
          _ToolBtn(label: 'S', strike: true, scheme: scheme),
          _ToolSep(scheme: scheme),
          _ToolBtn(label: 'H1', fontSize: PinFontSize.xs2, scheme: scheme),
          const SizedBox(width: 1),
          _ToolBtn(label: 'H2', fontSize: PinFontSize.xs2, scheme: scheme),
          _ToolSep(scheme: scheme),
          _ToolBtn(icon: PinIcons.listCheck, on: true, scheme: scheme),
          const SizedBox(width: 1),
          _ToolBtn(icon: PinIcons.listBullet, scheme: scheme),
          _ToolSep(scheme: scheme),
          _ToolBtn(icon: PinIcons.highlight, scheme: scheme),
          const SizedBox(width: 1),
          _ToolBtn(icon: PinIcons.image, scheme: scheme),
          _ToolSep(scheme: scheme),
          _ToolBtn(icon: PinIcons.more, scheme: scheme),
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
    required this.scheme,
  });

  final String? label;
  final PinIconData? icon;
  final double? fontSize;
  final bool italic;
  final bool underline;
  final bool strike;
  final bool on;
  final StickyScheme scheme;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hover, _) {
        final bg = on
            ? mixNoteBg(scheme, 25)
            : (hover ? mixNoteBg(scheme, 38) : Colors.transparent);
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
              child: _glyph(fg),
            ),
          ),
        );
      },
    );
  }

  Widget _glyph(Color fg) {
    if (icon != null) {
      return PinIcon(icon!, size: 15, color: fg);
    }
    return Text(
      label!,
      style: TextStyle(
        fontSize: fontSize ?? PinFontSize.sm,
        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
        decoration: TextDecoration.combine([
          if (underline) TextDecoration.underline,
          if (strike) TextDecoration.lineThrough,
        ]),
        color: fg,
        fontFamilyFallback: PinFont.sans,
      ),
    );
  }
}

/// 工具栏分隔线（.tb-sep：1×16、margin 0 6）
class _ToolSep extends StatelessWidget {
  const _ToolSep({required this.scheme});

  final StickyScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 16,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      color: scheme.line,
    );
  }
}

/// 清单项行（.ed-check：勾选可点、hover 显示删除叉）
class _CheckRow extends StatelessWidget {
  const _CheckRow(
    this.label, {
    required this.done,
    required this.scheme,
    this.onTap,
    this.onRemove,
  });

  final String label;
  final bool done;
  final StickyScheme scheme;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, hover, _) {
        return Padding(
          padding: const EdgeInsets.only(top: 13),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
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
                          child:
                              PinIcon(PinIcons.check, size: 10, color: scheme.bg),
                        )
                      : null,
                ),
                const SizedBox(width: PinSpace.s3),
                Expanded(
                  child: Text(
                    label,
                    style: context.pin.tsm.copyWith(
                      color: scheme.ink,
                      decoration: done ? TextDecoration.lineThrough : null,
                      // text-decoration-color: color-mix(in srgb, var(--note-ink) 55%, var(--note-bg))
                      decorationColor: Color.lerp(scheme.bg, scheme.ink, 0.55),
                    ),
                  ),
                ),
                if (hover)
                  GestureDetector(
                    onTap: onRemove,
                    child: PinIcon(
                      PinIcons.close,
                      size: 9,
                      color: scheme.ink2,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 添加清单项行（勾选清单的「+ 新建清单项」）
class _AddCheckRow extends StatelessWidget {
  const _AddCheckRow({required this.noteId});

  final String noteId;

  @override
  Widget build(BuildContext context) {
    final scheme = noteSchemeOf(kStickySchemes.keys.first); // 占位，实际由父级传入
    final repo = NoteScope.of(context);
    return HoverBuilder(
      builder: (context, hover, _) {
        final color = hover ? scheme.ink : scheme.ink2;
        return Padding(
          padding: const EdgeInsets.only(top: 13),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () =>
                repo.addCheck(noteId, '清单项 ${repo.selected?.checks.length ?? 0}'),
            child: Row(
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Color.lerp(scheme.bg, scheme.ink, 0.42)!,
                      width: 1.5,
                    ),
                  ),
                ),
                const SizedBox(width: PinSpace.s3),
                Text('新建清单项', style: context.pin.tsm.copyWith(color: color)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// 标签（.ed-tag：高 22、radius full、42% 便签底 + 8px 关闭叉）
class _NoteTag extends StatelessWidget {
  const _NoteTag({required this.scheme});

  final StickyScheme scheme;

  @override
  Widget build(BuildContext context) {
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: () {},
        child: Container(
          height: 22,
          padding: const EdgeInsets.fromLTRB(11, 0, 10, 0),
          decoration: BoxDecoration(
            color: mixNoteBg(scheme, 42),
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
  const _SideColumn({required this.note});

  final DemoNote note;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final repo = NoteScope.of(context);
    Widget swatchRow(List<StickyColor> colors) => Row(
          children: [
            for (var i = 0; i < colors.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              _SwatchCell(
                colors[i],
                on: note.color == colors[i],
                onTap: () =>
                    repo.update(note.id ?? note.title, color: colors[i]),
              ),
            ],
          ],
        );

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
              swatchRow(const [
                StickyColor.lemon,
                StickyColor.apricot,
                StickyColor.cherry,
                StickyColor.mint,
              ]),
              const SizedBox(height: 10),
              swatchRow(const [
                StickyColor.sky,
                StickyColor.lavender,
                StickyColor.paper,
                StickyColor.night,
              ]),
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
  const _SwatchCell(this.color, {this.on = false, this.onTap});

  final StickyColor color;
  final bool on;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final scheme = noteSchemeOf(color);
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        // HTML .sw-grid 单元 48px 会溢出 252 卡片内宽 216；取 46 恰好放下
        child: Container(
          width: 46,
          height: 40,
          alignment: Alignment.center,
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
                // outline 2px + offset 2.5px → 外扩 49 圆角描边（圆角随偏移放大）
                Positioned(
                  left: -4.5,
                  top: -4.5,
                  child: Container(
                    width: 49,
                    height: 49,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.5),
                      border: Border.all(color: spec.primary, width: 2),
                    ),
                  ),
                ),
              if (on)
                const Positioned(
                  right: -4,
                  bottom: -4,
                  child: _SelectedDot(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 选中态右下主色圆点（.sw.on::after）
class _SelectedDot extends StatelessWidget {
  const _SelectedDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: context.pin.primary,
      ),
    );
  }
}

/// 自定义颜色入口（.sw-custom：34×26 虚线 + 加号 / 大格）
class _CustomSwatch extends StatelessWidget {
  const _CustomSwatch({this.size = 40, this.iconSize = 11});

  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) {
        final color = hover ? spec.primaryStrong : spec.faint;
        return GestureDetector(
          onTap: () {},
          child: Container(
            width: size,
            height: size * 26 / 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: hover ? spec.primary : spec.lineStrong,
                width: 1.3,
              ),
            ),
            child: Center(
              child: PinIcon(PinIcons.plus, size: iconSize, color: color),
            ),
          ),
        );
      },
    );
  }
}
