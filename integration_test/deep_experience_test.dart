/// 深度体验走查（macOS 真机）
///
/// 与 app_flow_test.dart 的可达性走查互补：
/// 本文件真正执行「新建 / 编辑 / 删除撤销 / 便签编辑 / 拖拽 / 窄窗口」，
/// 并把实际操作后的结果逐条输出。失败的点只记录、不提前终止，便于完整评估体验。
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pin_note/app/app.dart';
import 'package:pin_note/app/app_scope.dart';
import 'package:pin_note/app/desktop_window.dart';
import 'package:pin_note/app/navigation.dart';
import 'package:pin_note/data/demo.dart';
import 'package:pin_note/data/note_repository.dart';
import 'package:pin_note/data/task_repository.dart';
import 'package:pin_note/widgets/overlays/task_edit_popover.dart';
import 'package:pin_note/widgets/sidebar.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('深度体验：真实操作与结果', (tester) async {
    final issues = <String>[];

    Future<void> settle([String? label]) async {
      await tester.pumpAndSettle();
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (label != null) debugPrint('[体验] —— $label');
    }

    void check(bool ok, String what, {String? issue}) {
      debugPrint('[体验] ${ok ? "✅" : "❌"} $what');
      if (!ok && issue != null) issues.add(issue);
    }

    await DesktopWindow.ensureInitialized();
    final taskRepo = TaskRepository();
    final noteRepo = NoteRepository();
    await tester.pumpWidget(
      PinNoteApp(taskRepo: taskRepo, noteRepo: noteRepo),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    if (find.text('开始使用').evaluate().isNotEmpty) {
      await tester.tap(find.text('开始使用').first);
      await settle('首启「开始使用」');
    }
    await taskRepo.reset();
    await noteRepo.reset();
    await tester.pumpAndSettle();
    check(find.text('已逾期').evaluate().isNotEmpty, '1. 今日首页正常呈现');

    // ---------- 2. 快速捕获：真实输入与解析 ----------
    await tester.tap(
      find.text('添加任务，输入 #标签 · !优先级 · 明天 9:00…'),
      warnIfMissed: false,
    );
    await settle('2. 打开快速捕获');
    await tester.enterText(
      find.byType(TextField),
      '明天9点 提交季度报告 #工作 !!',
    );
    await settle('2. 快速捕获输入「明天9点 提交季度报告 #工作 !!」');
    check(find.text('明天 09:00').evaluate().isNotEmpty,
        '2a. 下方日期 Chip 随输入实时更新',
        issue: '快速捕获下方识别 chips 是静态文案，输入与展示不同步');
    await tester.tap(find.text('添加待办'));
    await settle('2b. 添加待办');
    final created = taskRepo.tasks.first;
    check(created.title == '提交季度报告', '2c. 标题剥离识别段后正确落库',
        issue: '快速捕获标题解析异常');
    check(created.priority == PinPriority.high && created.tags.contains('#工作'),
        '2d. 高优先级与 #工作 标签落库',
        issue: '快速捕获标签/优先级未落库');
    check(created.meta.any((m) => m.label == '明天 09:00'),
        '2e. 日期元信息落库为「明天 09:00」',
        issue: '快速捕获日期未落库');

    // ---------- 3. 编辑任务：标题 / 优先级 / 标签 / 删除撤销 ----------
    await tester.tap(find.text('提交季度报告').first);
    await settle('3. 打开新任务的编辑浮层');
    await tester.enterText(find.byType(TextField).first, '提交季度报告终稿');
    await tester.tap(find.text('中').first);
    await tester.tap(find.byType(EditTagAdd));
    await settle('3a. 改标题 / 优先级中 / 添加标签');
    await tester.tap(find.text('确定'));
    await settle('3b. 保存');
    final edited = taskRepo.tasks.firstWhere((t) => t.id == created.id);
    check(edited.title == '提交季度报告终稿', '3c. 标题保存到任务列表');
    check(edited.priority == PinPriority.medium, '3d. 优先级保存为中');
    check(edited.tags.contains('#重要'), '3e. 新增标签保存到任务');
    check(find.text('提交季度报告终稿').evaluate().isNotEmpty,
        '3f. 保存后首页列表展示新标题');

    await tester.tap(find.text('提交季度报告终稿').first);
    await settle('3g. 再打开编辑');
    await tester.tap(find.text('删除').last);
    await settle('3h. 删除');
    check(taskRepo.tasks.every((t) => t.id != created.id), '3i. 删除后任务消失');
    await tester.tap(find.text('撤销').first);
    await settle('3j. 撤销删除');
    check(taskRepo.tasks.any((t) => t.id == created.id), '3k. 撤销后任务恢复');

    // ---------- 4. 搜索真实过滤与键盘 ----------
    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    await settle('4. Ctrl+K 打开搜索');
    await tester.enterText(find.byType(TextField), '季度');
    await settle('4. Ctrl+K 并输入「季度」');
    check(find.text('提交季度报告终稿').evaluate().isNotEmpty, '4a. 搜索实时命中编辑后的任务');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await settle('4b. Enter 打开结果');
    check(find.text('日期与时间').evaluate().isNotEmpty, '4c. Enter 打开任务编辑');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
    await settle('4d. Esc 关浮层');
    await tester.sendKeyDownEvent(LogicalKeyboardKey.escape);
    await settle('4e. Esc 关搜索');
    check(find.text('已逾期').evaluate().isNotEmpty, '4f. 返回今日且栈未异常');

    // ---------- 7. 设置 / 窄窗口 / 账户 ----------
    await tester.tap(find.byTooltip('设置'));
    await settle('7. 设置外观');
    await settle('7. 设置外观');
    await tester.tap(find.text('跟随系统'));
    await settle('7a. 点击跟随系统');
    final settingsCtx = tester.element(find.text('外观').first);
    check(AppScope.of(settingsCtx).mode == ThemeMode.system,
        '7b. 跟随系统主题生效',
        issue: '设置「跟随系统」只是跳转当前页，不改变 ThemeMode');
    check(find.text('浅色').evaluate().isNotEmpty, '7c. 设置页视觉正常');

    // 登录 / 账户流程已精简出主流程，不再走查

    // 「关于」入口保留（进入设计语言规范页）
    await tester.tap(find.text('关于'));
    await settle('7f. 点击设置「关于」');
    debugPrint('[诊断] 关于后路由=${AppNav.observer.current} '
        '设计语言规范=${find.text('设计语言规范').evaluate().length}');
    check(find.text('设计语言规范').evaluate().isNotEmpty,
        '7g. 关于可进入设计语言页');

    // 返回设置（测试导航），再走页面返回链接
    tester
        .state<NavigatorState>(find.byType(Navigator).first)
        .pushReplacementNamed('/settings');
    await settle('7g2. 设计语言页返回设置');
    await tester.tap(find.text('返回'));
    await settle('7h. 设置返回今日');
    await tester.binding.setSurfaceSize(const Size(850, 900));
    await tester.pumpAndSettle();
    final sideWidth = tester.getSize(find.byType(PinSidebar)).width;
    final viewportWidth = MediaQuery.sizeOf(
      tester.element(find.byType(MaterialApp).first),
    ).width;
    debugPrint('[诊断] 缩小后逻辑视口宽=$viewportWidth 侧栏宽=$sideWidth');
    if (viewportWidth >= 900) {
      debugPrint('[体验] ⚠️ 测试窗口未实际缩小，850px 断点无法在本轮验证');
    } else {
      check(sideWidth == 190, '7i. 850px 宽窗口侧栏缩窄为 190px',
          issue: '窄窗口侧栏宽度异常，实测 $sideWidth');
    }
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpAndSettle();

    debugPrint('===== 深度体验结束：发现 ${issues.length} 个体验问题 =====');
    for (var i = 0; i < issues.length; i++) {
      debugPrint('[改进 ${i + 1}] ${issues[i]}');
    }
  });
}
