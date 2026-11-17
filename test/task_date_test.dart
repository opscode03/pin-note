/// 任务日期关联测试：真实 dueAt、快捷日期、真正新建与持久化
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pin_note/app/app_scope.dart';
import 'package:pin_note/data/capture_parser.dart';
import 'package:pin_note/data/demo.dart';
import 'package:pin_note/data/task_repository.dart';
import 'package:pin_note/design/theme.dart';
import 'package:pin_note/widgets/overlays/task_edit_popover.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('快速捕获真实日期', () {
    final base = DateTime(2026, 11, 17, 10, 20);

    test('明天 + 时刻 + 标签 + 高优先级', () {
      final p = parseCapture('明天9点 提交季度报告 #工作 !!', now: base);
      expect(p.title, '提交季度报告');
      expect(p.priority, PinPriority.high);
      expect(p.tags, ['#工作']);
      expect(p.dueAt, DateTime(2026, 11, 18, 9));
      final task = captureToTask(p);
      expect(task.dueAt, p.dueAt);
      expect(task.meta.first.label, '明天 09:00');
    });

    test('下周一只带日期 / 下午时刻', () {
      final monday = parseCapture('下周一 复盘', now: base);
      expect(monday.dueAt, DateTime(2026, 11, 23, 9));
      final afternoon = parseCapture('明天下午3点半 打电话', now: base);
      expect(afternoon.dueAt, DateTime(2026, 11, 18, 15, 30));
    });

    test('只带时刻默认今天', () {
      final p = parseCapture('18:30 买猫粮', now: base);
      expect(p.dueAt, DateTime(2026, 11, 17, 18, 30));
    });
  });

  test('dueAt JSON 往返与仓库读回', () async {
    final repo = TaskRepository();
    final due = DateTime(2026, 12, 1, 16, 30);
    final created = repo.createTask(title: '持久化日期', dueAt: due);
    await repo.save();
    final fresh = TaskRepository();
    await fresh.load();
    final restored = fresh.tasks.firstWhere((t) => t.id == created.id);
    expect(restored.dueAt, due);
    expect(restored.meta.first.label, contains('12月1日 16:30'));
  });

  testWidgets('编辑器快捷日期保存到已有任务', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = TaskRepository();
    await tester.pumpWidget(_wrap(
      repo,
      const TaskEditPopover(
        task: DemoTask(id: '设计评审材料准备', title: '日期测试'),
        width: 408,
      ),
    ));
    expect(find.byType(TableCalendar<void>), findsOneWidget);
    await tester.tap(find.text('明天'));
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    final edited = repo.byId('设计评审材料准备');
    final expected = DateTime.now().add(const Duration(days: 1));
    expect(edited.dueAt, DateTime(expected.year, expected.month, expected.day, 9));
  });

  testWidgets('createNew 真正创建并带日期', (tester) async {
    tester.view.physicalSize = const Size(1200, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    final repo = TaskRepository();
    await tester.pumpWidget(_wrap(
      repo,
      const TaskEditPopover(
        task: DemoTask(title: '新任务'),
        width: 408,
        createNew: true,
      ),
    ));
    await tester.enterText(find.byType(TextField), '新任务带日期');
    await tester.tap(find.text('后天'));
    await tester.tap(find.text('确定'));
    await tester.pumpAndSettle();
    final created = repo.tasks.first;
    final expected = DateTime.now().add(const Duration(days: 2));
    expect(created.title, '新任务带日期');
    expect(created.dueAt, DateTime(expected.year, expected.month, expected.day, 9));
  });
}

Widget _wrap(TaskRepository repo, Widget child) {
  return MaterialApp(
    theme: buildPinTheme(pinSpecLight),
    home: TaskScope(
      notifier: repo,
      child: Scaffold(body: Center(child: child)),
    ),
  );
}
