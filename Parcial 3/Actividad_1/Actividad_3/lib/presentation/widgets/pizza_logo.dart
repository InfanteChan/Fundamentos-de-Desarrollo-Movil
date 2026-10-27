import 'package:flutter/material.dart';
import 'package:pizzeria/theme/app_colors.dart';

class PizzaLogo extends StatelessWidget {
  final double size;

  const PizzaLogo({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _PizzaSlicePainter(),
        ),
      ),
    );
  }
}

class _PizzaSlicePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paintDot = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035;

    final path = Path()
      ..moveTo(size.width * 0.1, size.height * 0.15)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.05,
        size.width * 0.9,
        size.height * 0.15,
      )
      ..lineTo(size.width * 0.5, size.height * 0.95)
      ..close();
    canvas.drawPath(path, paintLine);

    final crustPath = Path()
      ..moveTo(size.width * 0.15, size.height * 0.23)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.15,
        size.width * 0.85,
        size.height * 0.23,
      );
    canvas.drawPath(crustPath, paintLine);

    final dots = [
      Offset(size.width * 0.4, size.height * 0.38),
      Offset(size.width * 0.62, size.height * 0.42),
      Offset(size.width * 0.48, size.height * 0.56),
      Offset(size.width * 0.35, size.height * 0.68),
      Offset(size.width * 0.58, size.height * 0.72),
    ];
    for (final dot in dots) {
      canvas.drawCircle(dot, size.width * 0.065, paintDot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}