/// 任务仓库（P0：勾选完成 / 快速添加的最小状态层）
///
/// ChangeNotifier 持有演示任务；UI 层通过 [TaskScope.of] 读写。
/// 真实数据接入后由 Repository 接口替代，变更方法签名保持稳定。
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/tokens.dart';

import 'demo.dart';

/// 任务状态仓库
class TaskRepository extends ChangeNotifier {
  TaskRepository()
      : _tasks = [
          for (final t in [...kOverdueTasks, ...kTodayTasks, ...kDoneTasks])
            t.copyWith(id: t.title),
        ];

  final List<DemoTask> _tasks;

  List<DemoTask> get overdue =>
      _tasks.where((t) => t.group == TaskGroup.overdue).toList();
  List<DemoTask> get today =>
      _tasks.where((t) => t.group == TaskGroup.today && !t.done).toList();
  List<DemoTask> get done => _tasks.where((t) => t.done).toList();

  DemoTask byId(String id) =>
      _tasks.firstWhere((t) => t.id == id, orElse: () => _tasks.first);

  /// 勾选 / 取消勾选：完成 → 移入已完成组；撤销 → 回原分组
  void toggleDone(String id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final t = _tasks[i];
    final nowDone = !t.done;
    _tasks[i] = t.copyWith(
      done: nowDone,
      group: nowDone
          ? TaskGroup.done
          : (t.group == TaskGroup.done ? TaskGroup.today : t.group),
    );
    notifyListeners();
  }

  /// 快速捕获添加待办（P0 最小联动：标题 + 默认明天 9:00）
  void addQuickTask(String title) {
    _tasks.insert(
      0,
      DemoTask(
        title: title,
        meta: const [
          PinChipMeta('明天 9:00', icon: PinIcons.clock),
        ],
        listName: '收件箱',
        listColor: PinListDots.inbox,
        group: TaskGroup.today,
        id: '$title#${DateTime.now().millisecondsSinceEpoch}',
      ),
    );
    notifyListeners();
  }
}
