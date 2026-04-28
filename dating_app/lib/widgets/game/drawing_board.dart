import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../pages/game/game_controller.dart';

class DrawingBoard extends GetView<GameController> {
  const DrawingBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) => controller.startStroke(details.localPosition),
      onPanUpdate: (details) => controller.appendStroke(details.localPosition),
      onPanEnd: (_) => controller.endStroke(),
      child: Obx(
        () => CustomPaint(
          painter: _BoardPainter(
            strokes: controller.strokes,
            currentStroke: controller.currentStroke,
            color: controller.brushColor.value,
            strokeWidth: controller.strokeWidth.value,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}

class _BoardPainter extends CustomPainter {
  const _BoardPainter({
    required this.strokes,
    required this.currentStroke,
    required this.color,
    required this.strokeWidth,
  });

  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = color
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;
    for (final stroke in [...strokes, currentStroke]) {
      for (var i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _BoardPainter oldDelegate) {
    return true;
  }
}
