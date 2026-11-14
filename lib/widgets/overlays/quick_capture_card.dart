/// 贴记 PinNote · 快速捕获卡片（对应 ui/quick-capture.html .capture）
///
/// 同时用于：
/// - `/quick-capture` 路由屏（壁纸场景展示态）
/// - `showQuickCaptureDialog`（应用内浮层）
/// 「添加待办」写入任务仓库 + Toast 反馈后关闭；「存为便签」关闭并切换到便签库。
library;

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../data/capture_parser.dart';
import '../../data/demo.dart';
import '../../app/navigation.dart';
import '../../design/icons.dart';
import '../../design/theme.dart';
import '../../design/tokens.dart';
import '../buttons.dart';
import '../app_window.dart';
import '../chips.dart';
import '../toast.dart';

/// 快速捕获卡片
class QuickCaptureCard extends StatefulWidget {
  const QuickCaptureCard({super.key, required this.width});

  final double width;

  @override
  State<QuickCaptureCard> createState() => _QuickCaptureCardState();
}

class _QuickCaptureCardState extends State<QuickCaptureCard> {
  late final TextEditingController _title =
      TextEditingController(text: '提交周报 #工作 !!');
  late CaptureParse _parse = parseCapture(_title.text);

  @override
  void initState() {
    super.initState();
    _title.addListener(_onChanged);
  }

  void _onChanged() {
    final p = parseCapture(_title.text);
    if (p.title != _parse.title ||
        p.dateLabel != _parse.dateLabel ||
        p.priority != _parse.priority ||
        p.tags.toString() != _parse.tags.toString()) {
      setState(() => _parse = p);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      width: widget.width,
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 20),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.lg),
        border: Border.all(color: spec.line),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, 24),
            blurRadius: 64,
            color: Color(0x80040812), // rgba(4,8,18,.5)
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部
          Row(
            children: [
              const PinLogo(),
              const SizedBox(width: 10),
              Text(
                '快速捕获',
                style: TextStyle(
                  fontSize: PinFontSize.xs,
                  fontWeight: FontWeight.w600,
                  color: spec.text2,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
              const Spacer(),
              const PinKbd(['Ctrl', 'Shift', 'Space']),
              const SizedBox(width: 6),
              PinIconButton(
                PinIcons.close,
                size: 28,
                iconSize: 13,
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // 输入行（识别高亮 + 光标）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: spec.primaryTint,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    '明天9:00',
                    style: TextStyle(
                      fontSize: PinFontSize.lg,
                      fontWeight: FontWeight.w700,
                      color: spec.primaryStrong,
                      fontFamilyFallback: PinFont.sans,
                    ),
                  ),
                ),
                // Wrap 内不可用 Expanded：标题输入用固定宽（设计稿识别段占位）
                SizedBox(
                  width: 220,
                  child: Material(
                    type: MaterialType.transparency,
                    child: TextField(
                      controller: _title,
                      autofocus: true,
                      style: TextStyle(
                        fontSize: PinFontSize.lg,
                        color: spec.text,
                        fontFamilyFallback: PinFont.sans,
                      ),
                      cursorColor: spec.primary,
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
                Text(
                  '#工作',
                  style: TextStyle(
                    fontSize: PinFontSize.lg,
                    fontWeight: FontWeight.w700,
                    color: spec.violetStrong,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
                Text(
                  '!!',
                  style: TextStyle(
                    fontSize: PinFontSize.lg,
                    fontWeight: FontWeight.w700,
                    color: spec.dangerStrong,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
                Container(width: 2, height: 20, color: spec.primary),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 识别结果 chips
          const Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              PinChip(
                '11月10日 周二 09:00',
                style: PinChipStyle.accent,
                size: PinChipSize.lg,
                icon: PinIcons.calendar,
                bold: true,
              ),
              PinChip(
                '#工作',
                style: PinChipStyle.violet,
                size: PinChipSize.lg,
                icon: PinIcons.tag,
              ),
              PinChip(
                '高优先级',
                style: PinChipStyle.red,
                size: PinChipSize.lg,
                icon: PinIcons.flag,
              ),
              PinChip(
                '清单 · 工作',
                size: PinChipSize.lg,
                trailingIcon: PinIcons.chevronDown,
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 底部
          Row(
            children: [
              Expanded(
                child: Text(
                  '自动识别日期 · 标签 · 优先级，保存后同步到所有设备',
                  style: TextStyle(
                    fontSize: PinFontSize.xs2,
                    color: spec.text2,
                    fontFamilyFallback: PinFont.sans,
                  ),
                ),
              ),
              const SizedBox(width: PinSpace.s3),
              PinButton(
                '存为便签',
                variant: PinButtonVariant.secondary,
                onTap: () {
                  Navigator.pop(context);
                  AppNav.go(context, '/notes');
                },
              ),
              const SizedBox(width: 10),
              PinButton(
                '添加待办',
                trailingIcon: PinIcons.enter,
                onTap: () {
                  if (_parse.title.isEmpty) return;
                  final repo = TaskScope.of(context);
                  repo.addFromCapture(_parse);
                  showPinToast(
                    context,
                    title: '已添加待办「${_parse.title}」',
                    subtitle:
                        '${_parse.dateLabel ?? '无日期'} · 收件箱${_parse.priority == PinPriority.high ? ' · 高优先级' : ''}',
                  );
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
