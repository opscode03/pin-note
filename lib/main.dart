/// 贴记 PinNote · main
///
/// 桌面端启动流程：初始化无边框窗口（自绘标题栏）→ 挂载应用。
/// 深色模式由标题栏的主题按钮切换（对应设计稿 dark.html）。
library;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'app/app.dart';
import 'app/desktop_window.dart';
import 'data/note_repository.dart';
import 'data/preferences.dart';
import 'data/task_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // web 端启用 path 路由（/notes 直达对应屏；默认 hash 策略下 /notes 会回落首页）
  if (kIsWeb) {
    usePathUrlStrategy();
  }
  debugPrint('[启动] 1 path/url 策略完成');
  // 偏好与数据持久化（web 端走 localStorage，桌面端走 plist/注册表）
  await PreferencesService.init();
  debugPrint('[启动] 2 偏好初始化完成');
  final taskRepo = TaskRepository();
  final noteRepo = NoteRepository();
  await taskRepo.load();
  debugPrint('[启动] 3 任务加载完成 (${taskRepo.tasks.length} 条)');
  await noteRepo.load();
  debugPrint('[启动] 4 便签加载完成 (${noteRepo.notes.length} 条)');
  await DesktopWindow.ensureInitialized();
  debugPrint('[启动] 5 窗口初始化完成');
  runApp(PinNoteApp(taskRepo: taskRepo, noteRepo: noteRepo));
  debugPrint('[启动] 6 runApp 完成');
}
