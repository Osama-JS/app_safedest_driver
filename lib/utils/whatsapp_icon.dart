import 'package:flutter/material.dart';

class WhatsAppIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const WhatsAppIcon({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? Colors.green[600],
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.chat,
        size: size * 0.6,
        color: Colors.white,
      ),
    );
  }
}

// Alternative using a custom painter for more accurate WhatsApp icon
class WhatsAppIconPainter extends CustomPainter {
  final Color color;

  WhatsAppIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw WhatsApp-like icon
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    canvas.drawCircle(center, radius, paint);

    // Chat bubble
    paint.color = Colors.white;
    final bubbleRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.6,
        height: size.height * 0.5,
      ),
      Radius.circular(size.width * 0.1),
    );
    canvas.drawRRect(bubbleRect, paint);

    // Chat tail
    final path = Path();
    path.moveTo(center.dx - size.width * 0.15, center.dy + size.height * 0.15);
    path.lineTo(center.dx - size.width * 0.25, center.dy + size.height * 0.25);
    path.lineTo(center.dx - size.width * 0.05, center.dy + size.height * 0.2);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CustomWhatsAppIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const CustomWhatsAppIcon({
    super.key,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: WhatsAppIconPainter(
        color: color ?? Colors.green[600]!,
      ),
    );
  }
}
