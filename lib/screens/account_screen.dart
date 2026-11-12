/// 贴记 PinNote · 登录与账户（对应 ui/account.html）
///
/// 画布页：欢迎卡（460 宽，本地 / 同步双选项）+ 登录卡（460 宽）。
library;

import 'package:flutter/material.dart';

import '../app/navigation.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/chips.dart';
import '../widgets/controls.dart';
import '../widgets/interactive.dart';

/// 账户画布页：欢迎卡 + 登录卡
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CanvasPage(
      children: [
        Artboard(
          width: 460,
          padding: EdgeInsets.fromLTRB(40, 44, 40, 30),
          child: _WelcomeCard(),
        ),
        Artboard(
          width: 460,
          padding: EdgeInsets.fromLTRB(40, 40, 40, 28),
          child: _LoginCard(),
        ),
      ],
    );
  }
}

/// 欢迎卡（.acc-card：Logo + 标题 + 两个模式选项 + 主按钮 + 底部说明）
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Center(child: PinLogo(size: 56)),
        const SizedBox(height: 18),
        Text(
          '欢迎使用贴记',
          textAlign: TextAlign.center,
          style: spec.t2xl.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          '数据默认保存在本机 · 随时可开启同步',
          textAlign: TextAlign.center,
          style: spec.txs.copyWith(color: spec.text2),
        ),
        const SizedBox(height: 16),
        const _AccountOption(
          icon: PinIcons.folder,
          title: '先在本地使用',
          desc: '无需账号，数据仅保存在这台电脑，可随时导出',
          on: true,
        ),
        const SizedBox(height: 16),
        const _AccountOption(
          icon: PinIcons.sync,
          title: '登录并同步（推荐）',
          desc: '手机、平板、电脑多端实时同步，端到端加密',
        ),
        const SizedBox(height: 24),
        PinButton(
          '开始使用',
          size: PinButtonSize.xl,
          expand: true,
          onTap: () => AppNav.go(context, '/'),
        ),
        const SizedBox(height: 16),
        Text(
          '本地模式可随时在 设置 → 账户 中升级登录，数据自动合并',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: PinFontSize.xs2,
            color: spec.text2,
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}

/// 模式选项卡（.opt：44px 圆图标 + 标题/说明 + 右侧单选，
/// 选中 .opt-on 描边主色，悬停描边加深）
class _AccountOption extends StatelessWidget {
  const _AccountOption({
    required this.icon,
    required this.title,
    required this.desc,
    this.on = false,
  });

  final PinIconData icon;
  final String title;
  final String desc;
  final bool on;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: () => AppNav.go(context, '/'),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: spec.surface,
            borderRadius: BorderRadius.circular(PinRadius.md),
            border: Border.all(
              color: on ? spec.primary : (hover ? spec.faint : spec.lineStrong),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: on ? spec.primaryTint : spec.surface3,
                ),
                child: Center(
                  child: PinIcon(
                    icon,
                    size: 20,
                    color: on ? spec.primaryStrong : spec.text2,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: spec.tlg.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(desc, style: spec.txs.copyWith(color: spec.text2)),
                  ],
                ),
              ),
              PinRadio(on: on),
            ],
          ),
        ),
      ),
    );
  }
}

/// 登录卡（.login：分段切换 + 两个输入框 + 主按钮 + 社交登录 + 协议行）
class _LoginCard extends StatelessWidget {
  const _LoginCard();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '登录贴记',
          textAlign: TextAlign.center,
          style: spec.txl.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 18),
        // .tabs：登录页分段控件（选中项在设计稿中为主色浅底）
        const Center(child: PinSeg(items: ['手机号', '邮箱'], onIndex: 0)),
        const SizedBox(height: 22),
        const _LoginField(
          icon: PinIcons.person,
          text: '138 0013 8000',
          caret: true,
        ),
        const SizedBox(height: 12),
        _LoginField(
          icon: PinIcons.lock,
          text: '输入 6 位验证码',
          placeholder: true,
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: PinLink(
              '获取验证码',
              fontSize: PinFontSize.xs,
              onTap: () => AppNav.go(context, '/'),
            ),
          ),
        ),
        const SizedBox(height: 20),
        PinButton(
          '登录 / 注册',
          size: PinButtonSize.xl,
          expand: true,
          onTap: () => AppNav.go(context, '/'),
        ),
        const SizedBox(height: 22),
        // 「或」分隔（.divider：两侧细线）
        Row(
          children: [
            Expanded(child: Container(height: 1, color: spec.line)),
            const SizedBox(width: 12),
            Text(
              '或',
              style: TextStyle(
                fontSize: PinFontSize.xs2,
                color: spec.text2,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Container(height: 1, color: spec.line)),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _SocialButton(
                label: '微信登录',
                dot: const Color(0xFF58BE6C), // 微信绿（设计稿固定色）
                onTap: () => AppNav.go(context, '/'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Apple 登录',
                dot: const Color(0xFF383A42), // Apple 黑（设计稿固定色）
                onTap: () => AppNav.go(context, '/'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Center(
          child: PinChip(
            '支持端到端加密（Pro）',
            style: PinChipStyle.green,
            size: PinChipSize.lg,
            icon: PinIcons.lock,
          ),
        ),
        const SizedBox(height: 18),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '登录即代表同意',
              style: TextStyle(
                fontSize: PinFontSize.xs2,
                color: spec.text2,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
            PinLink('《用户协议》', fontSize: PinFontSize.xs2, onTap: () {}),
            Text(
              '与',
              style: TextStyle(
                fontSize: PinFontSize.xs2,
                color: spec.text2,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
            PinLink('《隐私政策》', fontSize: PinFontSize.xs2, onTap: () {}),
          ],
        ),
      ],
    );
  }
}

/// 登录输入框（.field 42 高：图标 + 文本 + 光标；[trailing] 右侧动作）
class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.icon,
    required this.text,
    this.placeholder = false,
    this.caret = false,
    this.trailing,
  });

  final PinIconData icon;
  final String text;
  final bool placeholder;
  final bool caret;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(horizontal: PinSpace.s3),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.sm),
        border: Border.all(color: spec.lineStrong),
      ),
      child: Row(
        children: [
          PinIcon(icon, size: 16, color: spec.faint),
          const SizedBox(width: PinSpace.s2),
          Text(
            text,
            style: placeholder
                ? spec.tsm.copyWith(color: spec.faint)
                : spec.tsm,
          ),
          if (caret) ...[
            const SizedBox(width: PinSpace.s2),
            Container(width: 1.5, height: 16, color: spec.primary),
          ],
          if (trailing != null) ...[const Spacer(), trailing!],
        ],
      ),
    );
  }
}

/// 社交登录按钮（.social .btn-secondary：15px 品牌色点 + 文案）
class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.dot, this.onTap});

  final String label;
  final Color dot;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: PinMotion.dur,
          curve: PinMotion.ease,
          height: 42,
          decoration: BoxDecoration(
            color: spec.surface,
            borderRadius: BorderRadius.circular(PinRadius.sm),
            border: Border.all(color: hover ? spec.faint : spec.lineStrong),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 15,
                height: 15,
                decoration: BoxDecoration(shape: BoxShape.circle, color: dot),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontSize: PinFontSize.sm,
                  fontWeight: FontWeight.w500,
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
