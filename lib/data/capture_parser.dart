/// 贴记 PinNote · 快速捕获自然语言解析（P2）
///
/// 从输入文本中识别：
/// - 标签：`#xxx`
/// - 优先级：`!`（中）`!!`（高）`!!!`（高）
/// - 日期：今天/明天/后天/大后天/周X + 可选时刻（HH:MM / X点[半]），
///   以及 上午/下午/晚上 前缀；只带时刻 → 今天。
/// 同时产出真实 [DateTime]（供任务 dueAt 持久化）。
library;

import '../design/icons.dart';
import '../design/tokens.dart';
import 'demo.dart';

/// 解析结果
class CaptureParse {
  const CaptureParse({
    required this.title,
    required this.tags,
    required this.priority,
    this.dateLabel,
    this.dueAt,
  });

  final String title;
  final List<String> tags;
  final PinPriority priority;
  final String? dateLabel;

  /// 由自然语言计算出的真实日期时间
  final DateTime? dueAt;
}

/// 解析结果 → 任务（仓库落库用）
DemoTask captureToTask(CaptureParse parse) {
  final meta = <PinChipMeta>[
    if (parse.dateLabel != null)
      PinChipMeta(parse.dateLabel!, icon: PinIcons.clock),
  ];
  return DemoTask(
    id: '${parse.title}#${DateTime.now().millisecondsSinceEpoch}',
    title: parse.title,
    meta: meta,
    tags: parse.tags,
    priority: parse.priority,
    listName: '收件箱',
    listColor: PinListDots.inbox,
    group: TaskGroup.today,
    dueAt: parse.dueAt,
  );
}

final RegExp _tagExp = RegExp(r'#\S+');
final RegExp _periodExp = RegExp('上午|下午|晚上');
final RegExp _comboExp = RegExp(
    r'(今天|明天|后天|大后天|下周[一二三四五六日天]|周[一二三四五六日天])?\s*(\d{1,2}[::：]\d{2}|\d{1,2}点(半|\d{1,2}分?)?)?');

/// 解析输入 → CaptureParse；[now] 供测试注入固定基准时间
CaptureParse parseCapture(String input, {DateTime? now}) {
  var text = input;
  final base = now ?? DateTime.now();
  final tags = <String>[];

  // 标签
  for (final m in _tagExp.allMatches(text).toList()) {
    tags.add(m.group(0)!);
  }
  text = text.replaceAll(_tagExp, '');

  // 优先级：独立连续感叹号 ! = 中 / !! 及以上 = 高
  var priority = PinPriority.none;
  if (text.contains('!!')) {
    priority = PinPriority.high;
  } else if (RegExp(r'(?<![!])!(?![!])').hasMatch(text)) {
    priority = PinPriority.medium;
  }
  if (priority != PinPriority.none) {
    text = text.replaceAll('!', '');
  }

  final period = _periodExp.firstMatch(text)?.group(0);
  if (period != null) text = text.replaceAll(period, '');

  // 日期（先匹配组合，再匹配单独日期 / 时刻）
  String? dateLabel;
  DateTime? dueAt;
  final combo = _comboExp.firstMatch(text);
  if (combo != null && combo.group(0)!.trim().isNotEmpty) {
    final day = combo.group(1);
    final time = combo.group(2);
    if (day != null && time != null) {
      dateLabel = '$day ${_normalizeClock(time, period)}';
    } else if (day != null) {
      dateLabel = day;
    } else if (time != null) {
      dateLabel = '今天 ${_normalizeClock(time, period)}';
    }
    if (dateLabel != null) {
      dueAt = _resolveDueAt(day, time, base, period);
      text = text.replaceFirst(combo.group(0)!, ' ');
    }
  }

  final title = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return CaptureParse(
    title: title.isEmpty ? input.trim() : title,
    tags: tags,
    priority: priority,
    dateLabel: dateLabel,
    dueAt: dueAt,
  );
}

String _normalizeClock(String time, [String? period]) {
  var hour = 9;
  var minute = 0;
  final colon = RegExp(r'^(\d{1,2})[::：](\d{1,2})$').firstMatch(time);
  if (colon != null) {
    hour = int.parse(colon.group(1)!);
    minute = int.parse(colon.group(2)!);
  } else {
    hour = int.tryParse(RegExp(r'\d{1,2}').firstMatch(time)?.group(0) ?? '9') ?? 9;
    final half = time.contains('半');
    final minuteText = RegExp(r'点(\d{1,2})分?').firstMatch(time)?.group(1);
    minute = half ? 30 : (int.tryParse(minuteText ?? '0') ?? 0);
  }
  if (period == '下午' || period == '晚上') {
    if (hour < 12) hour += 12;
  }
  if (period == '上午' && hour == 12) hour = 0;
  return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}

DateTime _resolveDueAt(
  String? day,
  String? time,
  DateTime base,
  String? period,
) {
  var date = DateTime(base.year, base.month, base.day);
  if (day == null && time == null) return date;
  if (day == '明天') {
    date = date.add(const Duration(days: 1));
  } else if (day == '后天') {
    date = date.add(const Duration(days: 2));
  } else if (day == '大后天') {
    date = date.add(const Duration(days: 3));
  } else if (day != null &&
      (day.startsWith('周') || day.startsWith('下周'))) {
    const weekdays = {
      '一': DateTime.monday,
      '二': DateTime.tuesday,
      '三': DateTime.wednesday,
      '四': DateTime.thursday,
      '五': DateTime.friday,
      '六': DateTime.saturday,
      '日': DateTime.sunday,
      '天': DateTime.sunday,
    };
    final target = weekdays[
        day.startsWith('下周') ? day.substring(2) : day.substring(1)]!;
    var delta = (target - date.weekday) % 7;
    if (delta == 0) delta = 7; // 本周已过日期语义：取下一周
    date = date.add(Duration(days: delta));
  }
  final clock = time == null ? '09:00' : _normalizeClock(time, period);
  final parts = clock.split(':');
  return DateTime(
    date.year,
    date.month,
    date.day,
    int.parse(parts[0]),
    int.parse(parts[1]),
  );
}
