/// 贴记 PinNote · 导航约定
///
/// 栈管理规则（P0 迭代确立，详见 docs/CODE_STANDARDS.md §3）：
/// - 主屏之间（今日/便签库/设置/托盘/编辑器等）一律 [AppNav.go] = pushReplacement，
///   栈深恒为 1；
/// - 浮层（任务编辑 / 快速捕获）用 `showTaskEditDialog` / `showQuickCaptureDialog`
///   （showGeneralDialog：Esc + 点蒙层关闭），确定/取消 = Navigator.pop；
/// - 独立展示屏（桌面贴总览等）仍走路由，但也用 [AppNav.go] 平级切换。
library;

import 'package:flutter/material.dart';

/// 当前路由名跟踪（供全局快捷键等无 context 场景判断）
class PinRouteObserver extends NavigatorObserver {
  String current = '/';

  void _setCurrent(Route<Object?>? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) current = name;
  }

  @override
  void didPush(Route<Object?> route, Route<Object?>? previousRoute) =>
      _setCurrent(route);

  @override
  void didReplace({Route<Object?>? newRoute, Route<Object?>? oldRoute}) =>
      _setCurrent(newRoute);

  @override
  void didPop(Route<Object?> route, Route<Object?>? previousRoute) =>
      _setCurrent(previousRoute);
}

class AppNav {
  AppNav._();

  static final PinRouteObserver observer = PinRouteObserver();

  /// 平级切换主屏（替换当前路由，不加深栈）；同名路由跳过
  static void go(BuildContext context, String route) {
    if (observer.current == route) return;
    Navigator.pushReplacementNamed(context, route);
  }
}
