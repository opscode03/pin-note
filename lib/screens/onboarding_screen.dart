/// 贴记 PinNote · 首次启动引导（对应 ui/onboarding.html）
///
/// 画布页：欢迎卡（500 宽）+ 教学卡（560 宽，内嵌 mini 桌面场景）。
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/chips.dart';
import '../widgets/interactive.dart';
import '../widgets/scene.dart';
import '../widgets/sticky_note.dart';

/// 引导画布页：第 1 步欢迎卡 + 第 2 步教学卡
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CanvasPage(
      children: [
        Artboard(
          width: 500,
          padding: EdgeInsets.fromLTRB(44, 40, 44, 30),
          child: _WelcomeCard(),
        ),
        Artboard(
          width: 560,
          padding: EdgeInsets.fromLTRB(40, 40, 40, 30),
          child: _TeachCard(),
        ),
      ],
    );
  }
}

/// 欢迎卡（.ob-card：居中排版 + 三条 feat + 主按钮 + 步骤指示）
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: PinLogo(size: 72)),
        const SizedBox(height: 22),
        Text(
          '把重要的事，贴在眼前。',
          textAlign: TextAlign.center,
          style: spec.t2xl.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.22,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '轻量好看的待办与便签 · 贴在桌面 · 全端同步',
          textAlign: TextAlign.center,
          style: spec.tsm.copyWith(color: spec.text2),
        ),
        const SizedBox(height: 20),
        const _Feat(icon: PinIcons.pin, title: '桌面贴', desc: '重要的事常驻桌面，一抬头就能看到'),
        const SizedBox(height: 20),
        const _Feat(
          icon: PinIcons.zap,
          title: '快速捕获',
          desc: '任何应用内 Ctrl+Shift+Space，1 秒记下想法',
        ),
        const SizedBox(height: 20),
        const _Feat(
          icon: PinIcons.sync,
          title: '全端同步',
          desc: '手机上记的内容，回到电脑时已在桌面',
        ),
        const SizedBox(height: 30),
        PinButton(
          '开始使用',
          size: PinButtonSize.xl,
          expand: true,
          onTap: () => Navigator.pushNamed(context, '/'),
        ),
        const SizedBox(height: 14),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: PinLink(
              '已有账号？登录并同步 →',
              fontSize: PinFontSize.xs,
              onTap: () => Navigator.pushNamed(context, '/account'),
            ),
          ),
        ),
        const SizedBox(height: 26),
        const Center(child: _Steps(on: 0)),
        const SizedBox(height: 10),
        Text(
          '第 1 步 · 欢迎页（共 3 步）',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            color: spec.faint,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}

/// 特性行（.feat：46px 主色浅底圆 + 图标 + 标题 / 说明）
class _Feat extends StatelessWidget {
  const _Feat({required this.icon, required this.title, required this.desc});

  final PinIconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: spec.primaryTint,
          ),
          child: Center(
            child: PinIcon(icon, size: 20, color: spec.primaryStrong),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: spec.tmd.copyWith(fontWeight: FontWeight.w600),
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

/// 步骤指示点（.steps：8px 圆点，当前步 18px 主色胶囊）
class _Steps extends StatelessWidget {
  const _Steps({required this.on});

  final int on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 3; i++) ...[
          if (i > 0) const SizedBox(width: 7),
          Container(
            width: i == on ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              // .steps i 背景 #D6DAE2，与 --color-line-strong 一致
              color: i == on ? spec.primary : spec.lineStrong,
              borderRadius: BorderRadius.circular(PinRadius.full),
            ),
          ),
        ],
      ],
    );
  }
}

/// 教学卡（.teach：左上步骤 Chip + mini 桌面场景 + 完成按钮）
class _TeachCard extends StatelessWidget {
  const _TeachCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            Text(
              '试试把便签贴到桌面',
              textAlign: TextAlign.center,
              style: spec.txl.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 18),
            const _MiniScene(),
            const SizedBox(height: 26),
            PinButton(
              '完成，进入贴记',
              size: PinButtonSize.xl,
              expand: true,
              onTap: () => Navigator.pushNamed(context, '/'),
            ),
            const SizedBox(height: 12),
            Center(
              child: HoverBuilder(
                builder: (context, _, _) => GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    child: Text(
                      '跳过引导',
                      style: spec.txs.copyWith(color: spec.text2),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 26),
            const Center(child: _Steps(on: 1)),
            const SizedBox(height: 10),
            Text(
              '第 2 步 · 贴第一张（教学页）',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: PinFontSize.xs2,
                color: spec.faint,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
          ],
        ),
        // 左上步骤 Chip（.step-chip：画板 left 32 / top 28，内容区已含 40 内边距）
        const Positioned(left: -8, top: -12, child: PinChip('第 2 步 · 共 3 步')),
      ],
    );
  }
}

/// mini 桌面场景（.mini-scene：300 高壁纸 + 胶带便签 + 白色标注 + 迷你任务栏）
class _MiniScene extends StatelessWidget {
  const _MiniScene();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(
          color: const Color(0x24FFFFFF),
        ), // rgba(255,255,255,.14)
      ),
      child: WallpaperScene(
        variant: 'a',
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // 欢迎便签（.welcome-note）：水平居中、top 54、旋转 -2°
            // Transform.rotate 非 const 构造，Positioned 不加 const
            Positioned(
              left: 0,
              right: 0,
              top: 54,
              child: Center(
                child: Transform.rotate(
                  angle: -2 * math.pi / 180,
                  child: const SizedBox(
                    width: 216,
                    child: PinSticky(
                      color: StickyColor.lemon,
                      tape: true,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 16,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StickyTitle('欢迎来到贴记', fontSize: 14),
                          StickyLine('这是你的第一张桌面贴'),
                          StickyLine('双击可以再次编辑'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              right: 22,
              top: 46,
              child: _Callout('拖动 · 摆放位置', lineOnLeft: true),
            ),
            const Positioned(
              right: 22,
              top: 128,
              child: _Callout('Ctrl + 滚轮 · 缩放', lineOnLeft: true),
            ),
            const Positioned(
              left: 26,
              bottom: 26,
              child: _Callout('右键 · 更多设置', lineOnLeft: false),
            ),
            // 底部迷你任务栏（.mini-tb）
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 32,
                color: const Color(0xD10E121A), // rgba(14,18,26,.82)
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < 5; i++) ...[
                      if (i > 0) const SizedBox(width: 10),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(
                            0x47FFFFFF,
                          ), // rgba(255,255,255,.28)
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 白色标注胶囊（.callout：白底圆角 full、阴影 0 8 20 rgba(8,14,28,.4)，
/// 外侧 16px 白色指示线指向便签）
class _Callout extends StatelessWidget {
  const _Callout(this.text, {required this.lineOnLeft});

  final String text;
  final bool lineOnLeft;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 30,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(PinRadius.full)),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 8),
                blurRadius: 20,
                color: Color(0x66080E1C), // rgba(8,14,28,.4)
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: PinFontSize.xs2,
              color: spec.text,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ),
        // 指示线（.callout::before：16×1.5 rgba(255,255,255,.65)）
        Positioned(
          left: lineOnLeft ? -20 : null,
          right: lineOnLeft ? null : -20,
          top: 14.25,
          child: Container(
            width: 16,
            height: 1.5,
            color: const Color(0xA6FFFFFF), // rgba(255,255,255,.65)
          ),
        ),
      ],
    );
  }
}
