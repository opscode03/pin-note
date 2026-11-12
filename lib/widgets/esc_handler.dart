/// 贴记 PinNote · Esc 关闭支持
///
/// 包裹浮层内容：autofocus + 捕获 Esc 键 → [onEsc]。
/// 用于 showGeneralDialog 内容（点蒙层之外的第二关闭途径）。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Esc 键关闭区域
class EscHandler extends StatelessWidget {
  const EscHandler({required this.child, required this.onEsc, super.key});

  final Widget child;
  final VoidCallback onEsc;

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          onEsc();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: child,
    );
  }
}
