/// 贴记 PinNote · 托盘与通知（对应 ui/tray.html）
///
/// 任务提醒 Toast + 托盘右键菜单 + 任务栏托盘图标（激活态）。
library;

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/theme.dart';
import '../design/tokens.dart';
import '../widgets/app_window.dart';
import '../widgets/buttons.dart';
import '../widgets/interactive.dart';
import '../widgets/menu.dart';
import '../widgets/scene.dart';

class TrayScreen extends StatelessWidget {
  const TrayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WallpaperScene(
      variant: 'd',
      child: Stack(
        children: [
          // 任务提醒 Toast
          Positioned(right: 26, top: 58, width: 352, child: _ReminderToast()),
          // 托盘菜单
          Positioned(right: 18, bottom: 62, child: _TrayMenu()),
          const PinTaskbar(trayPinOn: true),
        ],
      ),
    );
  }
}

/// 任务提醒通知（对应 .toast-box .toast 的纵向布局）
class _ReminderToast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: spec.surface,
        borderRadius: BorderRadius.circular(PinRadius.md),
        border: Border.all(color: spec.line),
        boxShadow: spec.shadowFar,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const PinLogo(size: 22),
              const SizedBox(width: 10),
              Text(
                '贴记 PinNote · 任务提醒',
                style: TextStyle(
                  fontSize: PinFontSize.xs2,
                  color: spec.text2,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
              const Spacer(),
              const PinIconButton(PinIcons.close, size: 24, iconSize: 13),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '提交年度设计评审材料',
            style: spec.tmd.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 5),
          Text(
            '今天 14:00 · 工作 · 提前 30 分钟提醒',
            style: TextStyle(
              fontSize: PinFontSize.xs,
              color: spec.text2,
              fontFamilyFallback: PinFont.sans,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              _ToastButton(
                '完成',
                icon: PinIcons.check,
                filled: true,
                onTap: () => Navigator.pushNamed(context, '/'),
              ),
              const SizedBox(width: 8),
              const _ToastButton('稍后 10 分钟'),
              const SizedBox(width: 8),
              const _ToastButton('稍后 1 小时'),
            ],
          ),
        ],
      ),
    );
  }
}

/// 通知操作胶囊（对应 .t-btn）
class _ToastButton extends StatelessWidget {
  const _ToastButton(this.label, {this.icon, this.filled = false, this.onTap});

  final String label;
  final PinIconData? icon;
  final bool filled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final fg = filled ? spec.primaryStrong : spec.text2;
    return HoverBuilder(
      builder: (context, hover, _) => GestureDetector(
        onTap: onTap,
        child: Container(
          height: 28,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: filled ? spec.primaryTint : spec.surface,
            borderRadius: BorderRadius.circular(PinRadius.full),
            border: filled
                ? null
                : Border.all(color: hover ? spec.faint : spec.lineStrong),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                PinIcon(icon!, size: 11, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: PinFontSize.xs2,
                  fontWeight: filled ? FontWeight.w700 : FontWeight.w400,
                  color: fg,
                  fontFamilyFallback: PinFont.sans,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 托盘菜单（对应 .tray-menu）
class _TrayMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PinMenu(
      width: 268,
      dividersAfter: const [4, 6],
      header: _MenuHeader(),
      items: [
        PinMenuItem(
          label: '快速捕获',
          icon: PinIcons.zap,
          kbd: 'Ctrl+Shift+Space',
          onTap: () => Navigator.pushNamed(context, '/quick-capture'),
        ),
        PinMenuItem(
          label: '新建便签',
          icon: PinIcons.note,
          kbd: 'Ctrl+Alt+N',
          onTap: () => Navigator.pushNamed(context, '/note-editor'),
        ),
        PinMenuItem(
          label: '新建待办',
          icon: PinIcons.plus,
          kbd: 'Ctrl+Shift+T',
          onTap: () => Navigator.pushNamed(context, '/task-edit'),
        ),
        PinMenuItem(
          label: '显示桌面贴',
          icon: PinIcons.pin,
          kbd: 'Ctrl+Alt+D',
          onTap: () => Navigator.pushNamed(context, '/desktop-pins'),
        ),
        PinMenuItem(
          label: '打开贴记',
          icon: PinIcons.layers,
          onTap: () => Navigator.pushNamed(context, '/'),
        ),
        const PinMenuItem(label: '导出数据', icon: PinIcons.folder),
        PinMenuItem(
          label: '设置',
          icon: PinIcons.gear,
          onTap: () => Navigator.pushNamed(context, '/settings'),
        ),
        const PinMenuItem(label: '退出', icon: PinIcons.close),
      ],
    );
  }
}

/// 菜单头（应用名 + 同步状态）
class _MenuHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        children: [
          const PinLogo(size: 26),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '贴记 PinNote',
                style: spec.tsm.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  PinIcon(PinIcons.check, size: 11, color: spec.successStrong),
                  const SizedBox(width: 5),
                  Text(
                    '刚刚已同步',
                    style: TextStyle(
                      fontSize: PinFontSize.xs2,
                      color: spec.successStrong,
                      fontFamilyFallback: PinFont.sans,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
