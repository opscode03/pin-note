/// 贴记 PinNote · 应用级状态（主题切换）
library;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../data/note_repository.dart';
import '../data/preferences.dart';
import '../data/task_repository.dart';

/// 全局应用控制器：浅 / 深色切换（对应设计稿 titlebar 的主题按钮）
class AppController extends ChangeNotifier {
  AppController()
      : _mode = PreferencesService.themeMode,
        onboardingSeen = PreferencesService.onboardingSeen;

  ThemeMode _mode;

  // 首启引导标记（持久化）
  bool onboardingSeen;

  void markOnboardingSeen() {
    if (onboardingSeen) return;
    onboardingSeen = true;
    PreferencesService.setOnboardingSeen();
    notifyListeners();
  }

  ThemeMode get mode => _mode;

  bool get isDark => _mode == ThemeMode.dark;

  void toggle() => setMode(isDark ? ThemeMode.light : ThemeMode.dark);

  void setMode(ThemeMode mode) {
    if (mode == _mode) return;
    _mode = mode;
    PreferencesService.setThemeMode(mode);
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

/// 便签状态作用域：`NoteScope.of(context)` 读写便签仓库
class NoteScope extends InheritedNotifier<NoteRepository> {
  const NoteScope({
    required NoteRepository super.notifier,
    required super.child,
    super.key,
  });

  static NoteRepository of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<NoteScope>();
    assert(scope != null && scope.notifier != null, 'NoteScope 未挂载');
    return scope!.notifier!;
  }
}

/// 判断是否运行在真实桌面环境（测试 / Web 下禁用窗口控制）
bool get isRealDesktop =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux);
