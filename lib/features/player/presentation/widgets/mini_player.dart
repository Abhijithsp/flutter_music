import 'dart:io';
import 'dart:math' as math;
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';

class MiniPlayer extends StatelessWidget {
  final VoidCallback onTap;

  const MiniPlayer({
    super.key,
    required this.onTap,
  });

  // Generates a beautiful deterministic neon gradient based on the song title hash
  List<Color> _getDeterministicColors(String title) {
    final int hash = title.hashCode;
    final List<List<Color>> palettes = [
      [const Color(0xFF8B5CF6), const Color(0xFFEC4899)], // Violet -> Pink
      [const Color(0xFF3B82F6), const Color(0xFF06B6D4)], // Blue -> Cyan
      [const Color(0xFF10B981), const Color(0xFF059669)], // Emerald -> Teal
      [const Color(0xFFF59E0B), const Color(0xFFEF4444)], // Amber -> Red
      [const Color(0xFF6366F1), const Color(0xFF8B5CF6)], // Indigo -> Purple
    ];
    final index = hash.abs() % palettes.length;
    return palettes[index];
  }

  Widget _buildMiniArtwork(MediaItem track) {
    final colors = _getDeterministicColors(track.title);
    final uriString = track.artUri?.toString();

    Widget imageContent = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          track.title.substring(0, math.min(track.title.length, 1)).toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ),
    );

    if (uriString != null && uriString.isNotEmpty) {
      try {
        if (uriString.startsWith('http')) {
          imageContent = Image.network(
            uriString,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => imageContent,
          );
        } else {
          final file = File(Uri.parse(uriString).toFilePath());
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
      height: 40,
      width: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageContent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final playerCubit = context.read<PlayerCubit>();
    final theme = Theme.of(context);

    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final currentTrack = state.currentTrack;
        if (currentTrack == null) {
          return const SizedBox.shrink();
        }

        final duration = currentTrack.duration ?? Duration.zero;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: GlassmorphicContainer(
              borderRadius: BorderRadius.circular(16),
              blur: 25.0,
              borderOpacity: 0.1,
              backgroundOpacity: 0.12,
              padding: EdgeInsets.zero,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                    child: Row(
                      children: [
                        // Artwork
                        _buildMiniArtwork(currentTrack),
                        const SizedBox(width: 12),
                        
                        // Title & Artist
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTrack.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currentTrack.artist ?? 'Unknown Artist',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 11.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Skip Previous
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous_rounded,
                            color: Colors.white70,
                            size: 24,
                          ),
                          onPressed: () => playerCubit.previous(),
                        ),
                        
                        // Play/Pause solid circular button
                        GestureDetector(
                          onTap: () => playerCubit.togglePlay(),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: theme.colorScheme.primary,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.colorScheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Icon(
                              state.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: theme.colorScheme.onPrimary,
                              size: 24,
                            ),
                          ),
                        ),
                        
                        // Skip Next
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white70,
                            size: 24,
                          ),
                          onPressed: () => playerCubit.next(),
                        ),
                      ],
                    ),
                  ),
                  
                  // Tiny Progress Bar absolute positioned at the top
                  if (duration > Duration.zero)
                    Positioned(
                      top: 0,
                      left: 16,
                      right: 16,
                      height: 2,
                      child: StreamBuilder<Duration>(
                        stream: AudioService.position,
                        builder: (context, snapshot) {
                          final position = snapshot.data ?? Duration.zero;
                          final double progress = (position.inMilliseconds / duration.inMilliseconds)
                              .clamp(0.0, 1.0);

                          return Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(1),
                            ),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary,
                                    borderRadius: BorderRadius.circular(1),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
