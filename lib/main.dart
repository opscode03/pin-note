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
  await PreferencesService.init();
  final taskRepo = TaskRepository();
  final noteRepo = NoteRepository();
  // 桌面端从偏好恢复数据（web 端跳过，保持演示态）
  if (!kIsWeb) {
    await taskRepo.load();
    await noteRepo.load();
  }
  await DesktopWindow.ensureInitialized();
  runApp(PinNoteApp(taskRepo: taskRepo, noteRepo: noteRepo));
}
