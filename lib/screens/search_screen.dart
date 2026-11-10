/// 贴记 PinNote · 搜索（对应 ui/search.html）
///
/// 主窗口 + 空内容区；搜索结果浮层（.popover.search-drop）贴在标题栏下方居中：
/// 「任务 / 便签 / 清单与标签」三组结果行 + 底部快捷键提示。
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/chips.dart';
import '../widgets/controls.dart';
import '../widgets/interactive.dart';
import '../widgets/sidebar.dart';

/// 搜索页（search.html：标题栏激活搜索胶囊 + 空内容区 + 结果浮层）
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    // .search-drop { width: min(600px, 62vw); top: 60px; 水平居中 }
    final dropWidth = width * 0.62 < 600 ? width * 0.62 : 600.0;

    return Stack(
      children: [
        PinAppWindow(
          // 标题栏搜索胶囊为激活态（.tb-search.active-state：评审 + 光标 + Esc）
          titleBar: const PinTitleBar(
            searchActive: true,
            searchText: '评审',
            searchTrailing: ['Esc'],
          ),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PinSidebar(items: _navItems(context)),
              const Expanded(child: _EmptyContent()),
            ],
          ),
        ),
        // 结果浮层（.popover.search-drop）
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Center(child: _SearchDrop(width: dropWidth)),
        ),
      ],
    );
  }
}

/// 侧栏（与 search.html 一致：清单只有收件箱/工作/生活，标签只有重要/设计）
List<Object> _navItems(BuildContext context) {
  final spec = context.pin;
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
    const SidebarEntry('收件箱', dotColor: PinListDots.inbox, badge: '3'),
    const SidebarEntry('工作', dotColor: PinListDots.work, badge: '12'),
    const SidebarEntry('生活', dotColor: PinListDots.life, badge: '9'),
    const SidebarHeader('标签'),
    // nav-hash 色取自语义色（--color-danger-strong / --color-primary-strong）
    SidebarEntry('重要', hashColor: spec.dangerStrong),
    SidebarEntry('设计', hashColor: spec.primaryStrong),
  ];
}

/// 空内容区（<main class="content"></main>；底色沿用内容区 --color-bg）
class _EmptyContent extends StatelessWidget {
  const _EmptyContent();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: context.pin.bg);
  }
}

/// 搜索结果浮层（.search-drop：padding 10）
class _SearchDrop extends StatelessWidget {
  const _SearchDrop({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: width,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.lg),
        border: Border.all(color: spec.line),
        boxShadow: spec.shadowFar,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _GroupLabel('任务 · 2'),
          _ResultRow(
            focus: true,
            onTap: () => Navigator.pushNamed(context, '/task-edit'),
            leading: const PinCheckbox(),
            title: const PinHighlightText('设计评审材料准备', query: '评审'),
            trailing: const _MetaText('今天 14:00 · 工作'),
          ),
          _ResultRow(
            onTap: () => Navigator.pushNamed(context, '/task-edit'),
            leading: const PinCheckbox(done: true),
            // 已完成任务：整行划线，「评审」再加主色下划线
            title: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: '提交年度设计'),
                  TextSpan(
                    text: '评审',
                    style: TextStyle(
                      fontSize: PinFontSize.sm,
                      fontWeight: FontWeight.w700,
                      color: spec.primaryStrong,
                      decoration: TextDecoration.combine([
                        TextDecoration.underline,
                        TextDecoration.lineThrough,
                      ]),
                      decorationColor: spec.primary,
                      decorationThickness: 1.5,
                    ),
                  ),
                  const TextSpan(text: '材料'),
                ],
                style: TextStyle(
                  fontSize: PinFontSize.sm,
                  color: spec.text2,
                  decoration: TextDecoration.lineThrough,
                  decorationColor: spec.faint,
                ),
              ),
            ),
            trailing: const _MetaText('11月6日 · 已完成'),
          ),
          const _GroupLabel('便签 · 1'),
          _ResultRow(
            onTap: () => Navigator.pushNamed(context, '/note-editor'),
            leading: PinIcon(PinIcons.note, size: 16, color: spec.text2),
            title: const PinHighlightText('设计评审准备', query: '评审'),
            trailing: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PinChip('桌面贴', icon: PinIcons.pin, style: PinChipStyle.accent),
                SizedBox(width: PinSpace.s2),
                _MetaText('柠檬黄 · 2 小时前'),
              ],
            ),
          ),
          const _GroupLabel('清单与标签 · 1'),
          _ResultRow(
            onTap: () => Navigator.pushNamed(context, '/notes'),
            leading: PinIcon(PinIcons.tag, size: 16, color: spec.violetStrong),
            title: Text(
              '#设计',
              style: spec.tsm.copyWith(
                color: spec.violetStrong,
                fontWeight: FontWeight.w700,
              ),
            ),
            title2: Text(
              '— 查看该标签下的 12 条内容',
              style: spec.tsm.copyWith(color: spec.text2),
            ),
            trailing: const _MetaText('标签'),
          ),
          // 底部快捷键提示（.sd-foot）
          Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 4),
            padding: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: spec.line)),
            ),
            child: const Row(
              children: [
                _FootHint(['↑', '↓'], '选择'),
                SizedBox(width: PinSpace.s4),
                _FootHint(['Enter'], '打开'),
                SizedBox(width: PinSpace.s4),
                _FootHint(['Esc'], '关闭'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 分组标题（.sd-group：margin 10 14 4、11px 加粗弱化色）
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
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

/// 11px 弱化元信息（.sd-meta）
class _MetaText extends StatelessWidget {
  const _MetaText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: context.pin.t2xs.copyWith(color: context.pin.faint),
    );
  }
}

/// 结果行（.sd-row：高 48、padding 0 14、圆角 8；focus 行选中底色）
class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.leading,
    required this.title,
    required this.trailing,
    required this.onTap,
    this.title2,
    this.focus = false,
  });

  final Widget leading;
  final Widget title;
  final Widget? title2;
  final Widget trailing;
  final VoidCallback onTap;
  final bool focus;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: focus
                ? spec.selBg
                : (hover ? spec.hover : Colors.transparent),
            borderRadius: BorderRadius.circular(PinRadius.sm),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: PinSpace.s3),
              title,
              if (title2 != null) ...[
                const SizedBox(width: PinSpace.s3),
                title2!,
              ],
              const Spacer(),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

/// 底部快捷键提示项（.sd-foot 里的 span：kbd + 说明文字）
class _FootHint extends StatelessWidget {
  const _FootHint(this.keys, this.label);

  final List<String> keys;
  final String label;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PinKbd(keys),
        const SizedBox(width: 4),
        Text(label, style: spec.t2xs.copyWith(color: spec.faint)),
      ],
    );
  }
}
