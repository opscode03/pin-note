/// 贴记 PinNote · 便签仓库（P2：便签编辑真实化 + 持久化）
library;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../design/tokens.dart';
import 'demo.dart';

/// 便签仓库：编辑器可编辑（标题 / 勾选项 / 颜色），变更持久化
class NoteRepository extends ChangeNotifier {
  NoteRepository();

  List<DemoNote> _notes = List.of(kDemoNotes);
  String? _selectedId;

  List<DemoNote> get notes => List.unmodifiable(_notes);
  int get pinnedCount => _notes.where((n) => n.pinned).length;

  DemoNote? get selected {
    if (_selectedId != null) {
      final i = _notes.indexWhere((n) => n.id == _selectedId);
      if (i != -1) return _notes[i];
    }
    return _notes.isEmpty ? null : _notes.first;
  }

  void select(String id) {
    if (_selectedId == id) return;
    _selectedId = id;
    notifyListeners();
  }

  void update(String id,
      {String? title, StickyColor? color, bool? pinned, bool? locked}) {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i == -1) return;
    _notes[i] = _notes[i].copyWith(
      title: title,
      color: color,
      pinned: pinned,
      locked: locked,
      time: '刚刚',
    );
    notifyListeners();
    unawaited(save());
  }

  void toggleCheck(String id, int index) {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i == -1) return;
    final n = _notes[i];
    if (index >= n.checks.length) return;
    final checks = List.of(n.checks);
    final (label, done) = checks[index];
    checks[index] = (label, !done);
    _notes[i] = n.copyWith(checks: checks, time: '刚刚');
    notifyListeners();
    unawaited(save());
  }

  void addCheck(String id, String label) {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i == -1) return;
    final n = _notes[i];
    _notes[i] = n.copyWith(
      checks: [...n.checks, (label, false)],
      time: '刚刚',
    );
    notifyListeners();
    unawaited(save());
  }

  void removeCheck(String id, int index) {
    final i = _notes.indexWhere((n) => n.id == id);
    if (i == -1) return;
    final n = _notes[i];
    if (index >= n.checks.length) return;
    final checks = List.of(n.checks)..removeAt(index);
    _notes[i] = n.copyWith(checks: checks, time: '刚刚');
    notifyListeners();
    unawaited(save());
  }

  // ---------- 持久化 ----------

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('notes');
      if (raw == null || raw.isEmpty) return;
      final list = DemoNote.listFromJson(raw);
      if (list.isNotEmpty) {
        _notes = list;
        _selectedId = null;
        notifyListeners();
      }
    } catch (_) {
      // 测试环境无插件实现或数据损坏：回退到种子数据
    }
  }

  Future<void> save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('notes', DemoNote.listToJson(_notes));
    } catch (_) {
      // 测试环境无插件实现：跳过持久化
    }
  }

  /// 走查/调试用：恢复种子数据并清空持久化
  Future<void> reset() async {
    _notes = List.of(kDemoNotes);
    _selectedId = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('notes');
    } catch (_) {
      // 测试环境无插件实现：跳过
    }
    notifyListeners();
  }
}
