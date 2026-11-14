/// 贴记 PinNote · 快速捕获自然语言解析（P2）
///
/// 从输入文本中识别：
/// - 标签：`#xxx`
/// - 优先级：`!`（中）`!!`（高）`!!!`（高）
/// - 日期：今天/明天/后天/大后天 + 可选时刻（HH:MM / X点[半]），
///   以及 周X + 时刻；只带时刻 → 今天
/// 剩余文本为标题。
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
  });

  final String title;
  final List<String> tags;
  final PinPriority priority;
  final String? dateLabel;

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
  );
}

final RegExp _tagExp = RegExp(r'#\S+');
final RegExp _comboExp =
    RegExp(r'(今天|明天|后天|大后天|周[一二三四五六日天])?\s*(\d{1,2}[::：]\d{2}|\d{1,2}点(半|\d{1,2}分?)?)?');

/// 解析输入 → CaptureParse
CaptureParse parseCapture(String input) {
  var text = input;
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

  // 日期（先匹配组合，再匹配单独日期 / 时刻）
  String? dateLabel;
  final combo = _comboExp.firstMatch(text);
  if (combo != null && combo.group(0)!.trim().isNotEmpty) {
    final day = combo.group(1);
    final time = combo.group(2);
    if (day != null && time != null) {
      dateLabel = _normalizeTime(day, time);
    } else if (day != null) {
      dateLabel = day;
    } else if (time != null) {
      dateLabel = '今天 ${_normalizeClock(time)}';
    }
    if (dateLabel != null) {
      text = text.replaceFirst(combo.group(0)!, ' ');
    }
  }

  final title = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  return CaptureParse(
    title: title.isEmpty ? input.trim() : title,
    tags: tags,
    priority: priority,
    dateLabel: dateLabel,
  );
}

String _normalizeTime(String day, String time) =>
    '$day ${_normalizeClock(time)}';

String _normalizeClock(String time) {
  if (time.contains('点')) {
    final hour = RegExp(r'\d{1,2}').firstMatch(time)?.group(0) ?? '9';
    final half = time.contains('半');
    final minute = RegExp(r'点(\d{1,2})分?').firstMatch(time)?.group(1);
    final mm = half
        ? '30'
        : (minute == null ? '00' : minute.padLeft(2, '0'));
    return '${hour.padLeft(2, '0')}:$mm';
  }
  final parts = time.split(RegExp(r'[::：]'));
  final hh = parts[0].padLeft(2, '0');
  final mm = (parts.length > 1 ? parts[1] : '00').padLeft(2, '0');
  return '$hh:$mm';
}
