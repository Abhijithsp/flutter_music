import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../../../../core/services/locator/service_locator.dart';
import '../../../../core/services/audio/playback_history_tracker.dart';
import '../../domain/entities/song.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../player/presentation/bloc/player_state.dart';
import '../widgets/song_tile.dart';
import 'playlist_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final PlaybackHistoryTracker _tracker = getIt<PlaybackHistoryTracker>();
  String _searchQuery = '';
  bool _isSearching = false;

  final TextEditingController _playlistNameController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _playlistNameController.dispose();
    super.dispose();
  }

  void _showCreatePlaylistDialog(BuildContext context, LibraryCubit cubit) {
    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: Text(
            'New Playlist',
            style: TextStyle(color: colors.onSurface),
          ),
          content: TextField(
            controller: _playlistNameController,
            autofocus: true,
            style: TextStyle(color: colors.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter playlist name',
              hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _playlistNameController.clear();
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.primary),
              ),
            ),
            TextButton(
              onPressed: () async {
                final name = _playlistNameController.text.trim();
                if (name.isNotEmpty) {
                  final success = await cubit.createPlaylist(name);
                  if (success) {
                    _playlistNameController.clear();
                    if (context.mounted) Navigator.pop(context);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Playlist already exists'),
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(
                'Create',
                style: TextStyle(
                  color: colors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Generates a beautiful deterministic neon gradient based on the song title hash
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

  Widget _buildArtworkPlaceholder(String title, double size) {
    final colors = _getDeterministicColors(title);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          title.substring(0, math.min(title.length, 1)).toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: size * 0.35,
          ),
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

          final allSongs = libraryState.songs;

          // Retrieve dynamic history lists
          final recentIds = _tracker.getRecentlyPlayed();
          final recentlyPlayed = recentIds
              .map(
                (id) => allSongs.firstWhere(
                  (s) => s.id == id || s.uri == id,
                  orElse: () => const Song(
                    id: '',
                    title: '',
                    artist: '',
                    album: '',
                    duration: Duration.zero,
                    uri: '',
                  ),
                ),
              )
              .where((s) => s.id.isNotEmpty)
              .toList();

          final favIds = _tracker.getFavorites();
          final favorites = favIds
              .map(
                (id) => allSongs.firstWhere(
                  (s) => s.id == id || s.uri == id,
                  orElse: () => const Song(
                    id: '',
                    title: '',
                    artist: '',
                    album: '',
                    duration: Duration.zero,
                    uri: '',
                  ),
                ),
              )
              .where((s) => s.id.isNotEmpty)
              .toList();

          final playCounts = _tracker.getPlayCounts();
          final mostPlayed = List<Song>.from(allSongs)
            ..sort(
              (a, b) => (playCounts[b.uri] ?? playCounts[b.id] ?? 0).compareTo(
                playCounts[a.uri] ?? playCounts[a.id] ?? 0,
              ),
            );
          final filteredMostPlayed = mostPlayed
              .where((s) => (playCounts[s.uri] ?? playCounts[s.id] ?? 0) > 0)
              .take(10)
              .toList();

          // Recently added (mocked as last 50 songs loaded)
          final recentlyAdded = allSongs.reversed.take(50).toList();

          // Filter songs if searching
          var searchedSongs = allSongs;
          if (_isSearching && _searchQuery.isNotEmpty) {
            searchedSongs = allSongs
                .where(
                  (s) =>
                      s.title.toLowerCase().contains(_searchQuery) ||
                      s.artist.toLowerCase().contains(_searchQuery) ||
                      s.album.toLowerCase().contains(_searchQuery),
                )
                .toList();
          }

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Top Bar with Profile & Search Toggle
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
                title: Text(
                  'Aura Sound',
                  style: theme.appBarTheme.titleTextStyle?.copyWith(
                    color: colors.onSurface,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      _isSearching ? Icons.close_rounded : Icons.search_rounded,
                    ),
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

              if (_isSearching)
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainer,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Search tracks, artists, albums...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      style: TextStyle(color: colors.onSurface),
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                    ),
                  ),
                ),

              if (_isSearching && _searchQuery.isNotEmpty) ...[
                if (searchedSongs.isEmpty)
                  const SliverFillRemaining(
                    child: Center(child: Text('No matching songs found')),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final song = searchedSongs[index];
                        return BlocBuilder<PlayerCubit, PlayerState>(
                          builder: (context, playerState) {
                            final currentTrack = playerState.currentTrack;
                            final isActive =
                                currentTrack != null &&
                                currentTrack.id == song.uri;
                            final isPlaying = isActive && playerState.isPlaying;

                            return SongTile(
                              song: song,
                              isActive: isActive,
                              isPlaying: isPlaying,
                              onTap: () {
                                context.read<PlayerCubit>().playSongItem(
                                  song,
                                  searchedSongs,
                                );
                              },
                            );
                          },
                        );
                      }, childCount: searchedSongs.length),
                    ),
                  ),
              ] else ...[
                // Recently Played Section
                if (recentlyPlayed.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 12.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Recently Played',
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'See All',
                              style: TextStyle(color: colors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: recentlyPlayed.length,
                        itemBuilder: (context, index) {
                          final song = recentlyPlayed[index];
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: GestureDetector(
                              onTap: () {
                                context.read<PlayerCubit>().playSongItem(
                                  song,
                                  recentlyPlayed,
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildArtworkPlaceholder(song.title, 130),
                                  const SizedBox(height: 8),
                                  Text(
                                    song.title,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    song.artist,
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                // Favorites & Most Played Grids
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.4,
                      children: [
                        // Favorites Card
                        GestureDetector(
                          onTap: () {
                            if (favorites.isNotEmpty) {
                              context.read<PlayerCubit>().playSongItem(
                                favorites.first,
                                favorites,
                              );
                            }
                          },
                          child: GlassmorphicContainer(
                            borderRadius: BorderRadius.circular(20),
                            borderOpacity: 0.1,
                            backgroundOpacity: 0.06,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.favorite_rounded,
                                  color: colors.tertiary,
                                  size: 36,
                                ),
                                const Spacer(),
                                Text(
                                  'Favorites',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${favorites.length} Tracks Saved',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Most Played Card
                        GestureDetector(
                          onTap: () {
                            if (filteredMostPlayed.isNotEmpty) {
                              context.read<PlayerCubit>().playSongItem(
                                filteredMostPlayed.first,
                                filteredMostPlayed,
                              );
                            }
                          },
                          child: GlassmorphicContainer(
                            borderRadius: BorderRadius.circular(20),
                            borderOpacity: 0.1,
                            backgroundOpacity: 0.06,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: colors.primary,
                                  size: 36,
                                ),
                                const Spacer(),
                                Text(
                                  'Most Played',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${filteredMostPlayed.length} Tracks',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
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

                // Playlists Grid
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      'Playlists',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (libraryState.playlists.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 8.0,
                      ),
                      child: GestureDetector(
                        onTap: () => _showCreatePlaylistDialog(
                          context,
                          context.read<LibraryCubit>(),
                        ),
                        child: GlassmorphicContainer(
                          borderRadius: BorderRadius.circular(20),
                          borderOpacity: 0.08,
                          backgroundOpacity: 0.04,
                          padding: const EdgeInsets.symmetric(
                            vertical: 24,
                            horizontal: 16,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.playlist_add_rounded,
                                color: colors.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'No Playlists. Create New +',
                                style: textTheme.bodyLarge?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 12.0,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.95,
                          ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final playlistName = libraryState.playlists.keys
                              .elementAt(index);
                          final songUris =
                              libraryState.playlists[playlistName] ?? [];
                          final songCount = songUris.length;
                          final grad = _getDeterministicColors(playlistName);

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PlaylistDetailPage(
                                    playlistName: playlistName,
                                  ),
                                ),
                              );
                            },
                            child: GlassmorphicContainer(
                              borderRadius: BorderRadius.circular(20),
                              borderOpacity: 0.08,
                              backgroundOpacity: 0.04,
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: grad,
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.queue_music_rounded,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    playlistName,
                                    style: textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '$songCount tracks',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: math.min(4, libraryState.playlists.length),
                      ),
                    ),
                  ),

                // Recently Added Section
                if (recentlyAdded.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                      child: Text(
                        'Recently Added',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(bottom: 120),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final song = recentlyAdded[index];
                        return BlocBuilder<PlayerCubit, PlayerState>(
                          builder: (context, playerState) {
                            final currentTrack = playerState.currentTrack;
                            final isActive =
                                currentTrack != null &&
                                currentTrack.id == song.uri;
                            final isPlaying = isActive && playerState.isPlaying;

                            return SongTile(
                              song: song,
                              isActive: isActive,
                              isPlaying: isPlaying,
                              onTap: () {
                                context.read<PlayerCubit>().playSongItem(
                                  song,
                                  recentlyAdded,
                                );
                              },
                            );
                          },
                        );
                      }, childCount: recentlyAdded.length),
                    ),
                  ),
                ] else
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ],
          );
        },
      ),
    );
  }
}
