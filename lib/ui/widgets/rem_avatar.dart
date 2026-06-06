import 'package:flutter/material.dart';

/// 雷姆头像组件（使用应用图标素材）
class RemAvatar extends StatelessWidget {
  final double size;
  final bool showBadge;

  const RemAvatar({
    super.key,
    this.size = 40,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipOval(
            child: Image.asset(
              'assets/images/app_icon.jpeg',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: size,
                height: size,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF7EC8E3), Color(0xFFA8D8EA)],
                  ),
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
          if (showBadge)
            Positioned(
              top: -3,
              right: -4,
              child: CustomPaint(
                size: Size(size * 0.4, size * 0.35),
                painter: _HornPainter(),
              ),
            ),
        ],
      ),
    );
  }
}

class _HornPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(size.width * 0.3, size.height);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.5,
      size.width * 0.4, size.height * 0.05,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.1,
      size.width * 0.85, size.height * 0.6,
    );
    path.quadraticBezierTo(
      size.width * 0.7, size.height * 0.4,
      size.width * 0.5, size.height * 0.8,
    );
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
