/// 贴记 PinNote · 操作反馈 Toast（对应 ui/empty-states.html D 卡与 tray.html）
///
/// `showPinToast(...)` 通过 Overlay 展示，5 秒自动消失，支持「撤销」动作。
/// 视觉复用 [PinToast]（lib/widgets/menu.dart）。
library;

import 'dart:async';

import 'package:flutter/material.dart';

import '../design/icons.dart';
import 'menu.dart';

/// 展示一条操作反馈 Toast；返回用于提前关闭的控制器
ToastHandle showPinToast(
  BuildContext context, {
  required String title,
  String? subtitle,
  PinIconData icon = PinIcons.check,
  Color? iconBg,
  Color? iconColor,
  String? actionLabel,
  VoidCallback? onAction,
  Duration duration = const Duration(seconds: 5),
}) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) {
    onAction?.call();
    return ToastHandle._();
  }
  final handle = ToastHandle._();
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ToastEntry(
      handle: handle,
      onRemove: () {
        if (entry.mounted) entry.remove();
      },
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconBg: iconBg,
      iconColor: iconColor,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
    ),
  );
  overlay.insert(entry);
  return handle;
}

/// Toast 控制器：可提前关闭
class ToastHandle {
  ToastHandle._();

  VoidCallback? _dismiss;
  void dismiss() => _dismiss?.call();
}

class _ToastEntry extends StatefulWidget {
  const _ToastEntry({
    required this.handle,
    required this.onRemove,
    required this.title,
    required this.duration,
    this.subtitle,
    this.icon,
    this.iconBg,
    this.iconColor,
    this.actionLabel,
    this.onAction,
  });

  final ToastHandle handle;
  final VoidCallback onRemove;
  final String title;
  final String? subtitle;
  final PinIconData? icon;
  final Color? iconBg;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Duration duration;

  @override
  State<_ToastEntry> createState() => _ToastEntryState();
}

class _ToastEntryState extends State<_ToastEntry> {
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.handle._dismiss = _close;
    _timer = Timer(widget.duration, _close);
  }

  bool _closing = false;

  void _close() {
    if (_closing) return;
    _closing = true;
    _timer.cancel();
    widget.onRemove();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 32,
      child: Align(
        alignment: Alignment.topCenter,
        child: Material(
          color: Colors.transparent,
          child: PinToast(
            title: widget.title,
            subtitle: widget.subtitle,
            icon: widget.icon ?? PinIcons.check,
            iconBg: widget.iconBg,
            iconColor: widget.iconColor,
            action: widget.actionLabel,
            onAction: () {
              widget.onAction?.call();
              _close(); // 点动作后立即收起
            },
            minWidth: 360,
          ),
        ),
      ),
    );
  }
}
