import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlowingBackground extends StatefulWidget {
  final Widget child;

  const GlowingBackground({
    super.key,
    required this.child,
  });

  @override
  State<GlowingBackground> createState() => _GlowingBackgroundState();
}

class _GlowingBackgroundState extends State<GlowingBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid dark base
        Positioned.fill(
          child: Container(
            color: const Color(0xFF131313),
          ),
        ),
        // Animated Orbs
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: _AuroraPainter(progress: _controller.value),
              );
            },
          ),
        ),
        // Glass Overlay to soften and blend everything
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.15),
              backgroundBlendMode: BlendMode.dstATop,
            ),
          ),
        ),
        // Content
        Positioned.fill(
          child: widget.child,
        ),
      ],
    );
  }
}

class _AuroraPainter extends CustomPainter {
  final double progress;

  _AuroraPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..maskFilter = const MaskFilter.blur(BlurStyle.normal, 90);

    // Orb 1: Stitch Primary Blue
    final double angle1 = progress * 2 * math.pi;
    final double orb1X = size.width * 0.3 + math.sin(angle1) * size.width * 0.15;
    final double orb1Y = size.height * 0.25 + math.cos(angle1) * size.height * 0.1;
    final double orb1Radius = math.min(size.width, size.height) * 0.55;
    
    paint.shader = RadialGradient(
      colors: [
        const Color(0xFF3E82F7).withValues(alpha: 0.35),
        const Color(0xFF3E82F7).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb1X, orb1Y), radius: orb1Radius));
    canvas.drawCircle(Offset(orb1X, orb1Y), orb1Radius, paint);

    // Orb 2: Stitch Secondary Light Blue
    final double angle2 = (progress + 0.33) * 2 * math.pi;
    final double orb2X = size.width * 0.7 + math.cos(angle2) * size.width * 0.2;
    final double orb2Y = size.height * 0.65 + math.sin(angle2) * size.height * 0.15;
    final double orb2Radius = math.min(size.width, size.height) * 0.5;

    paint.shader = RadialGradient(
      colors: [
        const Color(0xFFA7C8FF).withValues(alpha: 0.3),
        const Color(0xFFA7C8FF).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb2X, orb2Y), radius: orb2Radius));
    canvas.drawCircle(Offset(orb2X, orb2Y), orb2Radius, paint);

    // Orb 3: Stitch Tertiary Magenta
    final double angle3 = (progress + 0.66) * 2 * math.pi;
    final double orb3X = size.width * 0.45 + math.sin(angle3) * size.width * 0.25;
    final double orb3Y = size.height * 0.8 + math.cos(angle3) * size.height * 0.1;
    final double orb3Radius = math.min(size.width, size.height) * 0.6;

    paint.shader = RadialGradient(
      colors: [
        const Color(0xFFFF4B7D).withValues(alpha: 0.25),
        const Color(0xFFFF4B7D).withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromCircle(center: Offset(orb3X, orb3Y), radius: orb3Radius));
    canvas.drawCircle(Offset(orb3X, orb3Y), orb3Radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
