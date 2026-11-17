/// 贴记 PinNote · 任务日期格式化（真实 dueAt → 任务/详情 Chip 文案）
library;

import 'package:intl/intl.dart';

/// 将真实日期时间转为设计稿风格的短文案：
/// 今天 HH:mm / 明天 HH:mm / M月d日 HH:mm
String formatTaskDue(DateTime due) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  final dayDiff = dueDay.difference(today).inDays;
  final time = DateFormat('HH:mm').format(due);
  if (dayDiff == 0) return '今天 $time';
  if (dayDiff == 1) return '明天 $time';
  if (dayDiff == -1) return '昨天 $time · 已逾期';
  return '${DateFormat('M月d日').format(due)} $time';
}

/// 编辑器中的日期短标签：今天 / 明天 / 11月16日
String formatDueDay(DateTime due) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final dueDay = DateTime(due.year, due.month, due.day);
  final diff = dueDay.difference(today).inDays;
  if (diff == 0) return '今天';
  if (diff == 1) return '明天';
  if (diff == 2) return '后天';
  return DateFormat('M月d日').format(due);
}

DateTime dateOnly(DateTime value) =>
    DateTime(value.year, value.month, value.day);

DateTime withTimeOfDay(DateTime date, int hour, int minute) =>
    DateTime(date.year, date.month, date.day, hour, minute);
