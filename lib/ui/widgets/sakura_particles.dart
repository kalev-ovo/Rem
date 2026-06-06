import 'dart:math';
import 'package:flutter/material.dart';

/// 樱花飘落粒子背景
class SakuraParticles extends StatefulWidget {
  final Widget child;
  final int count;

  const SakuraParticles({
    super.key,
    required this.child,
    this.count = 20,
  });

  @override
  State<SakuraParticles> createState() => _SakuraParticlesState();
}

class _SakuraParticlesState extends State<SakuraParticles>
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Petal> _petals = [];
  final _random = Random();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final size = MediaQuery.of(context).size;
      for (int i = 0; i < widget.count; i++) {
        _petals.add(_Petal(
          x: _random.nextDouble() * size.width,
          y: -_random.nextDouble() * size.height,
          speed: 1.0 + _random.nextDouble() * 2.0,
          size: 6 + _random.nextDouble() * 8,
          opacity: 0.2 + _random.nextDouble() * 0.3,
          rotation: _random.nextDouble() * 2 * pi,
        ));
      }
      _initialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _SakuraPainter(_petals, _controller.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _Petal {
  double x;
  double y;
  final double speed;
  final double size;
  final double opacity;
  final double rotation;

  _Petal({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.opacity,
    required this.rotation,
  });
}

class _SakuraPainter extends CustomPainter {
  final List<_Petal> petals;
  final double progress;

  _SakuraPainter(this.petals, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final petal in petals) {
      // 更新位置
      double newY = petal.y + petal.speed * 1.5;
      double newX = petal.x + sin(progress * 2 * pi + petal.y / 50) * 0.5;
      if (newY > size.height + 20) {
        newY = -20;
        newX = Random().nextDouble() * size.width;
      }
      petal.y = newY;
      petal.x = newX;

      // 绘制花瓣（五瓣小花形状）
      paint.color = const Color(0xFFF4A7B9).withValues(alpha: petal.opacity);
      final center = Offset(petal.x, petal.y);
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(petal.rotation + progress * pi);

      // 画 5 个圆形花瓣
      for (int i = 0; i < 5; i++) {
        final angle = i * 2 * pi / 5;
        final dx = cos(angle) * petal.size * 0.5;
        final dy = sin(angle) * petal.size * 0.5;
        canvas.drawCircle(Offset(dx, dy), petal.size * 0.4, paint);
      }
      // 花蕊
      paint.color = const Color(0xFFFFD1DC).withValues(alpha: petal.opacity);
      canvas.drawCircle(Offset.zero, petal.size * 0.25, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SakuraPainter oldDelegate) => true;
}
