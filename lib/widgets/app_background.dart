// ignore_for_file: deprecated_member_use
import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppBackground extends StatefulWidget {
  final Widget child;
  const AppBackground({super.key, required this.child});

  @override
  State<AppBackground> createState() => _AppBackgroundState();
}

class _AppBackgroundState extends State<AppBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _bgController,
          builder: (_, __) {
            final t = _bgController.value;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-0.8 + 0.6 * t, -1),
                  end: Alignment(1, 0.8 - 0.6 * t),
                  colors: [
                    const Color(0xFF0B1023),
                    Color.lerp(
                      const Color(0xFF1D1F33),
                      const Color(0xFF0C1233),
                      t,
                    )!,
                    Color.lerp(
                      const Color(0xFF24105E),
                      const Color(0xFF0A0E24),
                      1 - t,
                    )!,
                  ],
                ),
              ),
            );
          },
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) =>
                  CustomPaint(painter: _ParticlesPainter(_bgController.value)),
            ),
          ),
        ),

        Positioned.fill(child: widget.child),
      ],
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  final double progress;
  _ParticlesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()..color = Colors.white.withOpacity(0.12);
    final paint2 = Paint()..color = Colors.blueAccent.withOpacity(0.10);

    for (int i = 0; i < 18; i++) {
      final dx =
          (size.width / 18) * (i + 1) +
          (18 * math.sin(progress * 2 * math.pi + i));
      final dy =
          (size.height / 18) * (i + 1) +
          (18 * math.cos(progress * 2 * math.pi + i));
      canvas.drawCircle(Offset(dx % size.width, dy % size.height), 2.2, paint1);
    }

    for (int i = 0; i < 6; i++) {
      final dx = (size.width / 6) * i + 28 * math.sin(progress * math.pi + i);
      final dy = (size.height / 6) * i + 28 * math.cos(progress * math.pi + i);
      canvas.drawCircle(Offset(dx % size.width, dy % size.height), 3.6, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) => true;
}
