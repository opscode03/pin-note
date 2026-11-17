/// 贴记 PinNote · 登录与账户（对应 ui/account.html）
///
/// 画布页：欢迎卡（460 宽，本地 / 同步双选项）+ 登录卡（460 宽）。
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/navigation.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/chips.dart';
import '../widgets/controls.dart';
import '../widgets/interactive.dart';
import '../widgets/toast.dart';

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
class _LoginCard extends StatefulWidget {
  const _LoginCard();

  @override
  State<_LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<_LoginCard> {
  final TextEditingController _phone =
      TextEditingController(text: '13800138000');
  final TextEditingController _code = TextEditingController();
  Timer? _timer;
  int _countdown = 0;
  String? _error;

  @override
  void dispose() {
    _timer?.cancel();
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  bool _validPhone() {
    return RegExp(r'^1\d{10}$').hasMatch(_phone.text.trim());
  }

  void _sendCode() {
    if (!_validPhone()) {
      setState(() => _error = '请输入 11 位手机号');
      return;
    }
    setState(() {
      _error = null;
      _countdown = 60;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
      } else {
        setState(() => _countdown -= 1);
      }
    });
    showPinToast(
      context,
      title: '验证码已发送（本地演示）',
      subtitle: '演示验证码：123456；尚未接入短信服务',
      icon: PinIcons.bell,
    );
  }

  void _submit() {
    if (!_validPhone()) {
      setState(() => _error = '请输入 11 位手机号');
      return;
    }
    if (_code.text.trim() != '123456') {
      setState(() => _error = '请输入本地演示验证码 123456');
      return;
    }
    setState(() => _error = null);
    showPinToast(
      context,
      title: '输入校验通过',
      subtitle: '同步服务尚未接入，本次未创建云端账户',
      icon: PinIcons.info,
    );
    AppNav.go(context, '/');
  }

  void _thirdParty(String provider) {
    showPinToast(
      context,
      title: '$provider 尚未接入',
      subtitle: '当前版本仅支持本地数据模式',
      icon: PinIcons.info,
    );
  }

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
        _LoginField(
          icon: PinIcons.person,
          controller: _phone,
          hint: '手机号',
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
        ),
        const SizedBox(height: 12),
        _LoginField(
          icon: PinIcons.lock,
          controller: _code,
          hint: '输入 6 位验证码',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          trailing: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: PinLink(
              _countdown > 0 ? '${_countdown}s 后重发' : '获取验证码',
              fontSize: PinFontSize.xs,
              onTap: _countdown == 0 ? _sendCode : null,
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: spec.txs.copyWith(color: spec.dangerStrong),
          ),
        ],
        const SizedBox(height: 20),
        PinButton(
          '登录 / 注册',
          size: PinButtonSize.xl,
          expand: true,
          onTap: _submit,
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
                onTap: () => _thirdParty('微信登录'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SocialButton(
                label: 'Apple 登录',
                dot: const Color(0xFF383A42), // Apple 黑（设计稿固定色）
                onTap: () => _thirdParty('Apple 登录'),
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

/// 登录输入框（.field 42 高：图标 + 真实输入 + 可选右侧动作）
class _LoginField extends StatelessWidget {
  const _LoginField({
    required this.icon,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
    this.trailing,
  });

  final PinIconData icon;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
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
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                style: spec.tsm,
                cursorColor: spec.primary,
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: hint,
                  hintStyle: spec.tsm.copyWith(color: spec.faint),
                ),
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: PinSpace.s2),
            trailing!,
          ],
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
