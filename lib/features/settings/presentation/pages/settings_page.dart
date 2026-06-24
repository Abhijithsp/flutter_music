import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/glassmorphic_container.dart';
import '../bloc/settings_cubit.dart';
import '../bloc/settings_state.dart';
import '../../../music_library/presentation/bloc/library_cubit.dart';
import '../../../music_library/presentation/bloc/library_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final List<Map<String, dynamic>> accentColors = [
      {'name': 'Lavender', 'color': const Color(0xFF7C4DFF)},
      {'name': 'Fluid Blue', 'color': const Color(0xFF3E82F7)},
      {'name': 'Aura Pink', 'color': const Color(0xFFFF4B7D)},
      {'name': 'Emerald', 'color': const Color(0xFF00C853)},
      {'name': 'Amber', 'color': const Color(0xFFFFAB00)},
    ];

    final List<Map<String, dynamic>> appIcons = [
      {
        'key': 'Default',
        'name': 'Default',
        'bgColor': const Color(0xFF0F0C1B),
        'borderColor': const Color(0xFF7C4DFF),
        'iconColor': Colors.white,
        'icon': Icons.music_note_rounded,
        'isGradient': true,
        'gradient': const LinearGradient(
          colors: [Color(0xFF7C4DFF), Color(0xFFFF4B7D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'key': 'aura_sound_dark',
        'name': 'Aura Dark',
        'bgColor': const Color(0xFF1E1E1E),
        'borderColor': const Color(0xFF00E5FF),
        'iconColor': const Color(0xFF00E5FF),
        'icon': Icons.waves_rounded,
        'isGradient': false,
      },
      {
        'key': 'aura_sound_light',
        'name': 'Aura Light',
        'bgColor': Colors.white,
        'borderColor': const Color(0xFF333333),
        'iconColor': const Color(0xFF333333),
        'icon': Icons.blur_circular_rounded,
        'isGradient': false,
      },
      {
        'key': 'aura_sound_gradient',
        'name': 'Aura Neon',
        'bgColor': const Color(0xFF21094E),
        'borderColor': Colors.white,
        'iconColor': Colors.white,
        'icon': Icons.equalizer_rounded,
        'isGradient': true,
        'gradient': const LinearGradient(
          colors: [Color(0xFF8A2387), Color(0xFFE94057), Color(0xFFF27121)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      },
      {
        'key': 'aura_sound_retro',
        'name': 'Aura Retro',
        'bgColor': const Color(0xFFFFE0B2),
        'borderColor': const Color(0xFFE65100),
        'iconColor': const Color(0xFFE65100),
        'icon': Icons.album_rounded,
        'isGradient': false,
      },
      {
        'key': 'aura_sound_mono',
        'name': 'Aura Mono',
        'bgColor': Colors.black,
        'borderColor': Colors.white,
        'iconColor': Colors.white,
        'icon': Icons.music_note_outlined,
        'isGradient': false,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          final settingsCubit = context.read<SettingsCubit>();

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
                  'Settings',
                  style: theme.appBarTheme.titleTextStyle?.copyWith(color: colors.onSurface),
                ),
              ),

              SliverList(
                delegate: SliverChildListDelegate([
                  _buildSectionHeader(context, 'App Customization'),

                  // Theme Mode Selector
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: GlassmorphicContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      borderOpacity: 0.08,
                      backgroundOpacity: 0.04,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.dark_mode_rounded, color: colors.primary),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Theme Mode', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    Text('Choose light, dark, or system default theme', style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: SegmentedButton<ThemeMode>(
                                  segments: const [
                                    ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                                    ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
                                    ButtonSegment(value: ThemeMode.system, label: Text('System')),
                                  ],
                                  selected: {state.themeMode},
                                  onSelectionChanged: (selected) {
                                    settingsCubit.updateThemeMode(selected.first);
                                  },
                                  style: SegmentedButton.styleFrom(
                                    selectedBackgroundColor: colors.primaryContainer,
                                    selectedForegroundColor: colors.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Accent Color Selector
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: GlassmorphicContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      borderOpacity: 0.08,
                      backgroundOpacity: 0.04,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.palette_rounded, color: colors.primary),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Accent Color', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    Text('Select your primary signature accent color', style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: accentColors.length,
                              itemBuilder: (context, index) {
                                final colorItem = accentColors[index];
                                final Color col = colorItem['color'] as Color;
                                final isSelected = state.accentColor.toARGB32() == col.toARGB32();

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: GestureDetector(
                                    onTap: () => settingsCubit.updateAccentColor(col),
                                    child: CircleAvatar(
                                      backgroundColor: col,
                                      radius: 20,
                                      child: isSelected
                                          ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
                                          : null,
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

                  // App Icon Selector
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: GlassmorphicContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      borderOpacity: 0.08,
                      backgroundOpacity: 0.04,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.app_shortcut_rounded, color: colors.primary),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('App Icon', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                    Text('Select your preferred home screen app icon', style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 105,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: appIcons.length,
                              itemBuilder: (context, index) {
                                final iconItem = appIcons[index];
                                final String iconKey = iconItem['key'] as String;
                                final String iconName = iconItem['name'] as String;
                                final Color bgColor = iconItem['bgColor'] as Color;
                                final Color borderColor = iconItem['borderColor'] as Color;
                                final Color iconColor = iconItem['iconColor'] as Color;
                                final IconData iconData = iconItem['icon'] as IconData;
                                final bool isGradient = iconItem['isGradient'] as bool;
                                final Gradient? gradient = iconItem['gradient'] as Gradient?;
                                final isSelected = state.appIcon == iconKey;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: GestureDetector(
                                    onTap: () => settingsCubit.updateAppIcon(iconKey),
                                    child: Column(
                                      children: [
                                        Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: isGradient ? null : bgColor,
                                                gradient: isGradient ? gradient : null,
                                                borderRadius: BorderRadius.circular(14),
                                                border: Border.all(
                                                  color: isSelected ? colors.primary : borderColor.withValues(alpha: 0.5),
                                                  width: isSelected ? 3 : 1.5,
                                                ),
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: colors.primary.withValues(alpha: 0.4),
                                                          blurRadius: 8,
                                                          spreadRadius: 1,
                                                        )
                                                      ]
                                                    : null,
                                              ),
                                              child: Icon(
                                                iconData,
                                                color: iconColor,
                                                size: 26,
                                              ),
                                            ),
                                            if (isSelected)
                                              Positioned(
                                                right: 1,
                                                bottom: 1,
                                                child: CircleAvatar(
                                                  radius: 9,
                                                  backgroundColor: colors.primary,
                                                  child: const Icon(
                                                    Icons.check_rounded,
                                                    color: Colors.white,
                                                    size: 11,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          iconName,
                                          style: textTheme.bodySmall?.copyWith(
                                            fontSize: 11,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                            color: isSelected ? colors.primary : colors.onSurface,
                                          ),
                                        ),
                                      ],
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

                  // Layout & Startup Settings
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: GlassmorphicContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      borderOpacity: 0.08,
                      backgroundOpacity: 0.04,
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.grid_view_rounded, color: colors.primary),
                            title: const Text('View Preference', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Set grid or list view for music lists'),
                            trailing: Switch(
                              value: state.viewPreference == 'grid',
                              onChanged: (val) {
                                settingsCubit.updateViewPreference(val ? 'grid' : 'list');
                              },
                              activeThumbColor: colors.primary,
                            ),
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.start_rounded, color: colors.primary),
                            title: const Text('Startup Screen', style: TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: const Text('Set the default screen when app opens'),
                            trailing: DropdownButton<String>(
                              value: state.defaultStartupScreen,
                              dropdownColor: colors.surfaceContainerHigh,
                              underline: const SizedBox.shrink(),
                              items: const [
                                DropdownMenuItem(value: 'Home', child: Text('Home')),
                                DropdownMenuItem(value: 'Songs', child: Text('Songs')),
                                DropdownMenuItem(value: 'Artists', child: Text('Artists')),
                                DropdownMenuItem(value: 'Folders', child: Text('Folders')),
                                DropdownMenuItem(value: 'Playlists', child: Text('Playlists')),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  settingsCubit.updateDefaultStartupScreen(val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildSectionHeader(context, 'Library & Scanning'),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                    child: GlassmorphicContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.all(16),
                      borderOpacity: 0.08,
                      backgroundOpacity: 0.04,
                      child: Column(
                        children: [
                          BlocBuilder<LibraryCubit, LibraryState>(
                            builder: (context, libraryState) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.sync_rounded, color: colors.primary),
                                title: const Text('Auto-Scan on Startup', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('Scan device for new music when app opens'),
                                trailing: Switch(
                                  value: libraryState.autoScan,
                                  onChanged: (val) {
                                    context.read<LibraryCubit>().setAutoScan(val);
                                  },
                                  activeThumbColor: colors.primary,
                                ),
                              );
                            },
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          BlocBuilder<LibraryCubit, LibraryState>(
                            builder: (context, libraryState) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.youtube_searched_for_rounded, color: colors.primary),
                                title: const Text('Scan Library Now', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: const Text('Search device for new audio tracks manually'),
                                trailing: libraryState.isScanning
                                    ? SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(colors.primary),
                                        ),
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.play_arrow_rounded, color: colors.primary),
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
                              );
                            },
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          BlocBuilder<LibraryCubit, LibraryState>(
                            builder: (context, libraryState) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.folder_special_rounded, color: colors.primary),
                                title: const Text('Included Folders', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  libraryState.includedFolders.isEmpty
                                      ? 'All music folders are scanned'
                                      : '${libraryState.includedFolders.length} folders restricted',
                                ),
                                trailing: Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
                                onTap: () => _showFolderManagementBottomSheet(context, isExcluded: false),
                              );
                            },
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          BlocBuilder<LibraryCubit, LibraryState>(
                            builder: (context, libraryState) {
                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: Icon(Icons.folder_off_rounded, color: colors.primary),
                                title: const Text('Excluded Folders', style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  '${libraryState.excludedFolders.length} folders ignored',
                                ),
                                trailing: Icon(Icons.chevron_right_rounded, color: colors.onSurfaceVariant),
                                onTap: () => _showFolderManagementBottomSheet(context, isExcluded: true),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  _buildSectionHeader(context, 'Tab Management'),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
                    child: Text(
                      'Drag the icons to reorder navigation tabs or toggle the switches to show/hide them.',
                      style: textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    child: GlassmorphicContainer(
                      borderRadius: BorderRadius.circular(16),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      borderOpacity: 0.08,
                      backgroundOpacity: 0.04,
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.allTabs.length,
                        itemBuilder: (context, index) {
                          final tabName = state.allTabs[index];
                          final isVisible = state.tabVisibility[tabName] ?? false;

                          IconData tabIcon = Icons.music_note_rounded;
                          if (tabName == 'Songs') tabIcon = Icons.music_note_rounded;
                          if (tabName == 'Artists') tabIcon = Icons.person_rounded;
                          if (tabName == 'Folders') tabIcon = Icons.folder_rounded;
                          if (tabName == 'Playlists') tabIcon = Icons.queue_music_rounded;
                          if (tabName == 'Albums') tabIcon = Icons.album_rounded;
                          if (tabName == 'Favorites') tabIcon = Icons.favorite_rounded;

                          return ListTile(
                            key: ValueKey(tabName),
                            leading: Icon(Icons.drag_indicator_rounded, color: colors.onSurfaceVariant),
                            title: Row(
                              children: [
                                Icon(tabIcon, color: colors.primary, size: 20),
                                const SizedBox(width: 12),
                                Text(tabName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              ],
                            ),
                            trailing: Switch(
                              value: isVisible,
                              onChanged: (val) {
                                settingsCubit.toggleTabVisibility(tabName, val);
                              },
                              activeThumbColor: colors.primary,
                            ),
                          );
                        },
                        onReorderItem: (oldIdx, newIdx) {
                          settingsCubit.reorderTabs(oldIdx, newIdx);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 140),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showFolderManagementBottomSheet(BuildContext context, {required bool isExcluded}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return BlocBuilder<LibraryCubit, LibraryState>(
              builder: (context, libState) {
                final folders = isExcluded ? libState.excludedFolders : libState.includedFolders;
                
                return Container(
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHigh.withValues(alpha: 0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border(
                      top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.2)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: colors.onSurfaceVariant.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isExcluded ? 'Excluded Folders' : 'Included Folders',
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                        child: Text(
                          isExcluded
                              ? 'Songs inside these folders will be ignored and hidden from your library.'
                              : 'Only songs inside these folders will be scanned and shown in your library.',
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: folders.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isExcluded ? Icons.folder_open_rounded : Icons.folder_copy_rounded,
                                        size: 64,
                                        color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        isExcluded ? 'No folders excluded' : 'No folder restrictions',
                                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        isExcluded
                                            ? 'All folders containing music on your device are being scanned.'
                                            : 'The entire device is scanned. Add folders to restrict the library.',
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                controller: scrollController,
                                itemCount: folders.length,
                                itemBuilder: (context, index) {
                                  final folderPath = folders[index];
                                  final folderName = folderPath.split('/').last;

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                                    leading: CircleAvatar(
                                      backgroundColor: colors.primaryContainer.withValues(alpha: 0.2),
                                      child: Icon(Icons.folder_rounded, color: colors.primary),
                                    ),
                                    title: Text(folderName, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text(folderPath, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                      onPressed: () {
                                        if (isExcluded) {
                                          context.read<LibraryCubit>().removeExcludedFolder(folderPath);
                                        } else {
                                          context.read<LibraryCubit>().removeIncludedFolder(folderPath);
                                        }
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: FilledButton.icon(
                            onPressed: () => _showAddFolderDialog(context, isExcluded: isExcluded),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Folder', style: TextStyle(fontWeight: FontWeight.bold)),
                            style: FilledButton.styleFrom(
                              backgroundColor: colors.primary,
                              foregroundColor: colors.onPrimary,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddFolderDialog(BuildContext parentContext, {required bool isExcluded}) {
    final libraryCubit = parentContext.read<LibraryCubit>();
    final allDetected = libraryCubit.getDetectedFolders();
    final currentList = isExcluded ? libraryCubit.state.excludedFolders : libraryCubit.state.includedFolders;
    final available = allDetected.where((folder) => !currentList.contains(folder)).toList();

    showDialog(
      context: parentContext,
      builder: (context) {
        final theme = Theme.of(context);
        final colors = theme.colorScheme;

        return AlertDialog(
          backgroundColor: colors.surfaceContainerHigh,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isExcluded ? 'Exclude a Folder' : 'Include a Folder',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: available.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.info_outline_rounded, size: 48, color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
                        const SizedBox(height: 16),
                        Text(
                          'No folders available',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          allDetected.isEmpty 
                              ? 'No folders have been detected on the device yet. Please run a music scan first.'
                              : 'All detected folders are already added.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: available.length,
                    itemBuilder: (context, index) {
                      final path = available[index];
                      final name = path.split('/').last;

                      return ListTile(
                        leading: Icon(Icons.folder_rounded, color: colors.primary),
                        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(path, style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant), maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () {
                          if (isExcluded) {
                            libraryCubit.addExcludedFolder(path);
                          } else {
                            libraryCubit.addIncludedFolder(path);
                          }
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
