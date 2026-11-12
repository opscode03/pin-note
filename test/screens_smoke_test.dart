/// 每屏冒烟测试：以浅色 / 深色主题分别挂载，验证不抛异常、无布局溢出。
///
/// 窗口控制在测试环境下被 DesktopWindow / isRealDesktop 防御性跳过。
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_note/app/app.dart';
import 'package:pin_note/app/app_scope.dart';
import 'package:pin_note/data/task_repository.dart';
import 'package:pin_note/design/icons.dart';
import 'package:pin_note/design/tokens.dart';
import 'package:pin_note/design/theme.dart';
import 'package:pin_note/screens/account_screen.dart';
import 'package:pin_note/screens/design_language_screen.dart';
import 'package:pin_note/screens/desktop_pins_screen.dart';
import 'package:pin_note/screens/empty_states_screen.dart';
import 'package:pin_note/screens/home_screen.dart';
import 'package:pin_note/screens/note_editor_screen.dart';
import 'package:pin_note/screens/notes_screen.dart';
import 'package:pin_note/screens/onboarding_screen.dart';
import 'package:pin_note/screens/pin_controls_screen.dart';
import 'package:pin_note/screens/quick_capture_screen.dart';
import 'package:pin_note/screens/search_screen.dart';
import 'package:pin_note/screens/settings_screen.dart';
import 'package:pin_note/screens/task_edit_screen.dart';
import 'package:pin_note/screens/tray_screen.dart';
import 'package:pin_note/widgets/buttons.dart';
import 'package:pin_note/widgets/chips.dart';
import 'package:pin_note/widgets/controls.dart';
import 'package:pin_note/widgets/sticky_note.dart';

Widget _wrap(Widget child, {Brightness brightness = Brightness.light}) {
  return MaterialApp(
    theme: buildPinTheme(
      brightness == Brightness.light ? pinSpecLight : pinSpecDark,
    ),
    home: TaskScope(
      notifier: TaskRepository(),
      child: Scaffold(body: child),
    ),
  );
}

void main() {
  group('设计系统组件', () {
    testWidgets('按钮 / Chip / kbd 渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              PinButton('新建任务', icon: PinIcons.plus),
              PinChip('今天 14:00', icon: PinIcons.clock),
              PinKbd(['Ctrl', 'K']),
              PinFlag('高', color: Color(0xFFB32E2E)),
            ],
          ),
        ),
      );
      expect(find.text('新建任务'), findsOneWidget);
      expect(find.text('Ctrl'), findsOneWidget);
    });

    testWidgets('便签 8 色渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(
          Column(
            children: [
              for (final color in StickyColor.values)
                PinSticky(color: color, child: const StickyTitle('测试')),
            ],
          ),
        ),
      );
      expect(find.text('测试'), findsNWidgets(StickyColor.values.length));
    });

    testWidgets('控件渲染', (tester) async {
      await tester.pumpWidget(
        _wrap(
          const Column(
            children: [
              PinCheckbox(done: true),
              PinRadio(on: true),
              PinSwitch(on: true),
              PinProgressBar(value: 0.5),
              PinRing(value: 0.375),
              PinSeg(items: ['小', '中', '大'], onIndex: 1),
            ],
          ),
        ),
      );
      expect(find.byType(PinSeg), findsOneWidget);
    });

    test('全部图标可构建 Path（无解析异常）', () {
      // 触发懒加载：遍历引用即可；解析错误会在 paint 时抛出，这里仅保证常量定义完整
      expect(PinIcons.plus.name, 'plus');
      expect(PinIcons.sync.name, 'sync');
    });

    testWidgets('全部图标真实绘制（paint 阶段解析 path）', (tester) async {
      final allIcons = <PinIconData>[
        PinIcons.plus,
        PinIcons.minus,
        PinIcons.close,
        PinIcons.check,
        PinIcons.chevronDown,
        PinIcons.chevronUp,
        PinIcons.chevronRight,
        PinIcons.chevronLeft,
        PinIcons.search,
        PinIcons.calendar,
        PinIcons.clock,
        PinIcons.bell,
        PinIcons.flag,
        PinIcons.tag,
        PinIcons.pin,
        PinIcons.tack,
        PinIcons.layers,
        PinIcons.note,
        PinIcons.gear,
        PinIcons.theme,
        PinIcons.sync,
        PinIcons.trash,
        PinIcons.more,
        PinIcons.palette,
        PinIcons.opacity,
        PinIcons.image,
        PinIcons.enter,
        PinIcons.start,
        PinIcons.wifi,
        PinIcons.volume,
        PinIcons.battery,
        PinIcons.gridView,
        PinIcons.listView,
        PinIcons.highlight,
        PinIcons.listCheck,
        PinIcons.listBullet,
        PinIcons.lock,
        PinIcons.zap,
        PinIcons.folder,
        PinIcons.person,
        PinIcons.keyboard,
        PinIcons.info,
        PinIcons.drag,
      ];
      await tester.pumpWidget(
        _wrap(
          Wrap(
            children: [for (final icon in allIcons) PinIcon(icon, size: 24)],
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(PinIcon), findsNWidgets(allIcons.length));
    });
  });

  group('页面冒烟', () {
    testWidgets('应用可挂载（浅色）', (tester) async {
      await tester.pumpWidget(const PinNoteApp());
      await tester.pump();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('主窗口屏：今日 / 便签库 / 任务编辑 / 设置 / 搜索 / 便签编辑（浅色）', (tester) async {
      for (final screen in const [
        HomeScreen(),
        NotesScreen(),
        TaskEditScreen(),
        SettingsScreen(),
        SearchScreen(),
        NoteEditorScreen(),
      ]) {
        await tester.pumpWidget(_wrap(screen));
        await tester.pump();
        // 不捕获渲染异常：框架测试结束时输出完整 creator 链，便于定位
      }
    });

    testWidgets('画布页：引导 / 账户 / 空状态（浅色）', (tester) async {
      for (final screen in const [
        OnboardingScreen(),
        AccountScreen(),
        EmptyStatesScreen(),
      ]) {
        await tester.pumpWidget(_wrap(screen));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('设计语言规范页（浅色 / 深色）', (tester) async {
      await tester.pumpWidget(_wrap(const DesignLanguageScreen()));
      await tester.pump();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(
        _wrap(const DesignLanguageScreen(), brightness: Brightness.dark),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('桌面贴总览（1440×900）', (tester) async {
      await _desktop(tester, const DesktopPinsScreen());
    });

    testWidgets('桌面贴控制（1440×900）', (tester) async {
      await _desktop(tester, const PinControlsScreen());
    });

    testWidgets('快速捕获（1440×900）', (tester) async {
      await _desktop(tester, const QuickCaptureScreen());
    });

    testWidgets('托盘与通知（1440×900）', (tester) async {
      await _desktop(tester, const TrayScreen());
    });

    test('任务仓库：勾选跨组移动 + 快速添加 + 撤销回原组', () {
      final repo = TaskRepository();
      final today0 = repo.today.length;
      final done0 = repo.done.length;
      final task = repo.today.first;
      repo.toggleDone(task.id!);
      expect(repo.today.length, today0 - 1);
      expect(repo.done.length, done0 + 1);
      repo.toggleDone(task.id!); // 撤销 → 回原分组
      expect(repo.today.length, today0);
      expect(repo.done.length, done0);
      repo.addQuickTask('测试任务');
      expect(repo.today.any((t) => t.title == '测试任务'), isTrue);
    });

    test('主题规格浅深色齐全', () {
      expect(pinSpecLight.bg, isNot(pinSpecDark.bg));
      expect(pinSpecLight.text, isNot(pinSpecDark.text));
    });
  });
}

/// 以 1440×900 桌面视口挂载场景屏
Future<void> _desktop(WidgetTester tester, Widget screen) async {
  tester.view.physicalSize = const Size(1440, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(_wrap(screen));
  await tester.pump();
  // 溢出等渲染异常不在此捕获：让框架在测试结束时输出完整 creator 链
}
