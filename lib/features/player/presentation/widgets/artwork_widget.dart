import 'dart:io';
import 'dart:math' as math;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

class ArtworkWidget extends StatefulWidget {
  final MediaItem? track;
  final bool isPlaying;
  final double size;

  const ArtworkWidget({
    super.key,
    required this.track,
    required this.isPlaying,
    this.size = 280,
  });

  @override
  State<ArtworkWidget> createState() => _ArtworkWidgetState();
}

class _ArtworkWidgetState extends State<ArtworkWidget> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    );

    if (widget.isPlaying) {
      _rotationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ArtworkWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _rotationController.repeat();
      } else {
        _rotationController.stop();
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  // Generates a beautiful deterministic neon gradient based on the song title hash
  List<Color> _getDeterministicColors(String title) {
    final int hash = title.hashCode;
    
    // 6 premium color palettes for 2026
    final List<List<Color>> palettes = [
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)], // Violet -> Pink
      [const Color(0xFF3B82F6), const Color(0xFF06B6D4)], // Blue -> Cyan
      [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald -> Teal
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Amber -> Red
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // Indigo -> Purple
      [const Color(0xFFEC4899), const Color(0xFFF43F5E)], // Rose -> Red
    ];

    final index = hash.abs() % palettes.length;
    return palettes[index];
  }

  Widget _buildArtworkContent() {
    final trackTitle = widget.track?.title ?? 'Octave';
    final colors = _getDeterministicColors(trackTitle);
    
    final uriString = widget.track?.artUri?.toString();
    
    if (uriString != null && uriString.isNotEmpty) {
      try {
        if (uriString.startsWith('http')) {
          return Image.network(
            uriString,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(colors, trackTitle),
          );
        } else {
          // Local file path
          final file = File(Uri.parse(uriString).toFilePath());
          if (file.existsSync()) {
            return Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildPlaceholder(colors, trackTitle),
            );
          }
        }
      } catch (_) {
        // Fall through to placeholder
      }
    }

    return _buildPlaceholder(colors, trackTitle);
  }

  Widget _buildPlaceholder(List<Color> colors, String title) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Subtle tech circles in background
          Opacity(
            opacity: 0.15,
            child: CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _TechCirclesPainter(),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note_rounded,
                size: widget.size * 0.25,
                color: Colors.white.withValues(alpha: 0.9),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  title.substring(0, math.min(title.length, 1)).toUpperCase(),
                  style: TextStyle(
                    fontSize: widget.size * 0.15,
                    fontWeight: FontWeight.w900,
                    color: Colors.white.withValues(alpha: 0.8),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackTitle = widget.track?.title ?? 'Octave';
    final colors = _getDeterministicColors(trackTitle);
    final glowColor = colors[0];

    return Center(
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dynamic Glowing Shadow behind the cover art
          Container(
            height: widget.size * 0.95,
            width: widget.size * 0.95,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: glowColor.withValues(alpha: widget.isPlaying ? 0.45 : 0.25),
                  blurRadius: widget.isPlaying ? 45 : 30,
                  spreadRadius: widget.isPlaying ? 8 : 2,
                ),
              ],
            ),
          ),
          
          // Rotating Outer Halo Ring
          RotationTransition(
            turns: _rotationController,
            child: Container(
              height: widget.size + 14,
              width: widget.size + 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.08),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: widget.size / 2 + 7 - 4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: glowColor,
                        boxShadow: [
                          BoxShadow(
                            color: glowColor,
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Artwork Container (Circular for Vinyl aesthetic, rounded card for sleekness - Vinyl looks more tactile!)
          Container(
            height: widget.size,
            width: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 3.0,
              ),
            ),
            child: ClipOval(
              child: _buildArtworkContent(),
            ),
          ),

          // Center spindle hole for Vinyl Record aesthetic (tactile detail)
          Container(
            height: 18,
            width: 18,
            decoration: const BoxDecoration(
              color: Color(0xFF08090E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 4,
                  spreadRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Center(
              child: Container(
                height: 6,
                width: 6,
                decoration: const BoxDecoration(
                  color: Colors.white38,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TechCirclesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width / 2, size.height / 2);
    
    // Draw concentric dashed circles
    canvas.drawCircle(center, size.width * 0.4, paint);
    
    paint.strokeWidth = 0.5;
    canvas.drawCircle(center, size.width * 0.3, paint);
    canvas.drawCircle(center, size.width * 0.2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
