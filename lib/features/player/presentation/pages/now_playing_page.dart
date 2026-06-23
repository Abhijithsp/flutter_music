import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glowing_background.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../../../../core/widgets/visualizer_widget.dart';
import '../bloc/player_cubit.dart';
import '../bloc/player_state.dart';
import '../widgets/artwork_widget.dart';
import '../widgets/player_controls.dart';
import '../widgets/seek_bar.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  bool _isFavorite = false;
  bool _showLyrics = false;
  double _volume = 0.7;

  // Pre-defined premium simulated lyrics for a music experience
  final List<String> _simulatedLyrics = [
    "Echoes in the starlight...",
    "We wander through the neon glow",
    "Chasing shadows that we used to know",
    "Every beat is a promise we keep",
    "Lost in the sound, falling so deep",
    "Through the static, I hear your name",
    "Music plays and clears the pain",
    "Rising up, we touch the sky",
    "No more questions, no more why",
    "Just the octave of our hearts",
    "Where the endless journey starts...",
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.expand_more_rounded, size: 36),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Now Playing'),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('More options'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: GlowingBackground(
        child: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            final currentTrack = state.currentTrack;
            if (currentTrack == null) {
              return const Center(child: Text('No song playing'));
            }

            final duration = currentTrack.duration ?? Duration.zero;
            final size = MediaQuery.of(context).size.width * 0.72;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    
                    // Top Visualizer Band indicating playback pulse
                    Opacity(
                      opacity: state.isPlaying ? 0.8 : 0.3,
                      child: VisualizerWidget(
                        isPlaying: state.isPlaying,
                        barCount: 15,
                        height: 20,
                        width: 140,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Main Center Crossfade (Artwork vs Sync Lyrics)
                    Expanded(
                      child: Center(
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 400),
                          firstCurve: Curves.easeInOutCubic,
                          secondCurve: Curves.easeInOutCubic,
                          crossFadeState: _showLyrics ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                          firstChild: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                width: size * 0.9,
                                height: size * 0.9,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                  boxShadow: [
                                    BoxShadow(
                                      color: theme.colorScheme.primary.withValues(alpha: 0.2),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              ArtworkWidget(
                                track: currentTrack,
                                isPlaying: state.isPlaying,
                                size: size,
                              ),
                            ],
                          ),
                          secondChild: GlassmorphicContainer(
                            height: MediaQuery.of(context).size.height * 0.42,
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(28),
                            padding: const EdgeInsets.all(24),
                            borderOpacity: 0.15,
                            backgroundOpacity: 0.08,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'LYRICS',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                    const Icon(Icons.sync_rounded, size: 16, color: Colors.white38),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: _simulatedLyrics.length,
                                    itemBuilder: (context, index) {
                                      // Highlight line 4 as the active line for dynamic visual appeal
                                      final isActiveLine = index == 4;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                                        child: Text(
                                          _simulatedLyrics[index],
                                          style: TextStyle(
                                            fontSize: isActiveLine ? 19 : 15,
                                            fontWeight: isActiveLine ? FontWeight.w800 : FontWeight.w500,
                                            color: isActiveLine 
                                                ? Colors.white 
                                                : Colors.white.withValues(alpha: 0.35),
                                            shadows: isActiveLine ? [
                                              Shadow(
                                                color: theme.colorScheme.primary.withValues(alpha: 0.6),
                                                blurRadius: 10,
                                              )
                                            ] : null,
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
                      ),
                    ),
                    
                    const SizedBox(height: 24),

                    // Title, Artist and Favorite Button Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentTrack.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                currentTrack.artist ?? 'Unknown Artist',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Glass Fav Button
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isFavorite = !_isFavorite;
                            });
                          },
                          child: GlassmorphicContainer(
                            height: 48,
                            width: 48,
                            borderRadius: BorderRadius.circular(16),
                            borderOpacity: 0.1,
                            backgroundOpacity: _isFavorite ? 0.2 : 0.05,
                            padding: EdgeInsets.zero,
                            child: Center(
                              child: AnimatedScale(
                                scale: _isFavorite ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  _isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: _isFavorite ? theme.colorScheme.tertiary : theme.colorScheme.onSurfaceVariant,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),

                    // SeekBar
                    SeekBar(duration: duration),
                    
                    const SizedBox(height: 24),

                    // Playback Controls
                    const PlayerControls(iconSize: 32),
                    
                    const SizedBox(height: 24),

                    // Volume Slider Row
                    Row(
                      children: [
                        Icon(
                          _volume == 0 ? Icons.volume_off_rounded : Icons.volume_down_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        Expanded(
                          child: SliderTheme(
                            data: theme.sliderTheme.copyWith(
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
                              thumbColor: theme.colorScheme.primary,
                              trackHeight: 3.0,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                            ),
                            child: Slider(
                              value: _volume,
                              onChanged: (val) {
                                setState(() {
                                  _volume = val;
                                });
                              },
                            ),
                          ),
                        ),
                        Icon(
                          Icons.volume_up_rounded,
                          size: 18,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),

                    // Bottom Navigation / Action Row (LIST, LYRICS, DEVICES)
                    Container(
                      padding: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildUtilityButton(
                            icon: Icons.playlist_play_rounded,
                            label: 'LIST',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Queue opened'), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                          _buildUtilityButton(
                            icon: Icons.lyrics_rounded,
                            label: 'LYRICS',
                            isActive: _showLyrics,
                            activeColor: theme.colorScheme.primary,
                            onTap: () {
                              setState(() {
                                _showLyrics = !_showLyrics;
                              });
                            },
                          ),
                          _buildUtilityButton(
                            icon: Icons.devices_rounded,
                            label: 'DEVICES',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Devices list'), duration: Duration(seconds: 1)),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildUtilityButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? activeColor,
  }) {
    final theme = Theme.of(context);
    final color = isActive 
        ? (activeColor ?? theme.colorScheme.primary) 
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
