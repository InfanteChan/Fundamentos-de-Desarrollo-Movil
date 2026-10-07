import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:pizzeria/theme/app_colors.dart';

class DashedOvenLoader extends StatefulWidget {
  final double size;

  const DashedOvenLoader({super.key, this.size = 80});

  @override
  State<DashedOvenLoader> createState() => _DashedOvenLoaderState();
}

class _DashedOvenLoaderState extends State<DashedOvenLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _DashedCirclePainter(),
            ),
          );
        },
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final radius = size.width / 2;
    final center = Offset(radius, radius);
    const dashCount = 20;
    const dashAngle = (2 * math.pi) / dashCount;
    const sweepAngle = dashAngle * 0.55;

    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 2),
        i * dashAngle,
        sweepAngle,
        false,
        paint,
      );
    }

    const dashLength = 4.0;
    const dashSpace = 4.0;
    double x = size.width * 0.25;
    final endX = size.width * 0.75;
    final y = size.height * 0.5;

    while (x < endX) {
      canvas.drawLine(
        Offset(x, y),
        Offset(math.min(x + dashLength, endX), y),
        paint,
      );
      x += dashLength + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}