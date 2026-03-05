import 'package:flutter/material.dart';

/// Painter for circular avatar markers with optional custom content
class CircularAvatarPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;
  final bool enableShadow;
  final Widget? customWidget;

  const CircularAvatarPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 2.0,
    this.enableShadow = true,
    this.customWidget,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw shadow
    if (enableShadow) {
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawCircle(
        center + const Offset(0, 3),
        radius,
        shadowPaint,
      );
    }

    // Draw border (outer ring)
    if (borderWidth > 0) {
      final borderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
      canvas.drawCircle(center, radius - borderWidth / 2, borderPaint);
    }

    // Draw fill
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - borderWidth, fillPaint);

    // If there's a custom widget, we can't draw it directly in Canvas
    // The widget should be layered on top in the widget tree
  }

  @override
  bool shouldRepaint(covariant CircularAvatarPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth ||
        oldDelegate.enableShadow != enableShadow ||
        oldDelegate.customWidget != customWidget;
  }
}
