/// 贴记 PinNote · 桌面贴位置持久化
library;

import 'dart:ui' show Offset;

import 'package:shared_preferences/shared_preferences.dart';

/// 保存桌面贴相对场景左上角的拖拽偏移（重启恢复）
class PinPositionStore {
  PinPositionStore._();

  static Future<Offset> load(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return Offset(
        prefs.getDouble('pin.offset.$id.x') ?? 0,
        prefs.getDouble('pin.offset.$id.y') ?? 0,
      );
    } catch (_) {
      return Offset.zero; // 测试环境无插件实现
    }
  }

  static Future<void> save(String id, Offset offset) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('pin.offset.$id.x', offset.dx);
      await prefs.setDouble('pin.offset.$id.y', offset.dy);
    } catch (_) {
      // 测试环境无插件实现：跳过
    }
  }
}
