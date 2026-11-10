/// 贴记 PinNote · main
///
/// 桌面端启动流程：初始化无边框窗口（自绘标题栏）→ 挂载应用。
/// 深色模式由标题栏的主题按钮切换（对应设计稿 dark.html）。
library;

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/desktop_window.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DesktopWindow.ensureInitialized();
  runApp(const PinNoteApp());
}
