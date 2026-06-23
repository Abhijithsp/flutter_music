import 'dart:math' as math;
import 'package:flutter/material.dart';

class VisualizerWidget extends StatefulWidget {
  final bool isPlaying;
  final int barCount;
  final double height;
  final double width;
  final Color? color;

  const VisualizerWidget({
    super.key,
    required this.isPlaying,
    this.barCount = 5,
    this.height = 24,
    this.width = 32,
    this.color,
  });

  @override
  State<VisualizerWidget> createState() => _VisualizerWidgetState();
}

class _VisualizerWidgetState extends State<VisualizerWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<double> _baseHeights = [];
  final List<double> _phases = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Seed randomized values for the bars so they don't move in lockstep
    final random = math.Random();
    for (int i = 0; i < widget.barCount; i++) {
      _baseHeights.add(0.3 + random.nextDouble() * 0.6); // 30% to 90%
      _phases.add(random.nextDouble() * 2 * math.pi); // 0 to 2pi
    }

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant VisualizerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(widget.barCount, (index) {
              double multiplier = 0.25; // idle height multiplier
              if (widget.isPlaying) {
                // Calculate dynamic sine wave based on animation controller and seeded phase
                multiplier = 0.25 + 0.75 * math.sin(_controller.value * 2 * math.pi + _phases[index]).abs();
              }
              
              final barHeight = widget.height * _baseHeights[index] * multiplier;

              return Container(
                width: (widget.width - (widget.barCount - 1) * 2) / widget.barCount,
                height: math.max(2.0, barHeight),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    colors: [
                      themeColor.withValues(alpha: 0.7),
                      themeColor,
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.3),
                      blurRadius: 4,
                      offset: const Offset(0, -1),
                    ),
                  ],
                ),
              );
            }),
          );
        },
      ),
    );
  }
}
