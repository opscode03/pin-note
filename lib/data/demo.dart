/// 贴记 PinNote · 演示数据
///
/// 与设计稿各屏展示的数据一致（home / notes / task-edit / search 等）。
/// 真实数据接入后此文件由 Repository 层替代，仅用于第一阶段视觉还原。
library;

import 'dart:convert';

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/tokens.dart';
import '../widgets/chips.dart';

/// 任务优先级（对应任务编辑弹层的优先级四选）
enum PinPriority { none, low, medium, high }

extension PinPriorityX on PinPriority {
  String get label => switch (this) {
        PinPriority.none => '无',
        PinPriority.low => '低',
        PinPriority.medium => '中',
        PinPriority.high => '高',
      };
}

/// 演示任务（对应 home.html 的任务行）
class DemoTask {
  const DemoTask({
    required this.title,
    this.meta = const <PinChipMeta>[],
    this.listName,
    this.listColor,
    this.done = false,
    this.selected = false,
    this.flagHigh = false,
    this.progress,
    this.group = TaskGroup.today,
    this.id,
    this.priority = PinPriority.none,
    this.tags = const <String>[],
  });

  final String title;
  final List<PinChipMeta> meta;
  final String? listName;
  final Color? listColor;
  final bool done;
  final bool selected;
  final bool flagHigh;

  /// 子任务进度 (done, total)
  final (int, int)? progress;

  /// 所属分组（逾期/今天/已完成）——勾选完成后跨组移动
  final TaskGroup group;

  /// 稳定标识（仓库内唯一；种子数据默认取标题）
  final String? id;

  /// 优先级（任务编辑可改）
  final PinPriority priority;

  /// 标签（#xxx；任务编辑可增删）
  final List<String> tags;

  // ---------- JSON（shared_preferences 持久化） ----------

  Map<String, dynamic> toJson() => {
        'id': id ?? title,
        'title': title,
        'meta': [
          for (final m in meta)
            {
              'label': m.label,
              'style': m.style.name,
              'icon': m.icon?.name,
            },
        ],
        'listName': listName,
        'listDot': _dotName(listColor),
        'done': done,
        'selected': selected,
        'flagHigh': flagHigh,
        'progress': progress == null ? null : [progress!.$1, progress!.$2],
        'group': group.name,
        'priority': priority.name,
        'tags': tags,
      };

  static DemoTask fromJson(Map<String, dynamic> j) => DemoTask(
        id: j['id'] as String?,
        title: j['title'] as String? ?? '任务',
        meta: [
          for (final m in (j['meta'] as List<dynamic>? ?? []))
            PinChipMeta(
              (m as Map<String, dynamic>)['label'] as String,
              style: PinChipStyle.values.firstWhere(
                (st) => st.name == m['style'],
                orElse: () => PinChipStyle.accent,
              ),
              icon: m['icon'] == null ? null : pinIconByName(m['icon'] as String),
            ),
        ],
        listName: j['listName'] as String?,
        listColor: _dotByName(j['listDot'] as String?),
        done: j['done'] as bool? ?? false,
        selected: j['selected'] as bool? ?? false,
        flagHigh: j['flagHigh'] as bool? ?? false,
        progress: j['progress'] == null
            ? null
            : (
                (j['progress'] as List<dynamic>)[0] as int,
                (j['progress'] as List<dynamic>)[1] as int,
              ),
        group: TaskGroup.values.firstWhere(
          (g) => g.name == j['group'],
          orElse: () => TaskGroup.today,
        ),
        priority: PinPriority.values.firstWhere(
          (p) => p.name == j['priority'],
          orElse: () => PinPriority.none,
        ),
        tags: [for (final t in (j['tags'] as List<dynamic>? ?? [])) t as String],
      );

  static String? _dotName(Color? c) {
    if (c == const Color(0xFF4A7DFF)) return 'inbox';
    if (c == PinListDots.work) return 'work';
    if (c == PinListDots.life) return 'life';
    if (c == PinListDots.study) return 'study';
    if (c == PinListDots.read) return 'read';
    return null;
  }

  static Color? _dotByName(String? name) => switch (name) {
        'inbox' => PinListDots.inbox,
        'work' => PinListDots.work,
        'life' => PinListDots.life,
        'study' => PinListDots.study,
        'read' => PinListDots.read,
        _ => null,
      };

  static String listToJson(List<DemoTask> tasks) =>
      jsonEncode([for (final t in tasks) t.toJson()]);

  static List<DemoTask> listFromJson(String raw) => [
        for (final m in (jsonDecode(raw) as List<dynamic>))
          DemoTask.fromJson(m as Map<String, dynamic>),
      ];

  DemoTask copyWith({
    String? title,
    List<PinChipMeta>? meta,
    String? listName,
    Color? listColor,
    bool? done,
    bool? selected,
    bool? flagHigh,
    (int, int)? progress,
    TaskGroup? group,
    String? id,
    PinPriority? priority,
    List<String>? tags,
  }) {
    return DemoTask(
      title: title ?? this.title,
      meta: meta ?? this.meta,
      listName: listName ?? this.listName,
      listColor: listColor ?? this.listColor,
      done: done ?? this.done,
      selected: selected ?? this.selected,
      flagHigh: flagHigh ?? this.flagHigh,
      progress: progress ?? this.progress,
      group: group ?? this.group,
      id: id ?? this.id,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }
}

/// 任务分组（对应 home.html 的分组标题）
enum TaskGroup { overdue, today, done }

/// 任务 meta 用的 Chip 配置
class PinChipMeta {
  const PinChipMeta(this.label, {this.style = PinChipStyle.accent, this.icon});

  final String label;
  final PinChipStyle style;
  final PinIconData? icon;
}

const kOverdueTasks = <DemoTask>[
  DemoTask(
    title: '回复客户张总的报价邮件',
    meta: [
      PinChipMeta(
        '昨天 9:30 · 已逾期',
        style: PinChipStyle.red,
        icon: PinIcons.clock,
      ),
    ],
    flagHigh: true,
    listName: '工作',
    listColor: PinListDots.work,
    group: TaskGroup.overdue,
  ),
];

const kTodayTasks = <DemoTask>[
  DemoTask(
    title: '设计评审材料准备',
    meta: [
      PinChipMeta('14:00', icon: PinIcons.clock),
    ],
    tags: ['#设计'],
    priority: PinPriority.high,
    progress: (2, 4),
    listName: '工作',
    listColor: PinListDots.work,
    selected: true,
  ),
  DemoTask(
    title: '整理 Q4 用户反馈',
    meta: [
      PinChipMeta('16:30', icon: PinIcons.clock),
    ],
    tags: ['#复盘'],
    listName: '工作',
    listColor: PinListDots.work,
  ),
  DemoTask(
    title: '预约牙医复诊',
    meta: [PinChipMeta('18:00', icon: PinIcons.clock)],
    listName: '生活',
    listColor: PinListDots.life,
  ),
  DemoTask(
    title: '背 50 个单词',
    meta: [PinChipMeta('每天', style: PinChipStyle.teal, icon: PinIcons.repeat)],
    listName: '学习',
    listColor: PinListDots.study,
  ),
  DemoTask(title: '买猫粮', listName: '生活', listColor: PinListDots.life),
];

const kDoneTasks = <DemoTask>[
  DemoTask(title: '晨跑 30 分钟', done: true, group: TaskGroup.done),
  DemoTask(title: '确认周五聚餐地点', done: true, group: TaskGroup.done),
  DemoTask(title: '提交报销单', done: true, group: TaskGroup.done),
];

/// 演示便签（对应 notes.html 的卡片）
class DemoNote {
  const DemoNote({
    required this.title,
    required this.color,
    required this.time,
    this.pinned = false,
    this.locked = false,
    this.tag,
    this.checks = const <(String, bool)>[],
    this.lines = const <String>[],
    this.id,
  });

  final String title;
  final StickyColor color;
  final String time;
  final bool pinned;
  final bool locked;
  final String? tag;
  final List<(String, bool)> checks;
  final List<String> lines;

  /// 稳定标识（仓库内唯一）
  final String? id;

  DemoNote copyWith({
    String? title,
    StickyColor? color,
    String? time,
    bool? pinned,
    bool? locked,
    String? tag,
    List<(String, bool)>? checks,
    List<String>? lines,
    String? id,
  }) {
    return DemoNote(
      title: title ?? this.title,
      color: color ?? this.color,
      time: time ?? this.time,
      pinned: pinned ?? this.pinned,
      locked: locked ?? this.locked,
      tag: tag ?? this.tag,
      checks: checks ?? this.checks,
      lines: lines ?? this.lines,
      id: id ?? this.id,
    );
  }

  // ---------- JSON（shared_preferences 持久化） ----------

  Map<String, dynamic> toJson() => {
        'id': id ?? title,
        'title': title,
        'color': color.name,
        'time': time,
        'pinned': pinned,
        'locked': locked,
        'tag': tag,
        'checks': [for (final (l, d) in checks) {'label': l, 'done': d}],
        'lines': lines,
      };

  static DemoNote fromJson(Map<String, dynamic> j) => DemoNote(
        id: j['id'] as String?,
        title: j['title'] as String? ?? '便签',
        color: StickyColor.values.firstWhere(
          (c) => c.name == j['color'],
          orElse: () => StickyColor.lemon,
        ),
        time: j['time'] as String? ?? '',
        pinned: j['pinned'] as bool? ?? false,
        locked: j['locked'] as bool? ?? false,
        tag: j['tag'] as String?,
        checks: [
          for (final c in (j['checks'] as List<dynamic>? ?? []))
            (
              (c as Map<String, dynamic>)['label'] as String,
              c['done'] as bool? ?? false,
            ),
        ],
        lines: [for (final l in (j['lines'] as List<dynamic>? ?? [])) l as String],
      );

  static String listToJson(List<DemoNote> notes) =>
      jsonEncode([for (final n in notes) n.toJson()]);

  static List<DemoNote> listFromJson(String raw) => [
        for (final m in (jsonDecode(raw) as List<dynamic>))
          DemoNote.fromJson(m as Map<String, dynamic>),
      ];
}

const kDemoNotes = <DemoNote>[
  DemoNote(
    id: '周报要点',
    title: '周报要点',
    color: StickyColor.lemon,
    time: '2 小时前',
    pinned: true,
    tag: '#工作',
    checks: [('竞品动态梳理', true), ('数据指标核对', true), ('Q4 目标对齐', false)],
  ),
  DemoNote(
    id: '书单',
    title: '书单',
    color: StickyColor.sky,
    time: '3 天前',
    tag: '#阅读',
    checks: [('《卡片笔记写作法》', false), ('《认知觉醒》', false), ('《瞬间之美》', false)],
  ),
  DemoNote(
    id: '健身计划',
    title: '健身计划',
    color: StickyColor.mint,
    time: '昨天',
    pinned: true,
    checks: [('跑步 3 公里', true), ('力量训练', false), ('拉伸 10 分钟', false)],
  ),
  DemoNote(
    id: '灵感',
    title: '灵感',
    color: StickyColor.cherry,
    time: '11月6日',
    tag: '#设计',
    checks: [('把提醒做成可选的', false), ('『贴纸边角』样式？', false)],
  ),
  DemoNote(
    id: 'Wi-Fi 密码',
    title: 'Wi-Fi 密码',
    color: StickyColor.lavender,
    time: '10月28日',
    pinned: true,
    locked: true,
    lines: ['客厅：pinnote2026', '客房：hello888'],
  ),
  DemoNote(
    id: '购物清单',
    title: '购物清单',
    color: StickyColor.paper,
    time: '11月8日',
    checks: [('咖啡豆', false), ('滤纸', false), ('猫砂', true)],
  ),
];
