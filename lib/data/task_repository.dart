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

  /// 完成前的来源分组（撤销时精确恢复）
  final Map<String, TaskGroup> _originGroups = {};

  List<DemoTask> get overdue =>
      _tasks.where((t) => t.group == TaskGroup.overdue).toList();
  List<DemoTask> get today =>
      _tasks.where((t) => t.group == TaskGroup.today && !t.done).toList();
  List<DemoTask> get done => _tasks.where((t) => t.done).toList();
  List<DemoTask> get tasks => List.unmodifiable(_tasks);

  DemoTask byId(String id) =>
      _tasks.firstWhere((t) => t.id == id, orElse: () => _tasks.first);

  /// 当前选中（详情面板展示的任务；打开编辑弹层时自动选中）
  String? get selectedId => _selectedId;
  String? _selectedId;

  void select(String id) {
    if (_selectedId == id) return;
    _selectedId = id;
    notifyListeners();
  }

  /// 解析「可编辑任务」：选中 → 今天第一条 → 逾期第一条
  DemoTask? resolveEditable() {
    final s = selectedTask;
    if (s != null) return s;
    if (today.isNotEmpty) return today.first;
    if (overdue.isNotEmpty) return overdue.first;
    return null;
  }

  DemoTask? get selectedTask {
    if (_selectedId != null) {
      final i = _tasks.indexWhere((t) => t.id == _selectedId);
      if (i != -1) return _tasks[i];
    }
    final i = _tasks.indexWhere((t) => t.selected || t.id != null);
    return i == -1 ? null : _tasks[i];
  }

  /// 保存编辑（标题 / 优先级 / 标签）
  void updateTask(String id, {String? title, PinPriority? priority, List<String>? tags}) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    _tasks[i] = _tasks[i].copyWith(title: title, priority: priority, tags: tags);
    notifyListeners();
  }

  /// 删除（返回可撤销句柄：调用 restore 恢复到原位置）
  ({VoidCallback restore})? deleteTask(String id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return null;
    final removed = _tasks[i];
    _tasks.removeAt(i);
    if (_selectedId == id) _selectedId = null;
    notifyListeners();
    return (
      restore: () {
        _tasks.insert(i.clamp(0, _tasks.length), removed);
        notifyListeners();
      },
    );
  }

  /// 勾选 / 取消勾选：完成 → 移入已完成组；撤销 → 精确回到来源分组
  void toggleDone(String id) {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i == -1) return;
    final t = _tasks[i];
    final nowDone = !t.done;
    if (nowDone) {
      _originGroups[t.id!] = t.group;
      _tasks[i] = t.copyWith(done: true, group: TaskGroup.done);
    } else {
      final origin = _originGroups.remove(t.id!) ?? TaskGroup.today;
      _tasks[i] = t.copyWith(done: false, group: origin);
    }
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
