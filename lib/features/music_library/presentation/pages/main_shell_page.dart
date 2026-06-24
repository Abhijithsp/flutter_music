import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_page.dart';
import 'songs_page.dart';
import 'artists_page.dart';
import 'albums_page.dart';
import 'folders_page.dart';
import 'playlists_page.dart';
import 'favorites_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../settings/presentation/bloc/settings_cubit.dart';
import '../../../settings/presentation/bloc/settings_state.dart';
import '../../../player/presentation/bloc/player_cubit.dart';
import '../../../player/presentation/bloc/player_state.dart';
import '../../../player/presentation/widgets/mini_player.dart';
import '../../../player/presentation/pages/now_playing_page.dart';
import '../../../../core/widgets/glowing_background.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  String _currentTab = 'Home';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _getPage(String tabName) {
    switch (tabName) {
      case 'Home':
        return const HomePage();
      case 'Songs':
        return const SongsPage();
      case 'Artists':
        return const ArtistsPage();
      case 'Albums':
        return const AlbumsPage();
      case 'Folders':
        return const FoldersPage();
      case 'Playlists':
        return const PlaylistsPage();
      case 'Favorites':
        return const FavoritesPage();
      case 'Settings':
        return const SettingsPage();
      default:
        return const HomePage();
    }
  }

  IconData _getTabIcon(String tabName) {
    switch (tabName) {
      case 'Home':
        return Icons.home_rounded;
      case 'Songs':
        return Icons.music_note_rounded;
      case 'Artists':
        return Icons.person_rounded;
      case 'Albums':
        return Icons.album_rounded;
      case 'Folders':
        return Icons.folder_rounded;
      case 'Playlists':
        return Icons.queue_music_rounded;
      case 'Favorites':
        return Icons.favorite_rounded;
      case 'Settings':
        return Icons.settings_rounded;
      default:
        return Icons.home_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width >= 600;

    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        final tabs = settingsState.visibleTabs;
        
        // Safety check if current tab was hidden
        if (!tabs.contains(_currentTab)) {
          _currentTab = tabs.first;
        }

        final currentIdx = tabs.indexOf(_currentTab);

        // Sidebar Widget (NavigationDrawer or custom Column)
        Widget buildSidebar() {
          return Container(
            width: 250,
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.8),
              border: Border(
                right: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: 0.15),
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Text(
                      'Aura Sound',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: tabs.length,
                      itemBuilder: (context, index) {
                        final tab = tabs[index];
                        final isSelected = tab == _currentTab;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSelected ? colors.primaryContainer : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: Icon(
                              _getTabIcon(tab),
                              color: isSelected ? colors.onPrimaryContainer : colors.onSurfaceVariant,
                            ),
                            title: Text(
                              tab,
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? colors.onPrimaryContainer : colors.onSurface,
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _currentTab = tab;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final bool hasOverflow = tabs.length > 5;
        final List<String> bottomBarTabs = hasOverflow
            ? [...tabs.take(4), 'More']
            : tabs;

        final bool isCurrentTabInBottomBar = bottomBarTabs.contains(_currentTab);

        return Scaffold(
          key: _scaffoldKey,
          drawer: isTablet ? null : Drawer(
            child: buildSidebar(),
          ),
          body: GlowingBackground(
            child: Row(
              children: [
                if (isTablet) buildSidebar(),
                Expanded(
                  child: Stack(
                    children: [
                      // Render Screens preserving scroll/states via IndexedStack
                      IndexedStack(
                        index: currentIdx,
                        children: tabs.map((tab) => _getPage(tab)).toList(),
                      ),
                      
                      // Floating MiniPlayer capsule
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: isTablet ? 16 : 96,
                        child: BlocBuilder<PlayerCubit, PlayerState>(
                          builder: (context, playerState) {
                            if (playerState.currentTrack != null) {
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Bottom Navigation Bar for Mobile Phones
          bottomNavigationBar: isTablet
              ? null
              : Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: colors.surface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: colors.outlineVariant.withValues(alpha: 0.15),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: bottomBarTabs.map((tab) {
                            final isMore = tab == 'More';
                            final isSelected = isMore
                                ? !isCurrentTabInBottomBar
                                : (tab == _currentTab);

                            return Expanded(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  if (isMore) {
                                    _scaffoldKey.currentState?.openDrawer();
                                  } else {
                                    setState(() {
                                      _currentTab = tab;
                                    });
                                  }
                                },
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    AnimatedScale(
                                      scale: isSelected ? 1.15 : 1.0,
                                      duration: const Duration(milliseconds: 200),
                                      curve: Curves.easeOutCubic,
                                      child: Icon(
                                        isMore ? Icons.apps_rounded : _getTabIcon(tab),
                                        color: isSelected ? colors.primary : colors.onSurfaceVariant.withValues(alpha: 0.6),
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      tab,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: isSelected ? colors.primary : colors.onSurfaceVariant.withValues(alpha: 0.6),
                                        fontSize: 10,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      margin: const EdgeInsets.only(top: 2),
                                      height: 3,
                                      width: isSelected ? 8 : 0,
                                      decoration: BoxDecoration(
                                        color: colors.primary,
                                        borderRadius: BorderRadius.circular(1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: colors.primary.withValues(alpha: 0.5),
                                            blurRadius: 4,
                                            spreadRadius: 0.5,
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
