/// 贴记 PinNote · 桌面场景（对应 app.css .scene / .wp-* / .taskbar）
///
/// 用于桌面贴总览 / 桌面贴控制 / 快速捕获 / 托盘与通知四张场景屏：
/// 深色壁纸 + Windows 任务栏。
library;

import 'dart:ui';

import 'package:flutter/material.dart';

import '../design/icons.dart';
import '../design/tokens.dart';

/// 壁纸场景容器：[variant] 取 kWallpapers 的 a/b/c/d
class WallpaperScene extends StatelessWidget {
  const WallpaperScene({
    required this.variant,
    required this.child,
    this.dim = false,
    super.key,
  });

  final String variant;
  final Widget child;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final wp = kWallpapers[variant]!;
    return Container(
      foregroundDecoration: dim
          ? const BoxDecoration(color: Color(0x6B080C16)) // rgba(8,12,22,.42)
          : null,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: wp.base,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          final scale = size.shortestSide;
          return Stack(
            fit: StackFit.expand,
            children: [
              for (final (gx, gy, r, color, stop) in wp.glow)
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(gx * 2 - 1, gy * 2 - 1),
                      radius: r / scale,
                      colors: [color, color.withValues(alpha: 0)],
                      stops: [0, stop],
                    ),
                  ),
                ),
              child,
            ],
          );
        },
      ),
    );
  }
}

/// Windows 任务栏（对应 .taskbar）
class PinTaskbar extends StatelessWidget {
  const PinTaskbar({this.activeAppIndex, this.trayPinOn = false, super.key});

  final int? activeAppIndex;
  final bool trayPinOn;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            height: PinSize.taskbar,
            decoration: const BoxDecoration(
              color: Color(0xD10E121A), // rgba(14,18,26,.82)
              border: Border(
                top: BorderSide(color: Color(0x14FFFFFF)), // white .08
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _TaskbarStart(),
                    _SearchPill(),
                    const SizedBox(width: 6),
                    for (var i = 0; i < kTaskbarApps.length; i++)
                      _TaskbarApp(
                        color: kTaskbarApps[i].$1,
                        icon: _appIcon(kTaskbarApps[i].$2),
                        active: i == activeAppIndex,
                      ),
                  ],
                ),
                Positioned(
                  right: 14,
                  child: Row(
                    children: [
                      _TrayPin(on: trayPinOn),
                      const SizedBox(width: 13),
                      const PinIcon(
                        PinIcons.chevronUp,
                        color: Color(0xFFD0D6E0),
                      ),
                      const SizedBox(width: 13),
                      const PinIcon(PinIcons.wifi, color: Color(0xFFD0D6E0)),
                      const SizedBox(width: 13),
                      const PinIcon(PinIcons.volume, color: Color(0xFFD0D6E0)),
                      const SizedBox(width: 13),
                      const PinIcon(PinIcons.battery, color: Color(0xFFD0D6E0)),
                      const SizedBox(width: 13),
                      const _Clock(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PinIconData _appIcon(String name) {
    switch (name) {
      case 'folder':
        return PinIcons.folder;
      case 'note':
        return PinIcons.note;
      case 'check':
        return PinIcons.check;
      case 'image':
        return PinIcons.image;
      case 'person':
        return PinIcons.person;
      default:
        return PinIcons.gear;
    }
  }
}

class _TaskbarStart extends StatelessWidget {
  const _TaskbarStart();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 34,
      height: 32,
      child: Center(
        child: PinIcon(PinIcons.start, size: 16, color: Color(0xFF55A0FF)),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: PinSpace.s3),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF), // white .10
        borderRadius: BorderRadius.circular(PinRadius.full),
      ),
      child: Row(
        children: [
          const PinIcon(PinIcons.search, size: 13, color: Color(0xD9C8CFDA)),
          const SizedBox(width: 8),
          Text(
            '搜索',
            style: TextStyle(
              fontSize: PinFontSize.xs2,
              color: const Color(0xD9C8CFDA).withValues(alpha: 0.85),
              fontFamilyFallback: PinFont.sans,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskbarApp extends StatelessWidget {
  const _TaskbarApp({
    required this.color,
    required this.icon,
    this.active = false,
  });

  final Color color;
  final PinIconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(PinRadius.sm),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PinIcon(icon, size: 13, color: Colors.white),
          if (active)
            Positioned(
              bottom: 3,
              child: Container(
                width: 14,
                height: 3,
                decoration: BoxDecoration(
                  color: const Color(0xFF81A7FF),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TrayPin extends StatelessWidget {
  const _TrayPin({required this.on});

  final bool on;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Center(
            child: PinIcon(PinIcons.pin, size: 16, color: Color(0xFFD0D6E0)),
          ),
          if (on) const Positioned(top: -3, right: -4, child: _TrayPinDot()),
        ],
      ),
    );
  }
}

class _TrayPinDot extends StatelessWidget {
  const _TrayPinDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 5,
      height: 5,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF7EA6FF),
      ),
    );
  }
}

class _Clock extends StatelessWidget {
  const _Clock();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '17:05',
          style: TextStyle(
            fontSize: 11.5,
            height: 1.35,
            color: Color(0xFFD0D6E0),
            fontFamilyFallback: PinFont.sans,
          ),
        ),
        Text(
          '2026/11/9',
          style: TextStyle(
            fontSize: 11,
            height: 1.35,
            color: Color(0xB8D2D8E2), // rgba(210,216,226,.72)
            fontFamilyFallback: PinFont.sans,
          ),
        ),
      ],
    );
  }
}
