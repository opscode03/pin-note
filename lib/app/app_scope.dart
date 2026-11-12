/// 贴记 PinNote · 应用级状态（主题切换）
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../data/task_repository.dart';

/// 全局应用控制器：浅 / 深色切换（对应设计稿 titlebar 的主题按钮）
class AppController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;

  // 首启引导标记（会话级；持久化在 P2 用 shared_preferences）
  bool onboardingSeen = false;

  void markOnboardingSeen() {
    if (onboardingSeen) return;
    onboardingSeen = true;
    notifyListeners();
  }

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void toggle() {
    _mode = isDark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    notifyListeners();
  }
}

/// 通过 `AppScope.of(context)` 访问
class AppScope extends InheritedNotifier<AppController> {
  const AppScope({
    required AppController super.notifier,
    required super.child,
    super.key,
  });

  static AppController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null && scope.notifier != null, 'AppScope 未挂载');
    return scope!.notifier!;
  }
}

/// 任务状态作用域：`TaskScope.of(context)` 读写任务仓库
class TaskScope extends InheritedNotifier<TaskRepository> {
  const TaskScope({
    required TaskRepository super.notifier,
    required super.child,
    super.key,
  });

  static TaskRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<TaskScope>();
    assert(scope != null && scope.notifier != null, 'TaskScope 未挂载');
    return scope!.notifier!;
  }
}

/// 判断是否运行在真实桌面环境（测试 / Web 下禁用窗口控制）
bool get isRealDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);
