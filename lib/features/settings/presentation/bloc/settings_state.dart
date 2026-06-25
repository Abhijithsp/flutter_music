import 'package:flutter/material.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Color accentColor;
  final String themePresetName;
  final String previewPresetName;
  final ThemeMode previewThemeMode;
  final String viewPreference;
  final String defaultStartupScreen;
  final List<String> visibleTabs;
  final List<String> allTabs;
  final Map<String, bool> tabVisibility;
  final String appIcon;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.accentColor = const Color(0xFF1E1E22), // Default Ink Wash
    this.themePresetName = 'Ink Wash',
    this.previewPresetName = 'Ink Wash',
    this.previewThemeMode = ThemeMode.dark,
    this.viewPreference = 'list',
    this.defaultStartupScreen = 'Home',
    this.visibleTabs = const ['Home', 'Songs', 'Artists', 'Folders', 'Playlists', 'Settings'],
    this.allTabs = const ['Songs', 'Artists', 'Folders', 'Playlists', 'Albums', 'Favorites'],
    this.tabVisibility = const {
      'Songs': true,
      'Artists': true,
      'Folders': true,
      'Playlists': true,
      'Albums': false,
      'Favorites': false,
    },
    this.appIcon = 'Default',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? accentColor,
    String? themePresetName,
    String? previewPresetName,
    ThemeMode? previewThemeMode,
    String? viewPreference,
    String? defaultStartupScreen,
    List<String>? visibleTabs,
    List<String>? allTabs,
    Map<String, bool>? tabVisibility,
    String? appIcon,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      accentColor: accentColor ?? this.accentColor,
      themePresetName: themePresetName ?? this.themePresetName,
      previewPresetName: previewPresetName ?? this.previewPresetName,
      previewThemeMode: previewThemeMode ?? this.previewThemeMode,
      viewPreference: viewPreference ?? this.viewPreference,
      defaultStartupScreen: defaultStartupScreen ?? this.defaultStartupScreen,
      visibleTabs: visibleTabs ?? this.visibleTabs,
      allTabs: allTabs ?? this.allTabs,
      tabVisibility: tabVisibility ?? this.tabVisibility,
      appIcon: appIcon ?? this.appIcon,
    );
  }
}

