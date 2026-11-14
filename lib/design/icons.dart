/// 贴记 PinNote · 图标库
///
/// `ui/icons.svg`（Fluent 线性 1.75px · 16/20/24）的 Flutter 实现。
/// 通过内嵌的迷你 SVG path 解析器逐字复制设计稿的 path 数据，保证形状一致；
/// 颜色语义与 `currentColor` 一致：描边 / 填充取 [PinIcon.color]。
library;

import 'package:flutter/material.dart';

import 'theme.dart';

/// 迷你 SVG path 解析器：支持 M L H V C S A Z 及小写相对、隐式重复。
/// 设计稿图标未使用 Q/T；遇到未支持的命令直接抛错（测试兜底）。
void _applySvgPath(Path path, String d) {
  double x = 0, y = 0;
  double sx = 0, sy = 0;
  double lastCtrlX = 0, lastCtrlY = 0;
  bool hasLastCtrl = false;

  final nums = <double>[];
  String cmd = '';

  void flush() {
    var i = 0;
    while (i < nums.length) {
      switch (cmd) {
        case 'M':
        case 'm':
          final abs = cmd == 'M';
          x = abs ? nums[i] : x + nums[i];
          y = abs ? nums[i + 1] : y + nums[i + 1];
          path.moveTo(x, y);
          sx = x;
          sy = y;
          i += 2;
          cmd = abs ? 'L' : 'l'; // M 后隐式 L
          hasLastCtrl = false;
        case 'L':
        case 'l':
          final abs = cmd == 'L';
          x = abs ? nums[i] : x + nums[i];
          y = abs ? nums[i + 1] : y + nums[i + 1];
          path.lineTo(x, y);
          i += 2;
          hasLastCtrl = false;
        case 'H':
        case 'h':
          x = cmd == 'H' ? nums[i] : x + nums[i];
          path.lineTo(x, y);
          i += 1;
          hasLastCtrl = false;
        case 'V':
        case 'v':
          y = cmd == 'V' ? nums[i] : y + nums[i];
          path.lineTo(x, y);
          i += 1;
          hasLastCtrl = false;
        case 'C':
        case 'c':
          final abs = cmd == 'C';
          final c1x = abs ? nums[i] : x + nums[i];
          final c1y = abs ? nums[i + 1] : y + nums[i + 1];
          final c2x = abs ? nums[i + 2] : x + nums[i + 2];
          final c2y = abs ? nums[i + 3] : y + nums[i + 3];
          final ex = abs ? nums[i + 4] : x + nums[i + 4];
          final ey = abs ? nums[i + 5] : y + nums[i + 5];
          path.cubicTo(c1x, c1y, c2x, c2y, ex, ey);
          lastCtrlX = c2x;
          lastCtrlY = c2y;
          hasLastCtrl = true;
          x = ex;
          y = ey;
          i += 6;
        case 'S':
        case 's':
          final abs = cmd == 'S';
          final c1x = hasLastCtrl ? 2 * x - lastCtrlX : x;
          final c1y = hasLastCtrl ? 2 * y - lastCtrlY : y;
          final c2x = abs ? nums[i] : x + nums[i];
          final c2y = abs ? nums[i + 1] : y + nums[i + 1];
          final ex = abs ? nums[i + 2] : x + nums[i + 2];
          final ey = abs ? nums[i + 3] : y + nums[i + 3];
          path.cubicTo(c1x, c1y, c2x, c2y, ex, ey);
          lastCtrlX = c2x;
          lastCtrlY = c2y;
          hasLastCtrl = true;
          x = ex;
          y = ey;
          i += 4;
        case 'A':
        case 'a':
          final abs = cmd == 'A';
          final rx = nums[i];
          final ry = nums[i + 1];
          final rot = nums[i + 2];
          final largeArc = nums[i + 3] == 1;
          final sweep = nums[i + 4] == 1;
          final ex = abs ? nums[i + 5] : x + nums[i + 5];
          final ey = abs ? nums[i + 6] : y + nums[i + 6];
          assert(rx == ry, '设计稿图标只使用圆形弧线');
          path.arcToPoint(
            Offset(ex, ey),
            radius: Radius.circular(rx),
            rotation: rot,
            largeArc: largeArc,
            clockwise: sweep,
          );
          x = ex;
          y = ey;
          i += 7;
          hasLastCtrl = false;
        case 'Z':
        case 'z':
          path.close();
          x = sx;
          y = sy;
          return;
        default:
          throw ArgumentError('不支持的 SVG path 命令: $cmd');
      }
    }
  }

  final tokenRe = RegExp(
    r'([MLHVCSAZmlhvcsaz])|([-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?)',
  );
  for (final m in tokenRe.allMatches(d)) {
    final letter = m.group(1);
    if (letter != null) {
      flush();
      nums.clear();
      cmd = letter;
      continue;
    }
    nums.add(double.parse(m.group(2)!));
  }
  flush();
}

/// 单个绘制指令（对应 `<symbol>` 内的 path / circle / rect）
sealed class _IconOp {
  const _IconOp();
}

class _StrokePath extends _IconOp {
  const _StrokePath(this.d, [this.width = 1.75]);
  final String d;
  final double width;
}

class _FillPath extends _IconOp {
  const _FillPath(this.d) : useSurface = false;
  final String d;
  final bool useSurface; // 填充用“面板底色”（如 layers 前层方块）
}

class _StrokeCircle extends _IconOp {
  const _StrokeCircle(this.cx, this.cy, this.r) : width = 1.75;
  final double cx, cy, r, width;
}

class _FillCircle extends _IconOp {
  const _FillCircle(
    this.cx,
    this.cy,
    this.r, {
    this.white = false,
    this.opacity = 1,
  });
  final double cx, cy, r;
  final bool white; // 高光点固定白色（如 tack）
  final double opacity;
}

class _StrokeRect extends _IconOp {
  const _StrokeRect(this.x, this.y, this.w, this.h, [this.rad = 0])
    : width = 1.75;
  final double x, y, w, h, rad, width;
}

class _FillRect extends _IconOp {
  const _FillRect(
    this.x,
    this.y,
    this.w,
    this.h, [
    this.rad = 0,
    this.useSurface = false,
  ]);
  final double x, y, w, h, rad;
  final bool useSurface;
}

/// 图标数据：名字 + 绘制指令列表（24×24 viewBox）
@immutable
class PinIconData {
  const PinIconData._(this.name, this._ops);

  final String name;
  final List<_IconOp> _ops;
}

/// 全部图标（与 ui/icons.svg 的 symbol 一一对应）
abstract final class PinIcons {
  static const plus = PinIconData._('plus', [_StrokePath('M12 5v14M5 12h14')]);
  static const minus = PinIconData._('minus', [_StrokePath('M5 12h14')]);
  static const close = PinIconData._('close', [
    _StrokePath('M6 6l12 12M18 6 6 18'),
  ]);
  static const check = PinIconData._('check', [
    _StrokePath('M5 12.6l4.4 4.4L19 7.4', 1.9),
  ]);
  static const chevronDown = PinIconData._('chevron-down', [
    _StrokePath('M6 9.5l6 6 6-6'),
  ]);
  static const chevronUp = PinIconData._('chevron-up', [
    _StrokePath('M6 14.5l6-6 6 6'),
  ]);
  static const chevronRight = PinIconData._('chevron-right', [
    _StrokePath('M9.5 6l6 6-6 6'),
  ]);
  static const chevronLeft = PinIconData._('chevron-left', [
    _StrokePath('M14.5 6l-6 6 6 6'),
  ]);
  static const search = PinIconData._('search', [
    _StrokeCircle(11, 11, 6),
    _StrokePath('M15.6 15.6 20 20'),
  ]);
  static const calendar = PinIconData._('calendar', [
    _StrokeRect(4, 5.5, 16, 14.5, 2.5),
    _StrokePath(
      'M4 10.5h16M8.5 3.5v3M15.5 3.5v3'
      'M8 14h.01M12 14h.01M16 14h.01M8 17h.01M12 17h.01',
    ),
  ]);
  static const clock = PinIconData._('clock', [
    _StrokeCircle(12, 12, 7.5),
    _StrokePath('M12 7.5V12l3 2'),
  ]);
  static const bell = PinIconData._('bell', [
    _StrokePath('M5.5 15.5v-4a6.5 6.5 0 0 1 13 0v4l1.7 2.7H3.8z'),
    _StrokePath('M10.2 20.5a2 2 0 0 0 3.6 0'),
  ]);
  static const flag = PinIconData._('flag', [
    _StrokePath('M6.5 4.5v15'),
    _FillPath(
      'M6.5 5.5c2.2-1.3 4.3-1.3 6.5 0'
      's4.3 1.3 5.5.4v6.8c-1.2.9-3.3.9-5.5-.4s-4.3-1.3-6.5 0z',
    ),
  ]);
  static const tag = PinIconData._('tag', [
    _StrokePath('M4.5 5.5h6.6L19.5 12l-8.4 6.5H4.5z'),
    _StrokeCircle(8, 12, 1.3),
  ]);
  static const pin = PinIconData._('pin', [
    _StrokeCircle(12, 7.6, 3.4),
    _StrokePath('M12 11v9'),
  ]);
  static const tack = PinIconData._('tack', [
    _FillCircle(12, 8, 4.2),
    _FillCircle(10.8, 6.8, 1.1, white: true, opacity: 0.8),
    _StrokePath('M12 12.2v8.3'),
  ]);
  static const layers = PinIconData._('layers', [
    _StrokeRect(4.5, 4.5, 10.5, 10.5, 2.4),
    _FillRect(9, 9, 10.5, 10.5, 2.4, true),
  ]);
  static const note = PinIconData._('note', [
    _StrokeRect(4.5, 4.5, 15, 15, 2.5),
    _StrokePath('M13.5 19.5v-5h5'),
  ]);
  static const gear = PinIconData._('gear', [
    _StrokeCircle(12, 12, 3),
    _StrokePath(
      'M12 4v2.4M12 17.6V20M4 12h2.4M17.6 12H20'
      'M6.3 6.3 8 8M16 16l1.7 1.7M17.7 6.3 16 8M8 16l-1.7 1.7',
    ),
  ]);
  static const theme = PinIconData._('theme', [
    _StrokeCircle(12, 12, 7.5),
    _FillPath('M12 4.5a7.5 7.5 0 0 1 0 15z'),
  ]);
  static const sync = PinIconData._('sync', [
    _StrokePath(
      'M5.2 12a6.8 6.8 0 0 1 11.6-4.8M18.8 12a6.8 6.8 0 0 1-11.6 4.8',
    ),
    _StrokePath('M17 3.6v3.8h-3.8M7 20.4v-3.8h3.8'),
  ]);
  static const repeat = PinIcons.sync;
  static const trash = PinIconData._('trash', [
    _StrokePath(
      'M5 7h14M9.5 7V5h5v2M7 7l.9 13h8.2L17 7M10.5 10.5v6M13.5 10.5v6',
    ),
  ]);
  static const more = PinIconData._('more', [
    _StrokePath('M7 12h.01M12 12h.01M17 12h.01', 2.6),
  ]);
  static const palette = PinIconData._('palette', [
    _StrokeCircle(12, 12, 7.5),
    _StrokePath(
      'M8.4 9.6h.01M12.3 8.2h.01M15 11h.01M11 14.6h.01M8 13.4h.01',
      2.4,
    ),
  ]);
  static const opacity = PinIconData._('opacity', [
    _StrokeCircle(12, 12, 7),
    _FillPath('M12 5a7 7 0 0 1 0 14z'),
  ]);
  static const image = PinIconData._('image', [
    _StrokeRect(4, 5.5, 16, 13, 2.5),
    _StrokeCircle(9, 10, 1.4),
    _StrokePath('M5.5 16.5 10 12l3 3 2.5-2.5 3 4'),
  ]);
  static const enter = PinIconData._('enter', [
    _StrokePath('M18.5 6v5a3 3 0 0 1-3 3H6'),
    _StrokePath('M9 10.5 5.5 14 9 17.5'),
  ]);
  static const start = PinIconData._('start', [
    _FillPath(
      'M5.5 5.5h5.4v5.4H5.5zM13.1 5.5h5.4v5.4h-5.4z'
      'M5.5 13.1h5.4v5.4H5.5zM13.1 13.1h5.4v5.4h-5.4z',
    ),
  ]);
  static const wifi = PinIconData._('wifi', [
    _StrokePath('M5 11.8a10 10 0 0 1 14 0M8 14.4a6.3 6.3 0 0 1 8 0'),
    _StrokePath('M12 18h.01', 2.4),
  ]);
  static const volume = PinIconData._('volume', [
    _FillPath('M4.5 9.8v4.4h3l4 3.4V6.4l-4 3.4z'),
    _StrokePath('M15 9.3a4.2 4.2 0 0 1 0 5.4M17.6 7a8 8 0 0 1 0 10'),
  ]);
  static const battery = PinIconData._('battery', [
    _StrokeRect(3.5, 8.5, 15, 7, 2),
    _StrokePath('M21 11v2'),
    _FillRect(5.5, 10.5, 8, 3, 1),
  ]);
  static const gridView = PinIconData._('grid-view', [
    _StrokeRect(4.5, 4.5, 6.2, 6.2, 1.8),
    _StrokeRect(13.3, 4.5, 6.2, 6.2, 1.8),
    _StrokeRect(4.5, 13.3, 6.2, 6.2, 1.8),
    _StrokeRect(13.3, 13.3, 6.2, 6.2, 1.8),
  ]);
  static const listView = PinIconData._('list-view', [
    _StrokeRect(4.5, 5.5, 15, 3.6, 1.8),
    _StrokeRect(4.5, 10.2, 15, 3.6, 1.8),
    _StrokeRect(4.5, 14.9, 15, 3.6, 1.8),
  ]);
  static const highlight = PinIconData._('highlight', [
    _StrokePath('M5 19.5l.9-3.8L15.2 6.4l3.4 3.4-9.3 9.3z'),
    _StrokePath('M13.4 8.2l3 3'),
  ]);
  static const listCheck = PinIconData._('list-check', [
    _StrokePath('M4.5 7.2l1.9 1.9 3.1-3.3'),
    _StrokePath('M12.5 7.5h7M12.5 13h7M12.5 18h7'),
  ]);
  static const listBullet = PinIconData._('list-bullet', [
    _StrokePath('M5.5 7h.01M5.5 12h.01M5.5 17h.01', 2.6),
    _StrokePath('M10 7h9.5M10 12h9.5M10 17h9.5'),
  ]);
  static const lock = PinIconData._('lock', [
    _StrokeRect(6, 10.5, 12, 9, 2.2),
    _StrokePath('M8.8 10.5V8.2a3.2 3.2 0 0 1 6.4 0v2.3M12 14.5v1.8'),
  ]);
  static const zap = PinIconData._('zap', [
    _FillPath('M13.2 3.5 5.8 13.6h5l-1 6.9 7.4-10.1h-5z'),
  ]);
  static const folder = PinIconData._('folder', [
    _StrokePath('M4 6.5h5.5l1.5 2H20v10H4z'),
  ]);
  static const person = PinIconData._('person', [
    _StrokeCircle(12, 8.6, 3.1),
    _StrokePath('M6.2 19.5a5.8 5.8 0 0 1 11.6 0'),
  ]);
  static const keyboard = PinIconData._('keyboard', [
    _StrokeRect(3.5, 7, 17, 10.5, 2),
    _StrokePath(
      'M7 10.5h.01M10.3 10.5h.01M13.6 10.5h.01M16.9 10.5h.01M8.5 14h7',
    ),
  ]);
  static const info = PinIconData._('info', [
    _StrokeCircle(12, 12, 7.5),
    _StrokePath('M12 11v5M12 8h.01', 2),
  ]);
  static const drag = PinIconData._('drag', [
    _StrokePath(
      'M8 6.5h.01M8 12h.01M8 17.5h.01'
      'M16 6.5h.01M16 12h.01M16 17.5h.01',
      2.6,
    ),
  ]);
}

/// 按名称反查图标（持久化序列化用）
PinIconData? pinIconByName(String name) => _iconByName[name];

const Map<String, PinIconData> _iconByName = {
  'plus': PinIcons.plus,
  'minus': PinIcons.minus,
  'close': PinIcons.close,
  'check': PinIcons.check,
  'chevronDown': PinIcons.chevronDown,
  'chevronUp': PinIcons.chevronUp,
  'chevronRight': PinIcons.chevronRight,
  'chevronLeft': PinIcons.chevronLeft,
  'search': PinIcons.search,
  'calendar': PinIcons.calendar,
  'clock': PinIcons.clock,
  'bell': PinIcons.bell,
  'flag': PinIcons.flag,
  'tag': PinIcons.tag,
  'pin': PinIcons.pin,
  'tack': PinIcons.tack,
  'layers': PinIcons.layers,
  'note': PinIcons.note,
  'gear': PinIcons.gear,
  'theme': PinIcons.theme,
  'sync': PinIcons.sync,
  'trash': PinIcons.trash,
  'more': PinIcons.more,
  'palette': PinIcons.palette,
  'opacity': PinIcons.opacity,
  'image': PinIcons.image,
  'enter': PinIcons.enter,
  'start': PinIcons.start,
  'wifi': PinIcons.wifi,
  'volume': PinIcons.volume,
  'battery': PinIcons.battery,
  'gridView': PinIcons.gridView,
  'listView': PinIcons.listView,
  'highlight': PinIcons.highlight,
  'listCheck': PinIcons.listCheck,
  'listBullet': PinIcons.listBullet,
  'lock': PinIcons.lock,
  'zap': PinIcons.zap,
  'folder': PinIcons.folder,
  'person': PinIcons.person,
  'keyboard': PinIcons.keyboard,
  'info': PinIcons.info,
  'drag': PinIcons.drag,
};

/// 图标绘制器：把 24×24 viewBox 缩放到 [PinIcon.size]
class _IconPainter extends CustomPainter {
  _IconPainter(this.data, this.color, this.surfaceColor);

  final PinIconData data;
  final Color color;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fill = Paint()..style = PaintingStyle.fill;

    for (final op in data._ops) {
      switch (op) {
        case _StrokePath():
          final path = Path().._apply(op.d);
          canvas.drawPath(
            path,
            stroke
              ..color = color
              ..strokeWidth = op.width,
          );
        case _FillPath():
          final path = Path().._apply(op.d);
          canvas.drawPath(
            path,
            fill..color = op.useSurface ? surfaceColor : color,
          );
        case _StrokeCircle():
          canvas.drawCircle(
            Offset(op.cx, op.cy),
            op.r,
            stroke
              ..color = color
              ..strokeWidth = op.width,
          );
        case _FillCircle():
          final c = op.white
              ? Color.fromRGBO(255, 255, 255, op.opacity)
              : color.withValues(alpha: color.a * op.opacity);
          canvas.drawCircle(Offset(op.cx, op.cy), op.r, fill..color = c);
        case _StrokeRect():
          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTWH(op.x, op.y, op.w, op.h),
            Radius.circular(op.rad),
          );
          canvas.drawRRect(
            rrect,
            stroke
              ..color = color
              ..strokeWidth = op.width,
          );
        case _FillRect():
          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTWH(op.x, op.y, op.w, op.h),
            Radius.circular(op.rad),
          );
          canvas.drawRRect(
            rrect,
            fill..color = op.useSurface ? surfaceColor : color,
          );
      }
    }
  }

  @override
  bool shouldRepaint(_IconPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.color != color ||
      oldDelegate.surfaceColor != surfaceColor;
}

extension on Path {
  void _apply(String d) => _applySvgPath(this, d);
}

/// 设计稿图标组件。
///
/// 默认颜色取 IconTheme（MaterialApp 中已按主题设为二级文本色），
/// [surfaceColor] 供需要“挖底”的图标（layers）使用。
class PinIcon extends StatelessWidget {
  const PinIcon(
    this.data, {
    super.key,
    this.size = 16,
    this.color,
    this.surfaceColor,
  });

  final PinIconData data;
  final double size;
  final Color? color;
  final Color? surfaceColor;

  @override
  Widget build(BuildContext context) {
    final spec = context.pin;
    final c = color ?? IconTheme.of(context).color ?? spec.text2;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _IconPainter(
          data,
          c,
          surfaceColor ?? context.surfaceColorOf(),
        ),
      ),
    );
  }
}
