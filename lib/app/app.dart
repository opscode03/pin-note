/// 贴记 PinNote · 应用入口组件
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/note_repository.dart';
import '../data/task_repository.dart';
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
import 'dialogs.dart';
import 'navigation.dart';

/// MaterialApp + 全局主题（浅 / 深色由 [AppController] 切换）
class PinNoteApp extends StatefulWidget {
  const PinNoteApp({super.key, required this.taskRepo, required this.noteRepo});

  final TaskRepository taskRepo;
  final NoteRepository noteRepo;

  @override
  State<PinNoteApp> createState() => _PinNoteAppState();
}

class _PinNoteAppState extends State<PinNoteApp> {
  late final AppController _controller = AppController();
  late final TaskRepository _taskRepo = widget.taskRepo;
  late final NoteRepository _noteRepo = widget.noteRepo;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  void _go(String route) {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    Navigator.pushReplacementNamed(ctx, route);
  }

  void _openSearch() => _go('/search');

  void _quickCapture() {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    showQuickCaptureDialog<void>(ctx);
  }

  void _newTask() {
    final ctx = _navigatorKey.currentContext;
    if (ctx == null) return;
    showTaskEditDialog<void>(ctx);
  }

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
      child: TaskScope(
        notifier: _taskRepo,
        child: NoteScope(
          notifier: _noteRepo,
          child: CallbackShortcuts(
            bindings: {
              const SingleActivator(LogicalKeyboardKey.keyK, control: true):
                  _openSearch,
              const SingleActivator(LogicalKeyboardKey.keyK, meta: true):
                  _openSearch,
              const SingleActivator(
                LogicalKeyboardKey.space,
                control: true,
                shift: true,
              ):
                  _quickCapture,
              const SingleActivator(
                LogicalKeyboardKey.keyT,
                control: true,
                shift: true,
              ):
                  _newTask,
              const SingleActivator(
                LogicalKeyboardKey.keyN,
                control: true,
                alt: true,
              ):
                  () => _go('/notes'),
              const SingleActivator(
                LogicalKeyboardKey.keyD,
                control: true,
                alt: true,
              ):
                  () => _go('/desktop-pins'),
            },
            child: MaterialApp(
              title: '贴记 PinNote',
              debugShowCheckedModeBanner: false,
              navigatorKey: _navigatorKey,
              navigatorObservers: [AppNav.observer],
              theme: buildPinTheme(pinSpecLight),
              darkTheme: buildPinTheme(pinSpecDark),
              themeMode: _controller.mode,
              // 页面为 CSS 1:1 还原，未使用 Scaffold/Material 包裹文本：
              // 在根节点安装默认文本样式，避免 fallback 红字下划线
              builder: (context, child) => DefaultTextStyle(
                style: Theme.of(context).textTheme.bodyMedium ??
                    const TextStyle(),
                child: child ?? const SizedBox.shrink(),
              ),
              home: _controller.onboardingSeen
                  ? const HomeScreen()
                  : const OnboardingScreen(),
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
          ),
        ),
      ),
    );
  }
}
