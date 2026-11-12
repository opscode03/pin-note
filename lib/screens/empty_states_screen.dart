/// 贴记 PinNote · 空状态与反馈（对应 ui/empty-states.html）
///
/// 画布页：A 今日 / B 便签库 / C 回收站 / D Toast 四张画板。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/menu.dart';
import '../widgets/sticky_note.dart';

/// 空状态与反馈画布页
class EmptyStatesScreen extends StatelessWidget {
  const EmptyStatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CanvasPage(
      children: [
        Artboard(
          width: 460,
          padding: EdgeInsets.fromLTRB(26, 20, 26, 28),
          child: _EmptyCard(
            tag: 'A · 今日',
            tagNote: '情绪安抚 + 引导创建',
            body: _TodayBody(),
          ),
        ),
        Artboard(
          width: 460,
          padding: EdgeInsets.fromLTRB(26, 20, 26, 28),
          child: _EmptyCard(
            tag: 'B · 便签库',
            tagNote: '堆叠插画 + 双入口',
            body: _NotesBody(),
          ),
        ),
        Artboard(
          width: 460,
          padding: EdgeInsets.fromLTRB(26, 20, 26, 28),
          child: _EmptyCard(
            tag: 'C · 回收站',
            tagNote: '说明数据保留策略',
            body: _TrashBody(),
          ),
        ),
        Artboard(
          width: 460,
          padding: EdgeInsets.fromLTRB(26, 20, 26, 28),
          child: _EmptyCard(
            tag: 'D · Toast',
            tagNote: '操作反馈 · 5 秒消失 · 可撤销',
            body: _ToastBody(),
          ),
        ),
      ],
    );
  }
}

/// 空状态画板骨架（.es-card：左上角标签 + 居中内容，min 高 380）
class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.tag,
    required this.tagNote,
    required this.body,
  });

  final String tag;
  final String tagNote;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 380),
          alignment: Alignment.center,
          child: body,
        ),
        // 标签（.es-tag：画板 left 22 / top 18，内容区已含 26/20 内边距）
        Positioned(
          left: -4,
          top: -2,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(tag, style: spec.tmd.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(width: 8),
              Text(
                tagNote,
                style: TextStyle(
                  fontSize: PinFontSize.xs2,
                  color: spec.text2,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A · 今日：插画圆 + 文案 + 双按钮
class _TodayBody extends StatelessWidget {
  const _TodayBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Illus(
          bg: context.pin.primaryTint,
          icon: PinIcons.pin,
          iconColor: context.pin.primary,
          badgeColor: context.pin.success,
        ),
        const SizedBox(height: 22),
        Text(
          '今天没有任务了，去喝口水吧',
          textAlign: TextAlign.center,
          style: context.pin.tlg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        Text(
          '已完成 3 项 · 明天还有 2 项安排',
          textAlign: TextAlign.center,
          style: context.pin.txs.copyWith(color: context.pin.text2),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PinButton(
              '添加任务',
              icon: PinIcons.plus,
              onTap: () => AppNav.go(context, '/'),
            ),
            const SizedBox(width: 12),
            PinButton(
              '从便签创建',
              variant: PinButtonVariant.secondary,
              onTap: () => AppNav.go(context, '/notes'),
            ),
          ],
        ),
      ],
    );
  }
}

/// B · 便签库：三张便签错位堆叠 + 文案 + 双按钮
class _NotesBody extends StatelessWidget {
  const _NotesBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 200,
          height: 110,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // .stack .sticky：118 宽、padding 14；lemon -7° / sky 0° / cherry +7°
              Positioned(
                left: 6,
                top: 14,
                child: Transform.rotate(
                  angle: -7 * math.pi / 180,
                  child: const _MiniSticky(StickyColor.lemon),
                ),
              ),
              const Positioned(
                left: 44,
                top: 8,
                child: _MiniSticky(StickyColor.sky),
              ),
              Positioned(
                left: 80,
                top: 16,
                child: Transform.rotate(
                  angle: 7 * math.pi / 180,
                  child: const _MiniSticky(StickyColor.cherry),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Text(
          '第一张便签，从一个想法开始',
          textAlign: TextAlign.center,
          style: context.pin.tlg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        Text(
          '富文本 · 清单 · 8 种颜色 · 一键贴桌面',
          textAlign: TextAlign.center,
          style: context.pin.txs.copyWith(color: context.pin.text2),
        ),
        const SizedBox(height: 22),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PinButton(
              '新建便签',
              icon: PinIcons.plus,
              onTap: () => AppNav.go(context, '/note-editor'),
            ),
            const SizedBox(width: 12),
            PinButton(
              '从 Windows 便签导入',
              variant: PinButtonVariant.secondary,
              onTap: () {},
            ),
          ],
        ),
      ],
    );
  }
}

/// 堆叠用的空白便签（.stack .sticky：118 宽、padding 14、无内容）
class _MiniSticky extends StatelessWidget {
  const _MiniSticky(this.color);

  final StickyColor color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      child: PinSticky(
        color: color,
        padding: const EdgeInsets.all(14),
        child: const SizedBox.shrink(),
      ),
    );
  }
}

/// C · 回收站：灰底插画圆 + 保留策略说明 + 链接
class _TrashBody extends StatelessWidget {
  const _TrashBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Illus(
          bg: context.pin.surface3,
          icon: PinIcons.trash,
          iconColor: context.pin.faint,
        ),
        const SizedBox(height: 22),
        Text(
          '回收站是空的',
          textAlign: TextAlign.center,
          style: context.pin.tlg.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 9),
        Text(
          '删除的任务与便签会在这里保留 30 天，之后永久删除',
          textAlign: TextAlign.center,
          style: context.pin.txs.copyWith(color: context.pin.text2),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: PinLink('了解数据安全与隐私 →', fontSize: PinFontSize.xs, onTap: () {}),
        ),
      ],
    );
  }
}

/// D · Toast：完成反馈 + 同步状态两组示例
class _ToastBody extends StatelessWidget {
  const _ToastBody();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PinToast(
              title: '已完成「背 50 个单词」',
              subtitle: '重复任务已顺延至明天',
              iconBg: spec.successTint,
              iconColor: spec.successStrong,
              action: '撤销',
            ),
            const SizedBox(height: 12),
            Text(
              '完成反馈 · Ctrl+Z 可撤销',
              style: TextStyle(
                fontSize: PinFontSize.xs2,
                color: spec.faint,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ],
        ),
        const SizedBox(height: 26),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            PinToast(
              title: '已同步 12 条更新',
              iconBg: spec.primaryTint,
              iconColor: spec.primaryStrong,
              icon: PinIcons.sync,
              trailing: '刚刚',
            ),
            const SizedBox(height: 12),
            Text(
              '同步状态 · 静默提示',
              style: TextStyle(
                fontSize: PinFontSize.xs2,
                color: spec.faint,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 空状态插画圆（.illus：96px 圆 + 42px 图标；[badgeColor] 右下 28px 徽章）
class _Illus extends StatelessWidget {
  const _Illus({
    required this.bg,
    required this.icon,
    required this.iconColor,
    this.badgeColor,
  });

  final Color bg;
  final PinIconData icon;
  final Color iconColor;
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(shape: BoxShape.circle, color: bg),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          PinIcon(icon, size: 42, color: iconColor),
          if (badgeColor != null)
            Positioned(
              right: 2,
              bottom: 6,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badgeColor,
                  border: Border.all(color: spec.surface, width: 2.5),
                ),
                child: const Center(
                  child: PinIcon(PinIcons.check, size: 13, color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
