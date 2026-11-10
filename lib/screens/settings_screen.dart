/// 贴记 PinNote · 设置（对应 ui/settings.html）
///
/// 左侧为设置专用侧栏（返回链接 + 「设置」标题 + 导航 + 用户卡），
/// 右侧为外观设置：主题三选（含预览小样）、强调色 8 圆点、
/// 界面字号分段 + 示例文本、桌面贴默认模式两行单选。
library;

import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/controls.dart';
import '../widgets/interactive.dart';
import '../widgets/task_views.dart';

/// 设置页（settings.html：自定义侧栏 + 外观内容区）
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PinAppWindow(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SettingsSidebar(),
          Expanded(child: _AppearanceContent()),
        ],
      ),
    );
  }
}

/// 设置专用侧栏（.sidebar：220 宽、surface-2 底、右分割线；顶部为返回链接）
class _SettingsSidebar extends StatelessWidget {
  const _SettingsSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PinSize.sidebar,
      decoration: BoxDecoration(
        color: context.pin.surface2,
        border: Border(right: BorderSide(color: context.pin.line)),
      ),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: PinSpace.s3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _BackLink(),
                  const _SidebarTitle(),
                  _SettingsNavItem(
                    '外观',
                    icon: PinIcons.theme,
                    selected: true,
                    onTap: () => Navigator.pushNamed(context, '/settings'),
                  ),
                  const _SettingsNavItem('行为', icon: PinIcons.gear),
                  const _SettingsNavItem('热键', icon: PinIcons.keyboard),
                  _SettingsNavItem(
                    '通知',
                    icon: PinIcons.bell,
                    onTap: () => Navigator.pushNamed(context, '/tray'),
                  ),
                  const _SettingsNavItem('数据', icon: PinIcons.folder),
                  _SettingsNavItem(
                    '账户',
                    icon: PinIcons.person,
                    onTap: () => Navigator.pushNamed(context, '/account'),
                  ),
                  const _SettingsNavItem('关于', icon: PinIcons.info),
                ],
              ),
            ),
          ),
          // 用户卡（与 PinSidebar 的 _SidebarFooter 同款；其实现为私有，此处复刻）
          const _SidebarFooter(),
        ],
      ),
    );
  }
}

/// 返回链接（.back-link：chevron + 返回，hover 变一级文本色）
class _BackLink extends StatelessWidget {
  const _BackLink();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/'),
        child: Container(
          margin: const EdgeInsets.fromLTRB(10, 4, 10, 0),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              PinIcon(
                PinIcons.chevronLeft,
                size: 13,
                color: hover ? spec.text : spec.text2,
              ),
              const SizedBox(width: 7),
              Text(
                '返回',
                style: TextStyle(
                  fontSize: 12.5,
                  color: hover ? spec.text : spec.text2,
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

/// 「设置」标题（.set-title：16px 加粗、padding 14 22 8）
class _SidebarTitle extends StatelessWidget {
  const _SidebarTitle();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 14, 22, 8),
      child: Text(
        '设置',
        style: context.pin.tlg.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// 设置导航项（样式与 .nav-item 一致，复刻 PinSidebar 的 _NavTile）
class _SettingsNavItem extends StatelessWidget {
  const _SettingsNavItem(
    this.label, {
    required this.icon,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final PinIconData icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) {
        final bg = selected
            ? spec.selBg
            : (hover ? spec.hover : Colors.transparent);
        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: PinSize.navItem,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(PinRadius.sm),
            ),
            child: Stack(
              children: [
                Row(
                  children: [
                    PinIcon(
                      icon,
                      size: 15,
                      color: selected ? spec.selText : spec.text2,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: PinFontSize.sm,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: selected ? spec.selText : spec.text,
                          fontFamilyFallback: PinFont.sans,
                        ),
                      ),
                    ),
                  ],
                ),
                // 激活态左侧条（.nav-item.active::before）
                if (selected)
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
          ),
        );
      },
    );
  }
}

/// 侧栏底部用户卡（复刻 PinSidebar._SidebarFooter）
class _SidebarFooter extends StatelessWidget {
  const _SidebarFooter();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: spec.line)),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: spec.primaryTint,
            ),
            child: Text(
              '晓',
              style: TextStyle(
                fontSize: PinFontSize.xs,
                fontWeight: FontWeight.w600,
                color: spec.primaryStrong,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '李晓',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: spec.text,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '本地模式 · 数据已同步',
                  style: TextStyle(
                    fontSize: PinFontSize.xs2,
                    color: spec.faint,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ],
            ),
          ),
          PinIcon(PinIcons.sync, size: 13, color: spec.faint),
        ],
      ),
    );
  }
}

/// 外观设置内容区（.content）
class _AppearanceContent extends StatelessWidget {
  const _AppearanceContent();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.pin.bg,
      child: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageHead(title: '外观', subtitle: '主题、强调色、字号与桌面贴默认模式'),
            SizedBox(height: PinSpace.s4),
            _ThemeCard(),
            SizedBox(height: 20), // .set-card margin-bottom 20px
            _AccentCard(),
            SizedBox(height: 20),
            _FontSizeCard(),
            SizedBox(height: 20),
            _PinModeCard(),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

/// 设置卡（.card.set-card：margin 0 32 20、padding 22 24、max-width 940）
class _SetCard extends StatelessWidget {
  const _SetCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: PinSpace.s6),
      constraints: const BoxConstraints(maxWidth: 940),
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(color: spec.line),
      ),
      child: child,
    );
  }
}

/// 卡片标题（.set-card h3：13px 加粗、下距 16）
class _CardTitle extends StatelessWidget {
  const _CardTitle(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: PinSpace.s4),
      child: Text(
        label,
        style: context.pin.tsm.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// 卡片一：主题（.th-row：三块 236 宽的选择块）
class _ThemeCard extends StatelessWidget {
  const _ThemeCard();

  @override
  Widget build(BuildContext context) {
    return _SetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('主题'),
          // 窄窗口下 3 块 236px 超出卡宽（HTML 亦溢出）；横向滚动避免 RenderFlex 报错
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              children: [
                _ThemeTile(
                  on: true,
                  label: '浅色',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  preview: const _ThemePreview(
                    canvas: Color(0xFFFFFFFF), // 浅色画布 #fff
                    side: Color(0xFFF5F6F8), // 浅色侧栏 --color-surface-2
                    bar: Color(0xFFE4E7EC), // 浅色骨架条 --color-line
                  ),
                ),
                const SizedBox(width: 26),
                _ThemeTile(
                  label: '深色',
                  onTap: () =>
                      AppScope.of(context).toggle(), // dark.html → 主题切换
                  preview: const _ThemePreview(
                    canvas: Color(0xFF1E1F27), // 深色画布 --color-bg(dark)
                    side: Color(0xFF191A20), // 深色侧栏 --color-surface-2(dark)
                    bar: Color(0xFF2F313A), // 深色骨架条 --color-line(dark)
                  ),
                ),
                const SizedBox(width: 26),
                _ThemeTile(
                  label: '跟随系统',
                  onTap: () => Navigator.pushNamed(context, '/settings'),
                  preview: const _ThemePreview.split(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 主题选择块（.th-tile：预览小样 + 单选 + 标签）
class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.label,
    required this.preview,
    required this.onTap,
    this.on = false,
  });

  final String label;
  final Widget preview;
  final VoidCallback onTap;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 236,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 预览小样（.th-prev：高 78；on 态主色 1.5px 描边）
              Container(
                height: 78,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(PinRadius.sm),
                  border: Border.all(
                    color: on ? spec.primary : spec.line,
                    width: on ? 1.5 : 1,
                  ),
                ),
                child: preview,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  children: [
                    PinRadio(on: on),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: PinFontSize.xs,
                        fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                        color: on ? spec.text : spec.text2,
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

/// 主题预览小样（.th-prev 内部：侧栏条 + 骨架条；色值为设计稿写死色）
class _ThemePreview extends StatelessWidget {
  const _ThemePreview({
    required this.canvas,
    required this.side,
    required this.bar,
  });

  /// 跟随系统：左右对分（.th-prev 的两半）
  const _ThemePreview.split() : canvas = null, side = null, bar = null;

  final Color? canvas;
  final Color? side;
  final Color? bar;

  @override
  Widget build(BuildContext context) {
    if (canvas == null) {
      return Row(
        children: [
          Expanded(
            child: _half(
              const Color(0xFFFFFFFF), // 浅色画布 #fff
              const Color(0xFFF5F6F8),
              const Color(0xFFE4E7EC),
            ),
          ),
          Expanded(
            child: _half(
              const Color(0xFF1E1F27), // 深色画布
              const Color(0xFF191A20),
              const Color(0xFF2F313A),
            ),
          ),
        ],
      );
    }
    return _half(canvas!, side!, bar!);
  }

  Widget _half(Color canvasColor, Color sideColor, Color barColor) {
    return Container(
      color: canvasColor,
      child: Row(
        children: [
          Container(width: 44, color: sideColor), // .th-side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 0), // .th-bars
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _PreviewBar(0.70, barColor),
                  const SizedBox(height: 7),
                  _PreviewBar(0.50, barColor),
                  const SizedBox(height: 7),
                  _PreviewBar(0.60, barColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 骨架条（.th-bars i：高 8、圆角 4、按比例宽度）
class _PreviewBar extends StatelessWidget {
  const _PreviewBar(this.factor, this.color);

  final double factor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: factor,
        child: Container(
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}

/// 卡片二：强调色（.acc-row：8 圆点 + 虚线加号）
class _AccentCard extends StatelessWidget {
  const _AccentCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return _SetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('强调色'),
          Row(
            children: [
              _AccentDot(color: spec.primary, on: true),
              const SizedBox(width: 18),
              _AccentDot(color: spec.success),
              const SizedBox(width: 18),
              _AccentDot(color: spec.teal),
              const SizedBox(width: 18),
              _AccentDot(color: spec.violet),
              const SizedBox(width: 18),
              _AccentDot(color: spec.pink),
              const SizedBox(width: 18),
              _AccentDot(color: spec.warning),
              const SizedBox(width: 18),
              _AccentDot(color: spec.danger),
              const SizedBox(width: 18),
              // 设计稿写死的炭灰圆点（settings.html 内联色 #383A42）
              const _AccentDot(color: Color(0xFF383A42)),
              const SizedBox(width: 18),
              const _AccentAdd(),
            ],
          ),
        ],
      ),
    );
  }
}

/// 强调色圆点（.acc-dot：34 圆；on 态主色 outline 2px + offset 3px）
class _AccentDot extends StatelessWidget {
  const _AccentDot({required this.color, this.on = false});

  final Color color;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final dot = Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
    if (!on) return dot;
    // outline 2px + offset 3px → 外扩 44 的主色圆环
    return Container(
      width: 44,
      height: 44,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: spec.primary, width: 2),
      ),
      child: Center(child: dot),
    );
  }
}

/// 添加自定义强调色（.acc-add：34 圆虚线描边 + 加号）
class _AccentAdd extends StatelessWidget {
  const _AccentAdd();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, _, _) => GestureDetector(
        onTap: () {},
        child: SizedBox(
          width: 34,
          height: 34,
          child: CustomPaint(
            painter: _DashedCirclePainter(color: spec.lineStrong, width: 1.4),
            child: Center(
              child: PinIcon(PinIcons.plus, size: 13, color: spec.faint),
            ),
          ),
        ),
      ),
    );
  }
}

/// 卡片三：界面字号（.seg + 示例文本）
class _FontSizeCard extends StatelessWidget {
  const _FontSizeCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return _SetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('界面字号'),
          Row(
            children: [
              const PinSeg(items: ['小', '中', '大'], onIndex: 1),
              const SizedBox(width: 28),
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: '今天 · 设计评审材料准备 '),
                    TextSpan(
                      text: 'Aa 123',
                      style: spec.tmd.copyWith(color: spec.text2),
                    ),
                  ],
                  style: spec.tmd,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 卡片四：桌面贴默认模式（.mode-row：单选 + 标题 / 说明）
class _PinModeCard extends StatelessWidget {
  const _PinModeCard();

  @override
  Widget build(BuildContext context) {
    return _SetCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle('桌面贴默认模式'),
          const _ModeRow(
            on: true,
            title: '壁纸层（推荐）',
            desc: '嵌入桌面壁纸层，不遮挡任何窗口，Win+D 不受影响',
          ),
          const SizedBox(height: 14),
          const _ModeRow(title: '置顶显示', desc: '始终位于所有窗口之上，适合当前最重要的一件事'),
          // 两种模式切换入口（.link → pin-controls.html）
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 6),
            child: PinLink(
              '两种模式可在桌面贴右键菜单中随时切换 →',
              fontSize: PinFontSize.xs,
              onTap: () => Navigator.pushNamed(context, '/pin-controls'),
            ),
          ),
        ],
      ),
    );
  }
}

/// 默认模式行（.mode-row：单选 + 标题 / 说明）
class _ModeRow extends StatelessWidget {
  const _ModeRow({required this.title, required this.desc, this.on = false});

  final String title;
  final String desc;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: PinRadio(on: on),
        ),
        const SizedBox(width: PinSpace.s3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: spec.tsm.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Text(desc, style: spec.txs.copyWith(color: spec.text2)),
            ],
          ),
        ),
      ],
    );
  }
}

/// 虚线圆描边画笔（Flutter Border 不支持 dashed，按 CSS `dashed` 视觉复刻）
class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color, required this.width});

  final Color color;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..color = color;
    final path = Path()
      ..addOval(
        Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2 - width / 2,
        ),
      );
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
  bool shouldRepaint(_DashedCirclePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.width != width;
}
