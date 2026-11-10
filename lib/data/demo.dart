/// 贴记 PinNote · 演示数据
///
/// 与设计稿各屏展示的数据一致（home / notes / task-edit / search 等）。
/// 真实数据接入后此文件由 Repository 层替代，仅用于第一阶段视觉还原。
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/tokens.dart';
import '../widgets/chips.dart';

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
}

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
  ),
];

const kTodayTasks = <DemoTask>[
  DemoTask(
    title: '设计评审材料准备',
    meta: [
      PinChipMeta('14:00', icon: PinIcons.clock),
      PinChipMeta('#设计', style: PinChipStyle.violet),
    ],
    flagHigh: true,
    progress: (2, 4),
    listName: '工作',
    listColor: PinListDots.work,
    selected: true,
  ),
  DemoTask(
    title: '整理 Q4 用户反馈',
    meta: [
      PinChipMeta('16:30', icon: PinIcons.clock),
      PinChipMeta('#复盘', style: PinChipStyle.violet),
    ],
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
  DemoTask(title: '晨跑 30 分钟', done: true),
  DemoTask(title: '确认周五聚餐地点', done: true),
  DemoTask(title: '提交报销单', done: true),
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
  });

  final String title;
  final StickyColor color;
  final String time;
  final bool pinned;
  final bool locked;
  final String? tag;
  final List<(String, bool)> checks;
  final List<String> lines;
}

const kDemoNotes = <DemoNote>[
  DemoNote(
    title: '周报要点',
    color: StickyColor.lemon,
    time: '2 小时前',
    pinned: true,
    tag: '#工作',
    checks: [('竞品动态梳理', true), ('数据指标核对', true), ('Q4 目标对齐', false)],
  ),
  DemoNote(
    title: '书单',
    color: StickyColor.sky,
    time: '3 天前',
    tag: '#阅读',
    checks: [('《卡片笔记写作法》', false), ('《认知觉醒》', false), ('《瞬间之美》', false)],
  ),
  DemoNote(
    title: '健身计划',
    color: StickyColor.mint,
    time: '昨天',
    pinned: true,
    checks: [('跑步 3 公里', true), ('力量训练', false), ('拉伸 10 分钟', false)],
  ),
  DemoNote(
    title: '灵感',
    color: StickyColor.cherry,
    time: '11月6日',
    tag: '#设计',
    checks: [('把提醒做成可选的', false), ('『贴纸边角』样式？', false)],
  ),
  DemoNote(
    title: 'Wi-Fi 密码',
    color: StickyColor.lavender,
    time: '10月28日',
    pinned: true,
    locked: true,
    lines: ['客厅：pinnote2026', '客房：hello888'],
  ),
  DemoNote(
    title: '购物清单',
    color: StickyColor.paper,
    time: '11月8日',
    checks: [('咖啡豆', false), ('滤纸', false), ('猫砂', true)],
  ),
];
