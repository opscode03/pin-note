/// 贴记 PinNote · 迷你日历（对应 app.css .cal，任务编辑弹层内）
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import 'buttons.dart';

/// 迷你月历：星期行 + 6 行日期网格
class MiniCalendar extends StatelessWidget {
  const MiniCalendar({
    required this.year,
    required this.month,
    required this.leadingBlanks,
    required this.dayCount,
    required this.today,
    super.key,
  });

  final int year;
  final int month;
  final int leadingBlanks; // 周一开头的前置占位（上月尾日数）
  final int dayCount;
  final int today;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Column(
      children: [
        // 头部：左右箭头 + 年月
        Stack(
          alignment: Alignment.center,
          children: [
            Text(
              '$year 年 $month 月',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: spec.text,
                fontFamilyFallback: PinFont.sans,
              ),
            ),
            const Positioned(
              left: 0,
              child: PinIconButton(
                PinIcons.chevronLeft,
                size: 24,
                iconSize: 13,
              ),
            ),
            const Positioned(
              right: 0,
              child: PinIconButton(
                PinIcons.chevronRight,
                size: 24,
                iconSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 星期
        Row(
          children: [
            for (final wd in const ['一', '二', '三', '四', '五', '六', '日'])
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      wd,
                      style: TextStyle(
                        fontSize: PinFontSize.xs2,
                        color: spec.text2,
                        fontFamilyFallback: PinFont.sans,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        // 日期网格
        for (var row = 0; row < (leadingBlanks + dayCount + 6) ~/ 7; row++)
          Row(
            children: [
              for (var col = 0; col < 7; col++)
                Expanded(child: Center(child: _day(context, row, col))),
            ],
          ),
      ],
    );
  }

  Widget? _dayCell(BuildContext context, int index) {
    final spec = context.pin;
    if (index < leadingBlanks) {
      final day = 26 + index; // 2026-11 的设计稿固定前置 10 月 26-31
      return Text(
        '$day',
        style: TextStyle(
          fontSize: PinFontSize.xs2,
          color: spec.faint,
          fontFamilyFallback: PinFont.sans,
        ),
      );
    }
    final day = index - leadingBlanks + 1;
    if (day > dayCount) return const SizedBox(height: 26);
    final isToday = day == today;
    return Container(
      width: 26,
      height: 26,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? spec.primary : Colors.transparent,
      ),
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: PinFontSize.xs2,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          color: isToday ? Colors.white : spec.text,
          fontFamilyFallback: PinFont.sans,
        ),
      ),
    );
  }

  Widget _day(BuildContext context, int row, int col) {
    final index = row * 7 + col;
    final cell = _dayCell(context, index);
    return cell ?? const SizedBox(height: 26);
  }
}
