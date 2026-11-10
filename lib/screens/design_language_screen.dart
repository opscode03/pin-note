/// 贴记 PinNote · 设计语言规范板（对应 ui/design-language.html）
///
/// Flutter 版「活的设计系统文档页」：spec-head + 8 张规范卡
/// （主色与语义色 / 中性灰阶 / 便签 8 色 / 字体字号 / 圆角阴影 / 图标 / 按钮 / 状态）。
/// 页面结构对应 HTML 的 .content（白底滚动），不用 CanvasPage。
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/buttons.dart';
import '../widgets/chips.dart';
import '../widgets/controls.dart';

/// 设计语言规范页（对应 .spec-head + .spec-grid 自适应网格）
class DesignLanguageScreen extends StatelessWidget {
  const DesignLanguageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      color: spec.bg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(PinSpace.s6, 26, PinSpace.s6, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // spec-head：标题 + 副标
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '设计语言规范',
                  style: spec.t2xl.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(width: 14),
                Text(
                  'Design Language V1.0 · 与 PRD 第 7 章对应 · 适用于全部平台',
                  style: spec.txs.copyWith(color: spec.text2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // spec-grid：minmax(340px, 1fr) 自适应多列，span2 跨两列
            LayoutBuilder(
              builder: (context, constraints) {
                const gap = 20.0;
                final cols = ((constraints.maxWidth + gap) / (340 + gap))
                    .floor()
                    .clamp(1, 4);
                final cardW = (constraints.maxWidth - gap * (cols - 1)) / cols;
                final span2W = cols >= 2 ? cardW * 2 + gap : cardW;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    _SpecCard(
                      width: cardW,
                      title: '主色与语义色',
                      child: const _PrimaryColorsBody(),
                    ),
                    _SpecCard(
                      width: cardW,
                      title: '中性色 · 文本 / 边框 / 背景',
                      child: const _GraysBody(),
                    ),
                    _SpecCard(
                      width: span2W,
                      title: '便签 8 色 · Sticky Palette',
                      child: const _StickyPaletteBody(),
                    ),
                    _SpecCard(
                      width: cardW,
                      title: '字体与字号 · 微软雅黑 UI / Segoe UI',
                      child: const _TypeBody(),
                    ),
                    _SpecCard(
                      width: cardW,
                      title: '圆角与阴影',
                      child: const _RadiusShadowBody(),
                    ),
                    _SpecCard(
                      width: span2W,
                      title: '图标 · Fluent 线性 1.75px · 16 / 20 / 24',
                      child: const _IconsBody(),
                    ),
                    _SpecCard(
                      width: cardW,
                      title: '按钮与操作',
                      child: const _ButtonsBody(),
                    ),
                    _SpecCard(
                      width: cardW,
                      title: '选择与状态',
                      child: const _StatesBody(),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 规范卡骨架（.spec-card：面板底 + 描边 + 20 内边距，标题 13 w700 mb 16）
class _SpecCard extends StatelessWidget {
  const _SpecCard({
    required this.width,
    required this.title,
    required this.child,
  });

  final double width;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(color: spec.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: spec.tsm.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// 主色与语义色卡：84px 大色块 + 46px 语义色块（hex 标注沿用设计稿文案）
class _PrimaryColorsBody extends StatelessWidget {
  const _PrimaryColorsBody();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _BigSwatch(color: spec.primary, name: '主色', hex: '#4A7DFF'),
            const SizedBox(width: 20),
            _BigSwatch(
              color: spec.primaryStrong,
              name: '主色 · 深',
              hex: '#3863DB',
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 22,
          runSpacing: 10,
          children: [
            _SmallSwatch(color: spec.success, name: '成功', hex: '#22C55E'),
            _SmallSwatch(color: spec.warning, name: '警示', hex: '#F09917'),
            _SmallSwatch(color: spec.danger, name: '危险', hex: '#EB5757'),
            _SmallSwatch(color: spec.violet, name: '标签', hex: '#7C5CFF'),
          ],
        ),
      ],
    );
  }
}

/// 84px 大色块 + 居中标注（.big-sw / .sw-lbl）
class _BigSwatch extends StatelessWidget {
  const _BigSwatch({
    required this.color,
    required this.name,
    required this.hex,
  });

  final Color color;
  final String name;
  final String hex;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(PinRadius.md),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            fontWeight: FontWeight.w600,
            color: spec.text,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
        Text(hex, style: spec.mono(PinFontSize.xs2, spec.text2)),
      ],
    );
  }
}

/// 46px 语义色块 + 居中标注（.swatch 46×46）
class _SmallSwatch extends StatelessWidget {
  const _SmallSwatch({
    required this.color,
    required this.name,
    required this.hex,
  });

  final Color color;
  final String name;
  final String hex;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(PinRadius.sm),
            border: Border.all(color: spec.line),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            fontWeight: FontWeight.w600,
            color: spec.text,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
        Text(hex, style: spec.mono(PinFontSize.xs2, spec.text2)),
      ],
    );
  }
}

/// 中性色灰阶（.gray-row，设计稿固定演示色阶）
const List<(Color, String)> _kGrayRamp = [
  (Color(0xFF1F2329), '#1F2329'),
  (Color(0xFF6C7380), '#6C7380'),
  (Color(0xFF9EA4B0), '#9EA4B0'),
  (Color(0xFFC9CDD6), '#C9CDD6'),
  (Color(0xFFE4E7EC), '#E4E7EC'),
  (Color(0xFFF5F6F8), '#F5F6F8'),
  (Color(0xFFFFFFFF), '#FFFFFF'),
];

/// 中性色卡：44×88 灰阶块 + mono hex 标注 + 说明段落
class _GraysBody extends StatelessWidget {
  const _GraysBody();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 7,
          runSpacing: 8,
          children: [
            for (var i = 0; i < _kGrayRamp.length; i++)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 88,
                    decoration: BoxDecoration(
                      color: _kGrayRamp[i].$1,
                      borderRadius: BorderRadius.circular(PinRadius.sm),
                      border: Border.all(color: spec.line),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(_kGrayRamp[i].$2, style: spec.mono(9.5, spec.faint)),
                ],
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '文本三级 #1F2329 · #6C7380 · #9EA4B0\n'
          '边框 #E4E7EC · 内容区 #F5F6F8 · 卡片 #FFFFFF',
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            color: spec.text2,
            height: 1.8,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}

/// 便签 8 色（.note-sw：128×76 便签色块，名称 + hex）
const List<(StickyColor, String, String)> _kStickyPalette = [
  (StickyColor.lemon, '柠檬黄', '#FFE994'),
  (StickyColor.apricot, '杏橘', '#FFD8B2'),
  (StickyColor.cherry, '樱花粉', '#FFD1DC'),
  (StickyColor.mint, '薄荷绿', '#C9F0D6'),
  (StickyColor.sky, '天空蓝', '#C6E4FF'),
  (StickyColor.lavender, '薰衣草', '#DDD4FF'),
  (StickyColor.paper, '纸白', '#F2F2F5'),
  (StickyColor.night, '暮夜', '#383942'),
];

/// 便签 8 色卡（span2）
class _StickyPaletteBody extends StatelessWidget {
  const _StickyPaletteBody();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 14,
      children: [
        for (final (color, name, hex) in _kStickyPalette)
          Builder(
            builder: (context) {
              final scheme = kStickySchemes[color]!;
              return Container(
                width: 128,
                height: 76,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: scheme.bg,
                  borderRadius: BorderRadius.circular(PinRadius.md),
                  border: Border.all(color: scheme.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: PinFontSize.xs2,
                        fontWeight: FontWeight.w600,
                        color: scheme.ink,
                        fontFamilyFallback: PinFont.sans,
                      ),
                    ),
                    Text(
                      hex,
                      style: context.pin.mono(PinFontSize.xs2, scheme.ink),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

/// 字体与字号卡（.type-row：示例文字 + 右侧 11px 说明）
class _TypeBody extends StatelessWidget {
  const _TypeBody();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    Widget row(String text, TextStyle style, String label) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Flexible(child: Text(text, style: style)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: PinFontSize.xs2,
                color: spec.text2,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        row(
          '今天 · 待办',
          spec.t2xl.copyWith(fontWeight: FontWeight.w700),
          '22 · 页面标题',
        ),
        row('便签库', spec.txl.copyWith(fontWeight: FontWeight.w700), '18 · 区块标题'),
        row(
          '任务标题示例',
          spec.tmd.copyWith(fontWeight: FontWeight.w600),
          '14 · 卡片标题',
        ),
        row('正文文本示例，行高 1.4', spec.tsm, '13 · 正文'),
        row('辅助说明文本', spec.txs, '12 · 辅助'),
        row('标签 · 时间戳', spec.t2xs, '11 · 标签'),
      ],
    );
  }
}

/// 圆角与阴影卡：三块 96px 白 tile（r8 近阴影 / r10 / r14 远阴影）
class _RadiusShadowBody extends StatelessWidget {
  const _RadiusShadowBody();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    Widget tile(double radius, List<BoxShadow>? shadow, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: spec.surface,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: spec.line),
              boxShadow: shadow,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: PinFontSize.xs2,
              color: spec.text2,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 22,
          runSpacing: 14,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            tile(PinRadius.sm, spec.shadowSm, 'r8 · 控件 · 近阴影'),
            tile(PinRadius.md, null, 'r10 · 卡片'),
            tile(PinRadius.lg, spec.shadowFar, 'r14 · 窗口 · 远阴影'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '阴影 近 0,2,8 / 8% · 远 0,12,32 / 16%\n'
          '间距基准 4px · 桌面贴网格吸附 24px',
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            color: spec.text2,
            height: 1.8,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}

/// 全部 44 个图标（与 ui/icons.svg 的 symbol 一一对应，repeat 复用 sync 造型）
const List<(PinIconData, String)> _kIconCatalog = [
  (PinIcons.plus, 'plus'),
  (PinIcons.minus, 'minus'),
  (PinIcons.close, 'close'),
  (PinIcons.check, 'check'),
  (PinIcons.chevronDown, 'chevron-down'),
  (PinIcons.chevronUp, 'chevron-up'),
  (PinIcons.chevronRight, 'chevron-right'),
  (PinIcons.chevronLeft, 'chevron-left'),
  (PinIcons.search, 'search'),
  (PinIcons.calendar, 'calendar'),
  (PinIcons.clock, 'clock'),
  (PinIcons.bell, 'bell'),
  (PinIcons.flag, 'flag'),
  (PinIcons.tag, 'tag'),
  (PinIcons.pin, 'pin'),
  (PinIcons.tack, 'tack'),
  (PinIcons.layers, 'layers'),
  (PinIcons.note, 'note'),
  (PinIcons.gear, 'gear'),
  (PinIcons.theme, 'theme'),
  (PinIcons.sync, 'sync'),
  (PinIcons.repeat, 'repeat'),
  (PinIcons.trash, 'trash'),
  (PinIcons.more, 'more'),
  (PinIcons.palette, 'palette'),
  (PinIcons.opacity, 'opacity'),
  (PinIcons.image, 'image'),
  (PinIcons.enter, 'enter'),
  (PinIcons.start, 'start'),
  (PinIcons.wifi, 'wifi'),
  (PinIcons.volume, 'volume'),
  (PinIcons.battery, 'battery'),
  (PinIcons.gridView, 'grid-view'),
  (PinIcons.listView, 'list-view'),
  (PinIcons.highlight, 'highlight'),
  (PinIcons.listCheck, 'list-check'),
  (PinIcons.listBullet, 'list-bullet'),
  (PinIcons.lock, 'lock'),
  (PinIcons.zap, 'zap'),
  (PinIcons.folder, 'folder'),
  (PinIcons.person, 'person'),
  (PinIcons.keyboard, 'keyboard'),
  (PinIcons.info, 'info'),
  (PinIcons.drag, 'drag'),
];

/// 图标卡（span2：44 格 22px 图标 + mono 名称，每格宽 64）
class _IconsBody extends StatelessWidget {
  const _IconsBody();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        for (final (icon, name) in _kIconCatalog)
          SizedBox(
            width: 64,
            child: Column(
              children: [
                PinIcon(icon, size: 22, color: spec.text2),
                const SizedBox(height: 7),
                Text(name, style: spec.mono(PinFontSize.xs2, spec.text2)),
              ],
            ),
          ),
      ],
    );
  }
}

/// 按钮与操作卡：主 / 次 / 危险 / 禁用 / 文本链接 + 图标按钮 / 激活 / kbd
class _ButtonsBody extends StatelessWidget {
  const _ButtonsBody();

  @override
  Widget build(BuildContext context) {
    Widget demo(String label, Widget child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: PinFontSize.xs2,
              color: context.pin.text2,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            demo('主按钮', PinButton('新建任务', icon: PinIcons.plus, onTap: () {})),
            demo(
              '次按钮',
              PinButton(
                '存为便签',
                variant: PinButtonVariant.secondary,
                onTap: () {},
              ),
            ),
            demo(
              '危险操作',
              PinButton(
                '删除',
                icon: PinIcons.trash,
                variant: PinButtonVariant.danger,
                onTap: () {},
              ),
            ),
            demo(
              '禁用',
              const PinButton('已保存', variant: PinButtonVariant.disabled),
            ),
            demo(
              '文本链接',
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: PinLink(
                  '查看全部 →',
                  fontSize: PinFontSize.sm,
                  onTap: () {},
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            demo('图标按钮', PinIconButton(PinIcons.plus, onTap: () {})),
            demo(
              '激活',
              PinIconButton(PinIcons.plus, active: true, onTap: () {}),
            ),
            demo('快捷键提示', const PinKbd(['Ctrl', 'K'])),
          ],
        ),
      ],
    );
  }
}

/// 侧栏数字徽章（.nav-badge：主色浅底胶囊）
class _NavBadge extends StatelessWidget {
  const _NavBadge(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: spec.primaryTint,
        borderRadius: BorderRadius.circular(PinRadius.full),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: PinFontSize.xs2,
          fontWeight: FontWeight.w600,
          color: spec.primaryStrong,
          fontFamilyFallback: PinFont.sans,
        ),
      ),
    );
  }
}

/// 导航项演示容器（.nav-demo：216 宽 surface-2 底 + 两行导航项）
class _NavDemo extends StatelessWidget {
  const _NavDemo();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: 216,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: spec.surface2,
        borderRadius: BorderRadius.circular(PinRadius.sm),
        border: Border.all(color: spec.line),
      ),
      child: const Column(
        children: [
          _NavDemoItem('工作', PinListDots.work),
          _NavDemoItem('生活', PinListDots.life, active: true),
        ],
      ),
    );
  }
}

/// 单行导航项（.nav-item / .nav-item.active：左侧色点 + 激活条）
class _NavDemoItem extends StatelessWidget {
  const _NavDemoItem(this.label, this.dotColor, {this.active = false});

  final String label;
  final Color dotColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      height: PinSize.navItem,
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: active ? spec.selBg : null,
        borderRadius: BorderRadius.circular(PinRadius.sm),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: PinFontSize.sm,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                    color: active ? spec.selText : spec.text,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ),
            ],
          ),
          // 激活态左侧条（.nav-item.active::before）
          if (active)
            Positioned(
              left: -10,
              top: 7,
              bottom: 7,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: spec.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 选择与状态卡：复选框 / Chip / 开关 / 进度 / 导航项五组演示
class _StatesBody extends StatelessWidget {
  const _StatesBody();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    Widget row(String label, List<Widget> children) {
      return Padding(
        padding: const EdgeInsets.only(top: 18),
        child: Wrap(
          spacing: 18,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 52,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: PinFontSize.xs2,
                  color: spec.text2,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
            ),
            ...children,
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 第二个复选框悬停时描边主色（.cb 的 hover 态）
        row('复选框', [
          const PinCheckbox(),
          const PinCheckbox(),
          const PinCheckbox(done: true),
        ]),
        row('Chip 色彩', [
          const PinChip(
            '今天 14:00',
            icon: PinIcons.clock,
            style: PinChipStyle.accent,
          ),
          const PinChip('#设计', style: PinChipStyle.violet),
          const PinChip('高', icon: PinIcons.flag, style: PinChipStyle.red),
          const PinChip('清单 · 工作'),
        ]),
        row('开关', [const PinSwitch(on: true), const PinSwitch()]),
        row('进度', [
          const PinProgressBar(value: 0.5, lg: true),
          const PinRing(value: 0.375),
          const _NavBadge('8'),
        ]),
        row('导航项', [const _NavDemo()]),
      ],
    );
  }
}
