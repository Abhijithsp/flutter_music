import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:audio_service/audio_service.dart';
import '../../../../core/services/audio/player_controller.dart';
import '../../../../core/services/locator/service_locator.dart';
import '../../domain/entities/song.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../player/presentation/bloc/player_state.dart';

class SongOptionsBottomSheet extends StatefulWidget {
  final Song song;
  final String? playlistName;

  const SongOptionsBottomSheet({
    super.key,
    required this.song,
    this.playlistName,
  });

  static void show(BuildContext context, Song song, {String? playlistName}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => SongOptionsBottomSheet(
        song: song,
        playlistName: playlistName,
      ),
    );
  }

  @override
  State<SongOptionsBottomSheet> createState() => _SongOptionsBottomSheetState();
}

class _SongOptionsBottomSheetState extends State<SongOptionsBottomSheet> {
  bool _showPlaylists = false;
  final TextEditingController _playlistNameController = TextEditingController();

  List<Color> _getDeterministicColors(String title) {
    final int hash = title.hashCode;
    final List<List<Color>> palettes = [
      [const Color(0xFF3E82F7), const Color(0xFFA7C8FF)],
      [const Color(0xFF8B5CF6), const Color(0xFFFF4B7D)],
      [const Color(0xFF00B4D8), const Color(0xFF90E0EF)],
      [const Color(0xFFFF4B7D), const Color(0xFFFF85A2)],
      [const Color(0xFF3E82F7), const Color(0xFFFF4B7D)],
    ];
    final index = hash.abs() % palettes.length;
    return palettes[index];
  }

  Widget _buildArtwork(ColorScheme colors) {
    final gradColors = _getDeterministicColors(widget.song.title);
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
          widget.song.title.substring(0, math.min(widget.song.title.length, 1)).toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 22,
          ),
        ),
      ),
    );

    if (widget.song.uri.isNotEmpty) {
      try {
        if (widget.song.uri.startsWith('http')) {
          imageContent = Image.network(
            widget.song.uri,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => imageContent,
          );
        } else {
          final file = File(Uri.parse(widget.song.uri).toFilePath());
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
      height: 64,
      width: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageContent,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF12121E).withValues(alpha: 0.95), // Premium deep dark color
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).padding.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // Header: Artwork, Title, Artist
          Row(
            children: [
              _buildArtwork(colors),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.song.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 8),

          // Animated Switcher for Main Menu vs Playlists Submenu
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.05, 0.0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _showPlaylists
                ? _buildPlaylistsMenu(context, colors)
                : _buildMainMenu(context, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildMainMenu(BuildContext context, ColorScheme colors) {
    return Column(
      key: const ValueKey('main_menu'),
      children: [
        // Favorite option
        BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, playerState) {
            final isFav = playerState.favorites.contains(widget.song.uri) ||
                playerState.favorites.contains(widget.song.id);
            return ListTile(
              leading: Icon(
                isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: isFav ? colors.tertiary : colors.onSurfaceVariant,
              ),
              title: Text(
                isFav ? 'Remove from Favorites' : 'Add to Favorites',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                context.read<PlayerCubit>().toggleFavorite(widget.song.uri);
                Navigator.pop(context);
              },
            );
          },
        ),

        // Add to Playlist option
        ListTile(
          leading: Icon(Icons.playlist_add_rounded, color: colors.onSurfaceVariant),
          title: const Text('Add to Playlist', style: TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white30),
          onTap: () {
            setState(() {
              _showPlaylists = true;
            });
          },
        ),

        // Add to Queue option
        ListTile(
          leading: Icon(Icons.queue_music_rounded, color: colors.onSurfaceVariant),
          title: const Text('Add to Queue', style: TextStyle(fontWeight: FontWeight.w500)),
          onTap: () {
            final controller = getIt<PlayerController>();
            final mediaItem = MediaItem(
              id: widget.song.uri,
              album: widget.song.album,
              title: widget.song.title,
              artist: widget.song.artist,
              duration: widget.song.duration,
              artUri: widget.song.artworkUri != null ? Uri.parse(widget.song.artworkUri!) : null,
            );
            controller.loadPlaylist(List.from(controller.currentQueue)..add(mediaItem));
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"${widget.song.title}" added to queue'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),

        // Remove from current Playlist (if applicable)
        if (widget.playlistName != null) ...[
          const SizedBox(height: 8),
          const Divider(color: Colors.white10),
          ListTile(
            leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            title: const Text(
              'Remove from Playlist',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w500),
            ),
            onTap: () {
              context.read<LibraryCubit>().removeSongFromPlaylist(
                    widget.playlistName!,
                    widget.song.uri,
                  );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Removed from ${widget.playlistName}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPlaylistsMenu(BuildContext context, ColorScheme colors) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      key: const ValueKey('playlists_menu'),
      builder: (context, libraryState) {
        final playlists = libraryState.playlists;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Subheader with Back button
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white70),
                  onPressed: () {
                    setState(() {
                      _showPlaylists = false;
                    });
                  },
                ),
                const Text(
                  'Select Playlist',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showCreatePlaylistDialog(context, context.read<LibraryCubit>()),
                  icon: const Icon(Icons.add, size: 16, color: Color(0xFF8B5CF6)),
                  label: const Text(
                    'Create New',
                    style: TextStyle(color: Color(0xFF8B5CF6), fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (playlists.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16),
                child: Center(
                  child: Text(
                    'No custom playlists. Create one to add tracks!',
                    style: TextStyle(color: Colors.white30, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 250),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final pName = playlists.keys.elementAt(index);
                    final songCount = playlists[pName]?.length ?? 0;

                    return ListTile(
                      leading: Icon(Icons.queue_music_rounded, color: colors.primary),
                      title: Text(pName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      subtitle: Text('$songCount tracks', style: const TextStyle(fontSize: 12, color: Colors.white30)),
                      onTap: () {
                        context.read<LibraryCubit>().addSongToPlaylist(pName, widget.song.uri);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Added to "$pName"'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
