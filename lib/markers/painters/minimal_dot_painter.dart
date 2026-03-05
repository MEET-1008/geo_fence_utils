import 'package:flutter/material.dart';

/// Painter for minimal dot markers (simple filled circles, no shadow)
class MinimalDotPainter extends CustomPainter {
  final Color color;

  const MinimalDotPainter({
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Simple filled circle
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant MinimalDotPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
