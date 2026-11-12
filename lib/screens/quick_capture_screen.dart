/// 贴记 PinNote · 快速捕获（对应 ui/quick-capture.html）
///
/// 任意应用内唤起的全局捕获窗：自然语言识别日期 / 标签 / 优先级。
library;

import 'package:flutter/material.dart';

import '../widgets/overlays/quick_capture_card.dart';
import '../widgets/scene.dart';

class QuickCaptureScreen extends StatelessWidget {
  const QuickCaptureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cardWidth = width * 0.86 < 620 ? width * 0.86 : 620.0;

    return WallpaperScene(
      variant: 'c',
      dim: true,
      child: Stack(
        children: [
          Center(child: QuickCaptureCard(width: cardWidth)),
          const PinTaskbar(activeAppIndex: 2),
        ],
      ),
    );
  }
}
