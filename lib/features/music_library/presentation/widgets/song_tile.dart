import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/widgets/visualizer_widget.dart';
import '../../domain/entities/song.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final VoidCallback onTap;
  final bool isActive;
  final bool isPlaying;

  const SongTile({
    super.key,
    required this.song,
    required this.onTap,
    this.isActive = false,
    this.isPlaying = false,
  });

  // Generates a beautiful deterministic neon gradient based on the song title hash
  List<Color> _getDeterministicColors(String title) {
    final int hash = title.hashCode;
    final List<List<Color>> palettes = [
      [const Color(0xFF3E82F7), const Color(0xFFA7C8FF)], // Stitch Primary -> Secondary
      [const Color(0xFF8B5CF6), const Color(0xFFFF4B7D)], // Violet -> Magenta
      [const Color(0xFF00B4D8), const Color(0xFF90E0EF)], // Cyan
      [const Color(0xFFFF4B7D), const Color(0xFFFF85A2)], // Pink
      [const Color(0xFF3E82F7), const Color(0xFFFF4B7D)], // Blue -> Magenta
    ];
    final index = hash.abs() % palettes.length;
    return palettes[index];
  }

  Widget _buildArtwork(BuildContext context, ColorScheme colors) {
    final gradColors = _getDeterministicColors(song.title);
    
    Widget imageContent = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          song.title.substring(0, math.min(song.title.length, 1)).toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );

    if (song.uri.isNotEmpty) {
      try {
        if (song.uri.startsWith('http')) {
          imageContent = Image.network(
            song.uri,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => imageContent,
          );
        } else {
          final file = File(Uri.parse(song.uri).toFilePath());
          if (file.existsSync()) {
            imageContent = Image.file(
              file,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => imageContent,
            );
          }
        }
      } catch (_) {}
    }

    return Container(
      height: 56,
      width: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(child: imageContent),
            if (isActive)
              Container(
                color: colors.primary.withValues(alpha: 0.2),
                child: Center(
                  child: VisualizerWidget(
                    isPlaying: isPlaying,
                    barCount: 3,
                    height: 16,
                    width: 14,
                    color: colors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF2A2A2A) // surface-container-high
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: _buildArtwork(context, colors),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: isActive ? colors.primary : colors.onSurface,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Text(
            '${song.artist} • ${song.album}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isActive ? colors.primary.withValues(alpha: 0.7) : colors.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.more_vert_rounded,
            color: isActive ? colors.primary : colors.onSurfaceVariant,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Options for: ${song.title}'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
        ),
        onTap: onTap,
      ),
    );
  }
}
