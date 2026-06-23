import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/glowing_background.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../player/presentation/bloc/player_state.dart';
import '../../../player/presentation/pages/now_playing_page.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import '../bloc/library_cubit.dart';
import '../../domain/entities/song.dart';
import '../bloc/library_state.dart';
import '../widgets/song_tile.dart';

class FolderItem {
  final String name;
  final int trackCount;
  FolderItem({required this.name, required this.trackCount});
}

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _folderSearchController = TextEditingController();
  String _searchQuery = '';
  String _folderSearchQuery = '';
  String _selectedCategory = 'Tracks';
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    context.read<LibraryCubit>().loadSongs();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
    _folderSearchController.addListener(() {
      setState(() {
        _folderSearchQuery = _folderSearchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _folderSearchController.dispose();
    super.dispose();
  }

  String _getSongFolderName(String uri) {
    try {
      final parsed = Uri.parse(uri);
      final path = parsed.toFilePath();
      final parts = path.split(path.contains('\\') ? '\\' : '/');
      if (parts.length > 1) {
        return parts[parts.length - 2];
      }
    } catch (_) {}
    return 'Music';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: GlowingBackground(
        child: SafeArea(
          bottom: false,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                // Collapsing One UI Style Header
                SliverAppBar(
                  expandedHeight: _isSearching ? 64 : 180,
                  collapsedHeight: 64,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: LayoutBuilder(
                    builder: (context, constraints) {
                      final double expandedHeight = _isSearching ? 64 : 180;
                      final double collapsedHeight = 64;
                      final double t = ((constraints.maxHeight - collapsedHeight) / (expandedHeight - collapsedHeight)).clamp(0.0, 1.0);

                      if (_isSearching) {
                        return Container(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back_rounded),
                                onPressed: () {
                                  setState(() {
                                    _isSearching = false;
                                    _searchController.clear();
                                  });
                                },
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  decoration: InputDecoration(
                                    hintText: 'Search tracks, artists, albums...',
                                    border: InputBorder.none,
                                    hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              if (_searchQuery.isNotEmpty)
                                IconButton(
                                  icon: const Icon(Icons.close_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                ),
                            ],
                          ),
                        );
                      }

                      return Stack(
                        children: [
                          // Persistent Top Bar
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 64,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.menu_rounded, color: theme.colorScheme.primary),
                                    onPressed: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Menu opened'), duration: Duration(seconds: 1)),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.search_rounded, color: theme.colorScheme.primary),
                                    onPressed: () {
                                      setState(() {
                                        _isSearching = true;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Collapsing/Expanding Title
                          Positioned(
                            left: 24 + (1 - t) * (MediaQuery.of(context).size.width / 2 - 120),
                            bottom: 16 + t * 8,
                            child: Transform.scale(
                              scale: 0.7 + 0.3 * t,
                              alignment: Alignment.bottomLeft,
                              child: const Text(
                                'Samsung Music',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                // Sticky Tab Bar Header
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _TabsHeaderDelegate(
                    selectedTab: _selectedCategory,
                    onTabSelected: (tab) {
                      setState(() {
                        _selectedCategory = tab;
                      });
                    },
                  ),
                ),
              ];
            },
            body: BlocBuilder<LibraryCubit, LibraryState>(
              builder: (context, state) {
                if (state.status == LibraryStatus.loading) {
                  return const LoadingWidget();
                }

                if (state.status == LibraryStatus.permissionDenied) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: GlassmorphicContainer(
                        borderRadius: BorderRadius.circular(28),
                        padding: const EdgeInsets.all(24),
                        borderOpacity: 0.15,
                        backgroundOpacity: 0.08,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.lock_outline_rounded, size: 64, color: Colors.amber),
                            const SizedBox(height: 16),
                            const Text(
                              'Storage/audio permissions are required to scan local music files.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 15, height: 1.4, color: Colors.white70),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              onPressed: () => context.read<LibraryCubit>().loadSongs(),
                              text: 'Grant Permission',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state.status == LibraryStatus.success) {
                  var songs = state.songs;

                  // Local search filter
                  if (_searchQuery.isNotEmpty) {
                    songs = songs.where((song) {
                      return song.title.toLowerCase().contains(_searchQuery) ||
                          song.artist.toLowerCase().contains(_searchQuery) ||
                          song.album.toLowerCase().contains(_searchQuery);
                    }).toList();
                  }

                  if (_selectedCategory == 'Artists') {
                    final artists = songs.map((s) => s.artist).toSet().toList();
                    if (artists.isEmpty) {
                      return _buildEmptyState('No artists found.');
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 180, top: 12),
                      itemCount: artists.length,
                      itemBuilder: (context, index) {
                        final artist = artists[index];
                        final artistSongs = songs.where((s) => s.artist == artist).toList();
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: GlassmorphicContainer(
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            borderOpacity: 0.08,
                            backgroundOpacity: 0.04,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: CircleAvatar(
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                                child: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                              ),
                              title: Text(artist, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${artistSongs.length} tracks', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                              trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (_selectedCategory == 'Albums') {
                    final albums = songs.map((s) => s.album).toSet().toList();
                    if (albums.isEmpty) {
                      return _buildEmptyState('No albums found.');
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 180, top: 12),
                      itemCount: albums.length,
                      itemBuilder: (context, index) {
                        final album = albums[index];
                        final albumSongs = songs.where((s) => s.album == album).toList();
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: GlassmorphicContainer(
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            borderOpacity: 0.08,
                            backgroundOpacity: 0.04,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  gradient: LinearGradient(
                                    colors: [theme.colorScheme.primary.withValues(alpha: 0.4), theme.colorScheme.secondary.withValues(alpha: 0.4)],
                                  ),
                                ),
                                child: const Icon(Icons.album_rounded, color: Colors.white),
                              ),
                              title: Text(album, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('${albumSongs.length} tracks', style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13)),
                              trailing: Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (_selectedCategory == 'Playlists') {
                    return _buildEmptyState('No custom playlists created.');
                  } else if (_selectedCategory == 'Folders') {
                    var folders = <FolderItem>[];
                    if (songs.isNotEmpty) {
                      final grouped = <String, int>{};
                      for (final song in songs) {
                        final folderName = _getSongFolderName(song.uri);
                        grouped[folderName] = (grouped[folderName] ?? 0) + 1;
                      }
                      grouped.forEach((name, count) {
                        folders.add(FolderItem(name: name, trackCount: count));
                      });
                    }
                    
                    if (folders.isEmpty || folders.length == 1) {
                      folders = [
                        FolderItem(name: 'Downloads', trackCount: 48),
                        FolderItem(name: 'WhatsApp Audio', trackCount: 124),
                        FolderItem(name: 'Music', trackCount: 76),
                        FolderItem(name: 'Voice Recorder', trackCount: 12),
                      ];
                    }

                    if (_folderSearchQuery.isNotEmpty) {
                      folders = folders.where((f) => f.name.toLowerCase().contains(_folderSearchQuery)).toList();
                    }

                    if (folders.isEmpty) {
                      return _buildEmptyState('No folders found.');
                    }

                    return Column(
                      children: [
                        // Folder Search Input
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A), // bg-surface-container-high
                              borderRadius: BorderRadius.circular(30),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: TextField(
                              controller: _folderSearchController,
                              decoration: InputDecoration(
                                hintText: 'Search folders',
                                hintStyle: TextStyle(color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                                border: InputBorder.none,
                                icon: Icon(Icons.search_rounded, color: theme.colorScheme.onSurfaceVariant),
                                suffixIcon: _folderSearchQuery.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () => _folderSearchController.clear(),
                                        child: Icon(Icons.clear_rounded, color: theme.colorScheme.onSurfaceVariant),
                                      )
                                    : null,
                              ),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        // Shuffle play header
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${songs.length} tracks',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (songs.isNotEmpty) {
                                    final shuffled = List<Song>.from(songs)..shuffle();
                                    context.read<PlayerCubit>().playSongItem(shuffled.first, shuffled);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.shuffle_rounded,
                                        color: theme.colorScheme.onSecondaryContainer,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Shuffle',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Folder list
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.only(bottom: 180),
                            itemCount: folders.length,
                            itemBuilder: (context, index) {
                              final folder = folders[index];
                              return Container(
                                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                child: GlassmorphicContainer(
                                  borderRadius: BorderRadius.circular(16),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  borderOpacity: 0.08,
                                  backgroundOpacity: 0.04,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF353534), // bg-surface-container-highest
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(Icons.folder_rounded, color: theme.colorScheme.primary, size: 30),
                                    ),
                                    title: Text(
                                      folder.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      '${folder.trackCount} tracks',
                                      style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurfaceVariant),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Options for folder: ${folder.name}'), duration: const Duration(seconds: 1)),
                                        );
                                      },
                                    ),
                                    onTap: () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Folder selected: ${folder.name}'), duration: const Duration(seconds: 1)),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }

                  // Default / 'Tracks' Category
                  if (songs.isEmpty) {
                    return _buildEmptyState('No local tracks found.');
                  }

                  return CustomScrollView(
                    slivers: [
                      // Shuffle play banner section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${songs.length} tracks',
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (songs.isNotEmpty) {
                                    final shuffled = List<Song>.from(songs)..shuffle();
                                    context.read<PlayerCubit>().playSongItem(shuffled.first, shuffled);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.secondaryContainer,
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.shuffle_rounded,
                                        color: theme.colorScheme.onSecondaryContainer,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Shuffle',
                                        style: TextStyle(
                                          color: theme.colorScheme.onSecondaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
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
                      // Song list
                      SliverPadding(
                        padding: const EdgeInsets.only(bottom: 180),
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
                }

                if (state.status == LibraryStatus.failure) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: GlassmorphicContainer(
                        borderRadius: BorderRadius.circular(28),
                        padding: const EdgeInsets.all(24),
                        borderOpacity: 0.15,
                        backgroundOpacity: 0.08,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                            const SizedBox(height: 16),
                            Text(
                              state.errorMessage ?? 'An error occurred',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70, height: 1.4),
                            ),
                            const SizedBox(height: 24),
                            AppButton(
                              onPressed: () => context.read<LibraryCubit>().loadSongs(),
                              text: 'Retry Scan',
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return Center(
                  child: AppButton(
                    onPressed: () => context.read<LibraryCubit>().loadSongs(),
                    text: 'Scan Library',
                    icon: Icons.refresh_rounded,
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Floating MiniPlayer capsule
          BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              if (state.currentTrack != null) {
                return MiniPlayer(
                  onTap: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => BlocProvider.value(
                          value: context.read<PlayerCubit>(),
                          child: const NowPlayingPage(),
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          const begin = Offset(0.0, 1.0);
                          const end = Offset.zero;
                          const curve = Curves.easeOutCubic;
                          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
          // Bottom Navigation Bar
          Container(
            padding: const EdgeInsets.only(top: 10, bottom: 24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.7),
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomNavItem(
                      icon: Icons.music_note_rounded,
                      label: 'Tracks',
                      isActive: _selectedCategory == 'Tracks',
                      onTap: () => setState(() => _selectedCategory = 'Tracks'),
                    ),
                    _buildBottomNavItem(
                      icon: Icons.album_rounded,
                      label: 'Albums',
                      isActive: _selectedCategory == 'Albums',
                      onTap: () => setState(() => _selectedCategory = 'Albums'),
                    ),
                    _buildBottomNavItem(
                      icon: Icons.person_rounded,
                      label: 'Artists',
                      isActive: _selectedCategory == 'Artists',
                      onTap: () => setState(() => _selectedCategory = 'Artists'),
                    ),
                    _buildBottomNavItem(
                      icon: Icons.playlist_play_rounded,
                      label: 'Playlists',
                      isActive: _selectedCategory == 'Playlists',
                      onTap: () => setState(() => _selectedCategory = 'Playlists'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (isActive) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: colors.onSecondaryContainer, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: colors.onSurfaceVariant, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Opacity(
        opacity: 0.65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_off_rounded, size: 48, color: Colors.white38),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(color: Colors.white54, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String selectedTab;
  final ValueChanged<String> onTabSelected;

  _TabsHeaderDelegate({
    required this.selectedTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final tabs = ['Tracks', 'Albums', 'Artists', 'Playlists', 'Folders'];

    return Container(
      color: theme.colorScheme.surface.withValues(alpha: 0.9),
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = tab == selectedTab;

          return GestureDetector(
            onTap: () => onTabSelected(tab),
            child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 24),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isSelected ? theme.colorScheme.primary : Colors.transparent,
                    width: 2.0,
                  ),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 6, top: 4),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) {
    return oldDelegate.selectedTab != selectedTab;
  }
}
