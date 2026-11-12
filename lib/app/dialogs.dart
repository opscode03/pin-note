/// 贴记 PinNote · 应用内浮层（showGeneralDialog 封装）
///
/// 约定（docs/CODE_STANDARDS.md §3）：
/// - 浮层 = showGeneralDialog：点蒙层可关、Esc 可关（EscHandler）、确定/取消 = pop；
/// - 浮层下的页面保持原样，栈深不增长。
library;

import 'package:flutter/material.dart';

import '../data/demo.dart';
import '../design/tokens.dart';
import '../app/app_scope.dart';
import '../widgets/esc_handler.dart';
import '../widgets/overlays/quick_capture_card.dart';
import '../widgets/toast.dart';
import '../widgets/overlays/task_edit_popover.dart';
import '../design/icons.dart';
import '../design/theme.dart';

/// 通用浮层容器：居中卡片 + 淡入缩放 + 蒙层点击关闭 + Esc 关闭
Future<T?> showPinDialog<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? barrierColor,
  bool barrierDismissible = true,
}) {
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierLabel: '关闭浮层',
    barrierColor: barrierColor ?? const Color(0x240F172A), // rgba(15,23,42,.14)
    transitionDuration: PinMotion.dur,
    pageBuilder: (ctx, a, b) => builder(ctx),
    transitionBuilder: (ctx, anim, a2, child) => FadeTransition(
      opacity: anim,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.96, end: 1).animate(anim),
        child: child,
      ),
    ),
  );
}

/// 任务编辑浮层（对应 task-edit.html 的 .edit-pop）
///
/// [task] 缺省时依次取：当前选中 → 今天第一条 → 逾期第一条；无可编辑任务则不打开。
Future<T?> showTaskEditDialog<T>(BuildContext context, {DemoTask? task}) {
  final repo = TaskScope.of(context);
  final target = task ?? repo.resolveEditable();
  if (target == null) {
    showPinToast(
      context,
      title: '没有可编辑的任务',
      subtitle: '先添加一条待办吧',
      icon: PinIcons.info,
      iconBg: context.pin.primaryTint,
      iconColor: context.pin.primaryStrong,
    );
    return Future<T?>.value();
  }
  repo.select(target.id ?? target.title);
  return showPinDialog<T>(
    context: context,
    builder: (ctx) => EscHandler(
      onEsc: () => Navigator.pop(ctx),
      child: Center(
        child: TaskEditPopover(
          task: target,
          width: MediaQuery.sizeOf(ctx).width * 0.9 < 408
              ? MediaQuery.sizeOf(ctx).width * 0.9
              : 408,
        ),
      ),
    ),
  );
}

/// 快速捕获浮层（对应 quick-capture.html；蒙层用场景同款暗色）
Future<T?> showQuickCaptureDialog<T>(BuildContext context) {
  return showPinDialog<T>(
    context: context,
    barrierColor: const Color(0x6B080C16), // rgba(8,12,22,.42)
    builder: (ctx) => EscHandler(
      onEsc: () => Navigator.pop(ctx),
      child: Center(
        child: QuickCaptureCard(
          width: MediaQuery.sizeOf(ctx).width * 0.86 < 620
              ? MediaQuery.sizeOf(ctx).width * 0.86
              : 620,
        ),
      ),
    ),
  );
}
