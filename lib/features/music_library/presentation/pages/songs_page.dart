import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:on_audio_query/on_audio_query.dart' as query;
import '../../domain/entities/song.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../player/presentation/bloc/player_state.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../widgets/song_tile.dart';
import '../../../../core/widgets/visualizer_widget.dart';

class SongsPage extends StatefulWidget {
  const SongsPage({super.key});

  @override
  State<SongsPage> createState() => _SongsPageState();
}

class _SongsPageState extends State<SongsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Color> _getDeterministicColors(String title) {
    final int hash = title.hashCode;
    final List<List<Color>> palettes = [
      [const Color(0xFF3E82F7), const Color(0xFFA7C8FF)],
      [const Color(0xFF8B5CF6), const Color(0xFFFF4B7D)],
      [const Color(0xFF00B4D8), const Color(0xFF90E0EF)],
      [const Color(0xFFFF4B7D), const Color(0xFFFF85A2)],
      [const Color(0xFF3E82F7), const Color(0xFFFF4B7D)],
    ];
    return palettes[hash.abs() % palettes.length];
  }

  Widget _buildArtwork(BuildContext context, Song song, bool isActive, bool isPlaying, double size) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final songId = int.tryParse(song.id);

    Widget imageContent = Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getDeterministicColors(song.title),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          song.title.substring(0, math.min(song.title.length, 1)).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: size * 0.35,
          ),
        ),
      ),
    );

    if (songId != null) {
      imageContent = query.QueryArtworkWidget(
        id: songId,
        type: query.ArtworkType.AUDIO,
        keepOldArtwork: true,
        nullArtworkWidget: imageContent,
      );
    }

    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
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
                    height: size * 0.3,
                    width: size * 0.28,
                    color: colors.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridTile(BuildContext context, Song song, bool isActive, bool isPlaying, VoidCallback onTap) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isActive ? colors.surfaceContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1.0,
                child: _buildArtwork(context, song, isActive, isPlaying, 120),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleSmall?.copyWith(
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? colors.primary : colors.onSurface,
              ),
            ),
            Text(
              song.artist,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
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
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, libraryState) {
          if (libraryState.status == LibraryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          var songs = libraryState.songs;

          if (_isSearching && _searchQuery.isNotEmpty) {
            songs = songs.where((song) {
              return song.title.toLowerCase().contains(_searchQuery) ||
                  song.artist.toLowerCase().contains(_searchQuery) ||
                  song.album.toLowerCase().contains(_searchQuery);
            }).toList();
          }

          return BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settingsState) {
              final isGrid = settingsState.viewPreference == 'grid';

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: false,
                    floating: true,
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    leading: Builder(
                      builder: (context) {
                        return IconButton(
                          icon: const Icon(Icons.menu_rounded),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        );
                      },
                    ),
                    title: _isSearching
                        ? TextField(
                            controller: _searchController,
                            autofocus: true,
                            decoration: InputDecoration(
                              hintText: 'Search songs...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                            ),
                            style: TextStyle(color: colors.onSurface),
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val.trim().toLowerCase();
                              });
                            },
                          )
                        : Text(
                            'Songs',
                            style: theme.appBarTheme.titleTextStyle?.copyWith(color: colors.onSurface),
                          ),
                    bottom: libraryState.isScanning
                        ? PreferredSize(
                            preferredSize: const Size.fromHeight(2),
                            child: LinearProgressIndicator(
                              minHeight: 2,
                              backgroundColor: Colors.transparent,
                              valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                            ),
                          )
                        : null,
                    actions: [
                      if (!_isSearching)
                        IconButton(
                          icon: const Icon(Icons.sync_rounded),
                          tooltip: 'Scan Library',
                          onPressed: () {
                            context.read<LibraryCubit>().loadSongs(forceScan: true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Scanning device for music...'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
                      IconButton(
                        icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
                        onPressed: () {
                          setState(() {
                            _isSearching = !_isSearching;
                            if (!_isSearching) {
                              _searchController.clear();
                              _searchQuery = '';
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  // Shuffle & Header Controls
                  if (songs.isNotEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${songs.length} tracks',
                              style: textTheme.bodyLarge?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                final shuffled = List<Song>.from(songs)..shuffle();
                                context.read<PlayerCubit>().playSongItem(shuffled.first, shuffled);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                decoration: BoxDecoration(
                                  color: colors.secondaryContainer,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.shuffle_rounded,
                                      color: colors.onSecondaryContainer,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Shuffle',
                                      style: TextStyle(
                                        color: colors.onSecondaryContainer,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (songs.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: Text('No tracks found')),
                    )
                  else if (isGrid)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = songs[index];
                            return BlocBuilder<PlayerCubit, PlayerState>(
                              builder: (context, playerState) {
                                final currentTrack = playerState.currentTrack;
                                final isActive = currentTrack != null && currentTrack.id == song.uri;
                                final isPlaying = isActive && playerState.isPlaying;

                                return _buildGridTile(
                                  context,
                                  song,
                                  isActive,
                                  isPlaying,
                                  () => context.read<PlayerCubit>().playSongItem(song, songs),
                                );
                              },
                            );
                          },
                          childCount: songs.length,
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.only(bottom: 120),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final song = songs[index];
                            return BlocBuilder<PlayerCubit, PlayerState>(
                              builder: (context, playerState) {
                                final currentTrack = playerState.currentTrack;
                                final isActive = currentTrack != null && currentTrack.id == song.uri;
                                final isPlaying = isActive && playerState.isPlaying;

                                return SongTile(
                                  song: song,
                                  isActive: isActive,
                                  isPlaying: isPlaying,
                                  onTap: () {
                                    context.read<PlayerCubit>().playSongItem(song, songs);
                                  },
                                );
                              },
                            );
                          },
                          childCount: songs.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
