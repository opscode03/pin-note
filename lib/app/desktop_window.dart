/// 贴记 PinNote · 桌面窗口控制（无边框窗口 + 自绘标题栏）
///
/// 设计稿的 .titlebar 是应用自绘的（右上 146×32 预留给窗口按钮），
/// 因此用 window_manager 隐藏系统标题栏，并自绘 Windows 风格窗口按钮。
/// 所有调用均做防御：测试环境或初始化失败时静默降级。
library;

import 'dart:ui' show Size;

import 'package:flutter/foundation.dart';
import 'package:window_manager/window_manager.dart';

import '../design/tokens.dart';
import 'app_scope.dart';

class DesktopWindow {
  DesktopWindow._();

  static bool _ready = false;

  /// 在 main() 中调用：隐藏系统标题栏、设置窗口尺寸
  static Future<void> ensureInitialized() async {
    if (!isRealDesktop || kIsWeb) return;
    try {
      await windowManager.ensureInitialized();
      await windowManager.waitUntilReadyToShow(
        const WindowOptions(
          size: Size(PinSize.windowDefaultWidth, PinSize.windowDefaultHeight),
          minimumSize: Size(PinSize.windowMinWidth, PinSize.windowMinHeight),
          center: true,
          title: '贴记 PinNote',
          titleBarStyle: TitleBarStyle.hidden,
        ),
        () async {
          await windowManager.show();
          await windowManager.focus();
        },
      );
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  static void minimize() => _run(windowManager.minimize);
  static void toggleMaximize() => _run(() async {
    if (await windowManager.isMaximized()) {
      await windowManager.unmaximize();
    } else {
      await windowManager.maximize();
    }
  });
  static void close() => _run(windowManager.close);
  static void startDragging() => _run(windowManager.startDragging);

  static Future<void> _run(Future<void> Function() action) async {
    if (!_ready) return;
    try {
      await action();
    } catch (_) {
      // 插件不可用时忽略（测试 / 预览环境）
    }
  }
}
