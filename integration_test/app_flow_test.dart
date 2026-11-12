/// 全流程操作走查（macOS 真机集成测试）
///
/// 以用户视角按主路径逐步操作当前 app，验证每条流程的衔接与可达性，
/// 并实测 Navigator 栈行为（push 累积问题取证）。
/// 运行：flutter test integration_test/app_flow_test.dart -d macos
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pin_note/app/app.dart';
import 'package:pin_note/app/desktop_window.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final issues = <String>[];

  testWidgets('主流程操作走查', (tester) async {
    // 真实桌面窗口（无边框 + 自绘标题栏）
    await DesktopWindow.ensureInitialized();

    await tester.pumpWidget(const PinNoteApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    void mark(bool ok, String what) {
      debugPrint('[走查] ${ok ? "✅" : "❌"} $what');
      if (!ok) issues.add(what);
    }

    Future<void> settle([String? label]) async {
      await tester.pumpAndSettle();
      // 真实停顿：给外部截屏留窗口，也模拟真人节奏
      await Future<void>.delayed(const Duration(milliseconds: 900));
      if (label != null) debugPrint('[走查] —— $label');
    }

    // ---------- 流程 A：主导航 ----------
    debugPrint('===== 流程 A：主导航 =====');
    await settle('今日页（起点）');
    expect(find.text('已逾期'), findsWidgets);

    await tester.tap(find.text('便签库').first, warnIfMissed: false);
    await settle('A1 侧栏「便签库」');
    mark(find.text('新建便签').evaluate().isNotEmpty, 'A1 侧栏「便签库」→ 便签库页');

    await tester.tap(find.text('搜索任务与便签…'), warnIfMissed: false);
    await settle('A2 标题栏搜索胶囊');
    mark(find.text('评审').evaluate().isNotEmpty,
        'A2 标题栏搜索 → 搜索页（关键词「评审」高亮）');

    // ---------- 流程 B：搜索结果 → 任务编辑 ----------
    debugPrint('===== 流程 B：搜索 → 任务编辑 =====');
    await tester.tap(find.text('设计评审材料准备').first, warnIfMissed: false);
    await settle('B1 打开任务编辑弹层');
    mark(find.text('日期与时间').evaluate().isNotEmpty, 'B1 搜索结果行 → 任务编辑弹层');
    mark(find.text('2026 年 11 月').evaluate().isNotEmpty, 'B2 弹层含迷你月历');

    final navForPopCheck = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    final canPopBefore = navForPopCheck.canPop();
    await tester.tap(find.text('确定'), warnIfMissed: false);
    await settle('B3 点「确定」');
    final canPopAfter = navForPopCheck.canPop();
    debugPrint('[走查] ℹ️ 「确定」前 canPop=$canPopBefore，后 canPop=$canPopAfter'
        '（true = 栈在叠加：返回操作会退回旧层而非关闭）');
    mark(find.text('已逾期').evaluate().isNotEmpty, 'B3 弹层「确定」→ 回到今日页');

    // ---------- 流程 C：便签链路 ----------
    debugPrint('===== 流程 C：便签链路 =====');
    await tester.tap(find.text('便签库').first, warnIfMissed: false);
    await settle('C0 进入便签库');
    await tester.tap(find.text('新建便签').first, warnIfMissed: false);
    await settle('C1 新建便签');
    mark(find.text('已自动保存 · 上次编辑 2 分钟前').evaluate().isNotEmpty,
        'C1 便签库「新建便签」→ 便签编辑器');

    await tester.tap(find.text('贴到桌面'), warnIfMissed: false);
    await settle('C2 贴到桌面');
    mark(find.text('产品发布会').evaluate().isNotEmpty, 'C2 编辑器「贴到桌面」→ 桌面贴总览');

    await tester.tap(find.text('贴在眼前。』'), warnIfMissed: false);
    await settle('C3 点品牌口号便签');
    mark(find.text('点击穿透').evaluate().isNotEmpty, 'C3 点桌面贴便签 → 控制菜单');

    await tester.tap(find.text('取消贴附'), warnIfMissed: false);
    await settle('C4 取消贴附');
    mark(find.text('新建便签').evaluate().isNotEmpty, 'C4 菜单「取消贴附」→ 便签库');

    // ---------- 流程 D：快速捕获 ----------
    debugPrint('===== 流程 D：快速捕获 =====');
    await tester.tap(find.text('今日').first, warnIfMissed: false);
    await settle('D0 回今日');
    await tester.tap(
      find.text('添加任务，输入 #标签 · !优先级 · 明天 9:00…'),
      warnIfMissed: false,
    );
    await settle('D1 快速添加');
    mark(find.text('自动识别日期 · 标签 · 优先级，保存后同步到所有设备')
            .evaluate()
            .isNotEmpty,
        'D1 今日「快速添加」→ 快速捕获');
    await tester.tap(find.text('添加待办'), warnIfMissed: false);
    await settle('D2 添加待办');
    mark(find.text('已逾期').evaluate().isNotEmpty, 'D2 「添加待办」→ 回今日页');

    // ---------- 流程 E：设置 / 主题 / 托盘 ----------
    debugPrint('===== 流程 E：设置 / 主题 / 托盘 =====');
    final diagCtx = tester.element(find.byType(MaterialApp).first);
    debugPrint('[诊断] E1 前视口=${MediaQuery.sizeOf(diagCtx)} '
        'tooltip(设置)=${find.byTooltip('设置').evaluate().length} '
        '文本(今天)=${find.text('今天').evaluate().length} '
        '文本(便签库)=${find.text('便签库').evaluate().length} '
        'canPop=${tester.state<NavigatorState>(find.byType(Navigator).first).canPop()}');
    final gearRect = tester.getRect(find.byTooltip('设置'));
    debugPrint('[诊断] 齿轮矩形=$gearRect 中心=${gearRect.center}');
    await tester.tap(find.byTooltip('设置'), warnIfMissed: true);
    await settle('E1 设置·外观');
    debugPrint('[诊断] E1 后 文本(外观)=${find.text('外观').evaluate().length} '
        '文本(深色)=${find.text('深色').evaluate().length} '
        '文本(主题、强调色…)=${find.text('主题、强调色、字号与桌面贴默认模式').evaluate().length}');
    mark(find.text('主题、强调色、字号与桌面贴默认模式').evaluate().isNotEmpty,
        'E1 标题栏 ⚙ → 设置·外观');

    final darkCount = find.text('深色').evaluate().length;
    debugPrint('[诊断] 深色 tile 数量=$darkCount');
    if (darkCount > 0) {
      await tester.tap(find.text('深色').first, warnIfMissed: false);
      await settle('E2 切深色');
    }
    final brightness =
        Theme.of(tester.element(find.text('外观').first)).brightness;
    mark(brightness == Brightness.dark, 'E2 主题选「深色」→ 立即生效');

    await tester.tap(find.text('通知'), warnIfMissed: false);
    await settle('E3 托盘与通知');
    mark(find.text('稍后 10 分钟').evaluate().isNotEmpty, 'E3 设置「通知」→ 托盘与通知');

    await tester.tap(find.text('完成'), warnIfMissed: false);
    await settle('E4 通知「完成」');
    mark(find.text('已逾期').evaluate().isNotEmpty, 'E4 通知「完成」→ 回今日页');

    await tester.tap(find.byTooltip('切换主题'), warnIfMissed: false);
    await settle('切回浅色');
    final brightnessAfter =
        Theme.of(tester.element(find.text('今天').first)).brightness;
    mark(brightnessAfter == Brightness.light, 'E5 标题栏 ⏾ 切回浅色');

    // ---------- 栈行为取证 ----------
    debugPrint('===== 栈行为取证 =====');
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    var pops = 0;
    while (nav.canPop() && pops < 40) {
      nav.pop();
      pops += 1;
    }
    await tester.pumpAndSettle();
    debugPrint('[走查] ℹ️ 走完全部流程后需要 pop $pops 次才回到栈底'
        '（理想值：主屏切换 0，浮层关闭 1）');
    issues.add('Navigator 栈叠加：全流程走完需要 pop $pops 次才回栈底');

    debugPrint('===== 走查结束：${issues.length} 个问题 =====');
    for (final s in issues) {
      debugPrint('[问题] $s');
    }
  });
}
