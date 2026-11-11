/// 贴记 PinNote · 应用入口组件
library;

import 'package:flutter/material.dart';

import '../design/theme.dart';
import '../screens/account_screen.dart';
import '../screens/desktop_pins_screen.dart';
import '../screens/design_language_screen.dart';
import '../screens/empty_states_screen.dart';
import '../screens/home_screen.dart';
import '../screens/note_editor_screen.dart';
import '../screens/notes_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/pin_controls_screen.dart';
import '../screens/quick_capture_screen.dart';
import '../screens/search_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/task_edit_screen.dart';
import '../screens/tray_screen.dart';
import 'app_scope.dart';

/// MaterialApp + 全局主题（浅 / 深色由 [AppController] 切换）
class PinNoteApp extends StatefulWidget {
  const PinNoteApp({super.key});

  @override
  State<PinNoteApp> createState() => _PinNoteAppState();
}

class _PinNoteAppState extends State<PinNoteApp> {
  final AppController _controller = AppController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onModeChanged);
  }

  void _onModeChanged() => setState(() {});

  @override
  void dispose() {
    _controller.removeListener(_onModeChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      notifier: _controller,
      child: MaterialApp(
        title: '贴记 PinNote',
        debugShowCheckedModeBanner: false,
        theme: buildPinTheme(pinSpecLight),
        darkTheme: buildPinTheme(pinSpecDark),
        themeMode: _controller.mode,
        // 页面为 CSS 1:1 还原，未使用 Scaffold/Material 包裹文本，
        // 导致所有 Text 继承 DefaultTextStyle.fallback（红色 + 黄色下划线）。
        // 在根节点安装默认文本样式，颜色由各 Text 显式指定不受影响。
        builder: (context, child) => DefaultTextStyle(
          style: Theme.of(context).textTheme.bodyMedium ?? const TextStyle(),
          child: child!,
        ),
        home: const HomeScreen(),
        routes: {
          '/home': (_) => const HomeScreen(),
          '/notes': (_) => const NotesScreen(),
          '/note-editor': (_) => const NoteEditorScreen(),
          '/desktop-pins': (_) => const DesktopPinsScreen(),
          '/pin-controls': (_) => const PinControlsScreen(),
          '/quick-capture': (_) => const QuickCaptureScreen(),
          '/search': (_) => const SearchScreen(),
          '/task-edit': (_) => const TaskEditScreen(),
          '/settings': (_) => const SettingsScreen(),
          '/tray': (_) => const TrayScreen(),
          '/empty-states': (_) => const EmptyStatesScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/account': (_) => const AccountScreen(),
          '/design-language': (_) => const DesignLanguageScreen(),
        },
      ),
    );
  }
}
