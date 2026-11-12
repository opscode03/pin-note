/// 贴记 PinNote · 应用窗口骨架（对应 app.css .win / .titlebar / .app-body / .canvas-page）
library;

import 'package:flutter/material.dart';

import '../app/app_scope.dart';
import '../app/navigation.dart';
import '../app/desktop_window.dart';
import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'buttons.dart';
import 'chips.dart';
import 'interactive.dart';

/// 应用 Logo（渐变圆角方块 + 白色图钉；对应 .logo / .logo-lg / .logo-xl）
class PinLogo extends StatelessWidget {
  const PinLogo({this.size = 24, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final iconSize = size <= 24
        ? 14.0
        : size <= 56
        ? 30.0
        : 38.0;
    final radius = size <= 24
        ? 7.0
        : size <= 56
        ? 16.0
        : 20.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [spec.primary, spec.primaryStrong],
        ),
      ),
      child: Center(
        child: PinIcon(PinIcons.pin, size: iconSize, color: Colors.white),
      ),
    );
  }
}

/// 自绘窗口按钮（Windows 风格：最小化 / 最大化 / 关闭）
class _WindowButtons extends StatelessWidget {
  const _WindowButtons();

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Row(
      children: [
        _WindowButton(
          onTap: DesktopWindow.minimize,
          icon: PinIcon(PinIcons.minus, size: 11, color: spec.text2),
        ),
        _WindowButton(
          onTap: DesktopWindow.toggleMaximize,
          icon: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              border: Border.all(color: spec.text2, width: 1),
            ),
          ),
        ),
        _WindowButton(
          onTap: DesktopWindow.close,
          icon: PinIcon(PinIcons.close, size: 11, color: spec.text2),
          hoverColor: const Color(0xFFC42B1C),
          hoverIconColor: Colors.white,
        ),
      ],
    );
  }
}

class _WindowButton extends StatefulWidget {
  const _WindowButton({
    required this.icon,
    required this.onTap,
    this.hoverColor,
    this.hoverIconColor,
  });

  final Widget icon;
  final VoidCallback onTap;
  final Color? hoverColor;
  final Color? hoverIconColor;

  @override
  State<_WindowButton> createState() => _WindowButtonState();
}

class _WindowButtonState extends State<_WindowButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: 46,
          height: 32,
          color: _hover ? (widget.hoverColor ?? Colors.transparent) : null,
          child: Center(
            child: widget.hoverIconColor != null && _hover
                ? PinIcon(
                    PinIcons.close,
                    size: 11,
                    color: widget.hoverIconColor,
                  )
                : widget.icon,
          ),
        ),
      ),
    );
  }
}

/// 标题栏（对应 .titlebar：Logo + 名称 + 居中搜索胶囊 + 右侧动作 + 窗口按钮区）
class PinTitleBar extends StatelessWidget {
  const PinTitleBar({
    this.searchActive = false,
    this.searchText,
    this.searchController,
    this.searchFocusNode,
    this.searchTrailing,
    this.trailing,
    super.key,
  });

  /// 搜索胶囊处于激活态（搜索页）
  final bool searchActive;
  final String? searchText;

  /// 激活态 + 真实输入：传入控制器后胶囊内渲染 TextField（搜索页实时过滤）
  final TextEditingController? searchController;

  /// 输入框焦点节点（可选）
  final FocusNode? searchFocusNode;

  /// 激活态时替换右侧 Ctrl+K 提示（如 Esc）
  final List<String>? searchTrailing;
  final List<Widget>? trailing;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final width = MediaQuery.sizeOf(context).width;
    final pillWidth = width * 0.4 < 380 ? width * 0.4 : 380.0;

    final Widget pill;
    if (searchController != null) {
      pill = _SearchPillInput(
        width: pillWidth,
        controller: searchController!,
        focusNode: searchFocusNode,
      );
    } else if (searchActive) {
      pill = _SearchPillActive(
        width: pillWidth,
        text: searchText ?? '',
        trailing: searchTrailing ?? const ['Esc'],
      );
    } else {
      pill = _SearchPillIdle(width: pillWidth);
    }

    return Container(
      height: PinSize.titlebar,
      decoration: BoxDecoration(color: spec.surface),
      child: Stack(
        children: [
          // 可拖拽区域
          // 注意：不要在这里挂 onDoubleTap —— DoubleTapGestureRecognizer 会把
          // 本区域内所有单击的手势裁定挂起约 300ms，导致标题栏按钮点击迟滞
          // （真机手感延迟 + 测试环境假时钟下永不裁定）。拖拽窗口用 onPanStart。
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanStart: (_) => DesktopWindow.startDragging(),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const PinLogo(),
                  const SizedBox(width: 10),
                  Text(
                    '贴记 PinNote',
                    style: TextStyle(
                      fontSize: PinFontSize.xs,
                      fontWeight: FontWeight.w600,
                      color: spec.text2,
                      fontFamilyFallback: PinFont.sans,
                    ),
                  ),
                  const Spacer(),
                  ...?trailing,
                  PinIconButton(
                    PinIcons.theme,
                    onTap: () => AppScope.of(context).toggle(),
                    tooltip: '切换主题',
                  ),
                  const SizedBox(width: 6),
                  PinIconButton(
                    PinIcons.gear,
                    onTap: () => AppNav.go(context, '/settings'),
                    tooltip: '设置',
                  ),
                  const SizedBox(width: 6),
                  const _WindowButtons(),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
          // 居中搜索胶囊
          Align(alignment: Alignment.center, child: pill),
        ],
      ),
    );
  }
}

/// 未激活搜索胶囊（.tb-search）
class _SearchPillIdle extends StatelessWidget {
  const _SearchPillIdle({required this.width});

  final double width;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: () => AppNav.go(context, '/search'),
        child: Container(
          width: width,
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: PinSpace.s3),
          decoration: BoxDecoration(
            color: spec.surface3,
            borderRadius: BorderRadius.circular(PinRadius.full),
            border: Border.all(color: hover ? spec.lineStrong : spec.line),
          ),
          child: Row(
            children: [
              PinIcon(PinIcons.search, size: 13, color: spec.faint),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '搜索任务与便签…',
                  style: TextStyle(
                    fontSize: PinFontSize.xs,
                    color: spec.faint,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ),
              const PinKbd(['Ctrl', 'K']),
            ],
          ),
        ),
      ),
    );
  }
}

/// 输入态搜索胶囊（搜索页：真 TextField + Esc）
class _SearchPillInput extends StatelessWidget {
  const _SearchPillInput({
    required this.width,
    required this.controller,
    this.focusNode,
  });

  final double width;
  final TextEditingController controller;
  final FocusNode? focusNode;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: width,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: PinSpace.s3),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.full),
        border: Border.all(color: spec.primary),
        boxShadow: [
          BoxShadow(blurRadius: 0, spreadRadius: 3, color: spec.primaryTint),
        ],
      ),
      child: Row(
        children: [
          PinIcon(PinIcons.search, size: 13, color: spec.text),
          const SizedBox(width: 8),
          Expanded(
            // 自绘 UI 无 Material 祖先：TextField 需要 Material（透明）
            child: Material(
              type: MaterialType.transparency,
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                style: TextStyle(
                  fontSize: PinFontSize.xs,
                  fontWeight: FontWeight.w600,
                  color: spec.text,
                  fontFamilyFallback: PinFont.sans,
                ),
                cursorColor: spec.primary,
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const PinKbd(['Esc']),
        ],
      ),
    );
  }
}

/// 激活态搜索胶囊（静态展示：有输入文字 + Esc）
class _SearchPillActive extends StatelessWidget {
  const _SearchPillActive({
    required this.width,
    required this.text,
    required this.trailing,
  });

  final double width;
  final String text;
  final List<String> trailing;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: width,
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: PinSpace.s3),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.full),
        border: Border.all(color: spec.primary),
        boxShadow: [
          BoxShadow(blurRadius: 0, spreadRadius: 3, color: spec.primaryTint),
        ],
      ),
      child: Row(
        children: [
          PinIcon(PinIcons.search, size: 13, color: spec.text),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: PinFontSize.xs,
              fontWeight: FontWeight.w600,
              color: spec.text,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
          const SizedBox(width: 2),
          Container(width: 1.5, height: 13, color: spec.primary),
          const Spacer(),
          PinKbd(trailing),
        ],
      ),
    );
  }
}

/// 应用窗口骨架：标题栏 + 主体
class PinAppWindow extends StatelessWidget {
  const PinAppWindow({required this.body, this.titleBar, super.key});

  final Widget body;
  final Widget? titleBar;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return ColoredBox(
      color: spec.surface,
      child: Column(
        children: [
          titleBar ?? const PinTitleBar(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// 画布页背景（对应 .canvas-page：#E9EDF2 + 22px 点阵，画板居中排布）
class CanvasPage extends StatelessWidget {
  const CanvasPage({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(color: Color(0xFFE9EDF2)),
      child: CustomPaint(
        painter: const _DotGridPainter(
          dot: Color(0xFFDBE1EA),
          spacing: 22,
          radius: 1.2,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40),
          child: Center(
            child: Wrap(
              spacing: 40,
              runSpacing: 40,
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({
    required this.dot,
    required this.spacing,
    required this.radius,
  });

  final Color dot;
  final double spacing;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = dot;
    for (double x = spacing / 2; x < size.width; x += spacing) {
      for (double y = spacing / 2; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) =>
      oldDelegate.dot != dot || oldDelegate.spacing != spacing;
}

/// 画板（.artboard：白卡 + 远阴影，承载画布页上的卡片）
class Artboard extends StatelessWidget {
  const Artboard({
    required this.child,
    this.width,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final Widget child;
  final double? width;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.lg),
        border: Border.all(color: spec.line),
        boxShadow: spec.shadowFar,
      ),
      child: child,
    );
  }
}
