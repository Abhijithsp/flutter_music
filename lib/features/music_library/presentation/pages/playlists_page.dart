import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';
import 'playlist_detail_page.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final TextEditingController _playlistNameController = TextEditingController();

  List<Color> _getDeterministicColors(String title) {
    final int hash = title.hashCode;
    final List<List<Color>> palettes = [
      [const Color(0xFFFF8E53), const Color(0xFFFF007F)], // Sunset Orange -> Pink
      [const Color(0xFF11998E), const Color(0xFF38EF7D)], // Emerald Green -> Mint
      [const Color(0xFF00C6FF), const Color(0xFF0072FF)], // Ocean Blue -> Navy
      [const Color(0xFF7F00FF), const Color(0xFFFF007F)], // Purple -> Neon Pink
      [const Color(0xFF3E82F7), const Color(0xFFA7C8FF)], // Blue -> Light Blue
    ];
    final index = hash.abs() % palettes.length;
    return palettes[index];
  }

  void _showCreatePlaylistDialog(BuildContext context, LibraryCubit cubit) {
    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('New Playlist', style: TextStyle(color: colors.onSurface)),
          content: TextField(
            controller: _playlistNameController,
            autofocus: true,
            style: TextStyle(color: colors.onSurface),
            decoration: InputDecoration(
              hintText: 'Enter playlist name',
              hintStyle: TextStyle(color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.3)),
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
              child: Text('Cancel', style: TextStyle(color: colors.primary)),
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
                        const SnackBar(content: Text('Playlist already exists')),
                      );
                    }
                  }
                }
              },
              child: Text('Create', style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showDeletePlaylistDialog(BuildContext context, LibraryCubit cubit, String name) {
    showDialog(
      context: context,
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text('Delete Playlist', style: TextStyle(color: colors.onSurface)),
          content: Text(
            'Are you sure you want to delete "$name"? Songs inside will not be deleted.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.primary)),
            ),
            TextButton(
              onPressed: () {
                cubit.deletePlaylist(name);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Deleted playlist "$name"')),
                );
              },
              child: Text('Delete', style: TextStyle(color: colors.error, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final libraryCubit = context.read<LibraryCubit>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, libraryState) {
          final playlists = libraryState.playlists;

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
                title: Text(
                  'Playlists',
                  style: theme.appBarTheme.titleTextStyle?.copyWith(color: colors.onSurface),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add_rounded),
                    onPressed: () => _showCreatePlaylistDialog(context, libraryCubit),
                    tooltip: 'Create Playlist',
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              if (playlists.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.playlist_add_rounded,
                            size: 80,
                            color: colors.primary.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No custom playlists yet',
                            style: textTheme.titleMedium?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a playlist to organize your favorite tracks.',
                            textAlign: TextAlign.center,
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => _showCreatePlaylistDialog(context, libraryCubit),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Create Playlist'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 120.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.95,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final playlistName = playlists.keys.elementAt(index);
                        final songUris = playlists[playlistName] ?? [];
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
                          onLongPress: () => _showDeletePlaylistDialog(context, libraryCubit, playlistName),
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
                                      child: Icon(Icons.queue_music_rounded, color: Colors.white, size: 36),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  playlistName,
                                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$songCount tracks',
                                  style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: playlists.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
