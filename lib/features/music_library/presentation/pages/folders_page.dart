import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/song.dart';
import '../bloc/library_cubit.dart';
import '../bloc/library_state.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import 'folder_songs_page.dart';

class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getSongFolderName(Song song) {
    final filePath = song.path ?? '';
    if (filePath.isNotEmpty) {
      try {
        final path = filePath.replaceAll('\\', '/');
        final parts = path.split('/');
        if (parts.length > 1) {
          return parts[parts.length - 2];
        }
      } catch (_) {}
    }
    return 'Music';
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

          final songs = libraryState.songs;
          final foldersMap = <String, List<Song>>{};

          for (final song in songs) {
            final folderName = _getSongFolderName(song);
            if (!foldersMap.containsKey(folderName)) {
              foldersMap[folderName] = [];
            }
            foldersMap[folderName]!.add(song);
          }

          var folderNames = foldersMap.keys.toList();

          if (_isSearching && _searchQuery.isNotEmpty) {
            folderNames = folderNames
                .where((name) => name.toLowerCase().contains(_searchQuery))
                .toList();
          }

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
                          hintText: 'Search folders...',
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
                        'Folders',
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

              if (folderNames.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: Text('No folders found')),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 120, top: 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final folderName = folderNames[index];
                        final folderSongs = foldersMap[folderName] ?? [];

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                          child: GlassmorphicContainer(
                            borderRadius: BorderRadius.circular(16),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            borderOpacity: 0.08,
                            backgroundOpacity: 0.04,
                            child: ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.folder_rounded, color: colors.primary, size: 28),
                              ),
                              title: Text(
                                folderName,
                                style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                '${folderSongs.length} tracks',
                                style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                              ),
                              trailing: Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FolderSongsPage(
                                      folderName: folderName,
                                      songs: folderSongs,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      childCount: folderNames.length,
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
