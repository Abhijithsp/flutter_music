import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/permissions/permission_service.dart';
import '../../domain/entities/song.dart';
import '../../domain/usecases/get_all_songs.dart';
import 'library_state.dart';

class LibraryCubit extends Cubit<LibraryState> {
  final GetAllSongs getAllSongs;
  final PermissionService permissionService;
  final SharedPreferences prefs;
  List<Song> _unfilteredSongs = [];

  LibraryCubit({
    required this.getAllSongs,
    required this.permissionService,
    required this.prefs,
  }) : super(const LibraryState()) {
    _init();
  }

  void _init() {
    final autoScan = prefs.getBool('library_auto_scan') ?? true;
    final excluded = prefs.getStringList('library_excluded_folders') ?? [];
    final included = prefs.getStringList('library_included_folders') ?? [];
    
    // Load cached songs
    List<Song> cachedSongs = [];
    final songsJson = prefs.getString('library_cached_songs');
    if (songsJson != null) {
      try {
        final List<dynamic> decoded = jsonDecode(songsJson);
        cachedSongs = decoded.map((item) => Song.fromJson(item as Map<String, dynamic>)).toList();
      } catch (_) {}
    }
    
    _unfilteredSongs = List<Song>.from(cachedSongs);

    emit(state.copyWith(
      autoScan: autoScan,
      excludedFolders: excluded,
      includedFolders: included,
      songs: cachedSongs,
      status: cachedSongs.isNotEmpty ? LibraryStatus.success : LibraryStatus.initial,
    ));

    // Auto-scan on startup
    if (autoScan || cachedSongs.isEmpty) {
      Future.delayed(Duration.zero, () => loadSongs());
    }
  }

  Future<void> loadSongs({bool forceScan = false}) async {
    if (state.isScanning) return;

    final hasPermission = await permissionService.requestStoragePermission();
    if (!hasPermission) {
      emit(state.copyWith(
        status: state.songs.isEmpty ? LibraryStatus.permissionDenied : state.status,
        isScanning: false,
      ));
      return;
    }

    // If not forced and we already have songs, skip full query
    if (!forceScan && state.songs.isNotEmpty && _unfilteredSongs.isNotEmpty) {
      return;
    }

    emit(state.copyWith(
      status: state.songs.isEmpty ? LibraryStatus.loading : state.status,
      isScanning: true,
    ));

    try {
      final songs = await getAllSongs();
      _unfilteredSongs = songs;

      final filteredSongs = _filterSongs(songs, state.includedFolders, state.excludedFolders);
      
      // Save to cache
      final songsJson = jsonEncode(filteredSongs.map((s) => s.toJson()).toList());
      await prefs.setString('library_cached_songs', songsJson);

      emit(state.copyWith(
        status: LibraryStatus.success,
        songs: filteredSongs,
        isScanning: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: state.songs.isEmpty ? LibraryStatus.failure : state.status,
        errorMessage: e.toString(),
        isScanning: false,
      ));
    }
  }

  Future<void> setAutoScan(bool enabled) async {
    await prefs.setBool('library_auto_scan', enabled);
    emit(state.copyWith(autoScan: enabled));
    if (enabled) {
      loadSongs(forceScan: true);
    }
  }

  Future<void> addExcludedFolder(String path) async {
    final list = List<String>.from(state.excludedFolders);
    if (!list.contains(path)) {
      list.add(path);
      await prefs.setStringList('library_excluded_folders', list);
      emit(state.copyWith(excludedFolders: list));
      await _reapplyFilters();
    }
  }

  Future<void> removeExcludedFolder(String path) async {
    final list = List<String>.from(state.excludedFolders);
    if (list.remove(path)) {
      await prefs.setStringList('library_excluded_folders', list);
      emit(state.copyWith(excludedFolders: list));
      await _reapplyFilters();
    }
  }

  Future<void> addIncludedFolder(String path) async {
    final list = List<String>.from(state.includedFolders);
    if (!list.contains(path)) {
      list.add(path);
      await prefs.setStringList('library_included_folders', list);
      emit(state.copyWith(includedFolders: list));
      await _reapplyFilters();
    }
  }

  Future<void> removeIncludedFolder(String path) async {
    final list = List<String>.from(state.includedFolders);
    if (list.remove(path)) {
      await prefs.setStringList('library_included_folders', list);
      emit(state.copyWith(includedFolders: list));
      await _reapplyFilters();
    }
  }

  Future<void> _reapplyFilters() async {
    if (_unfilteredSongs.isEmpty) {
      await loadSongs(forceScan: true);
      return;
    }
    final filteredSongs = _filterSongs(_unfilteredSongs, state.includedFolders, state.excludedFolders);
    
    final songsJson = jsonEncode(filteredSongs.map((s) => s.toJson()).toList());
    await prefs.setString('library_cached_songs', songsJson);

    emit(state.copyWith(
      songs: filteredSongs,
    ));
  }

  List<Song> _filterSongs(List<Song> songs, List<String> included, List<String> excluded) {
    return songs.where((song) {
      final filePath = song.path ?? '';
      if (filePath.isEmpty) return true; // Keep mock songs or online songs
      
      final normalizedPath = filePath.replaceAll('\\', '/');
      final parentPath = _getParentFolderPath(normalizedPath);
      
      // Excluded folders check (prefix match)
      for (final excludedPath in excluded) {
        final normalizedExcluded = excludedPath.replaceAll('\\', '/');
        if (parentPath == normalizedExcluded || parentPath.startsWith('$normalizedExcluded/')) {
          return false;
        }
      }
      
      // Included folders check
      if (included.isNotEmpty) {
        bool isIncluded = false;
        for (final includedPath in included) {
          final normalizedIncluded = includedPath.replaceAll('\\', '/');
          if (parentPath == normalizedIncluded || parentPath.startsWith('$normalizedIncluded/')) {
            isIncluded = true;
            break;
          }
        }
        if (!isIncluded) return false;
      }
      
      return true;
    }).toList();
  }

  String _getParentFolderPath(String filePath) {
    if (filePath.isEmpty) return '';
    final parts = filePath.split('/');
    if (parts.length <= 1) return '';
    return parts.sublist(0, parts.length - 1).join('/');
  }

  List<String> getDetectedFolders() {
    final folders = <String>{};
    for (final song in _unfilteredSongs) {
      final filePath = song.path ?? '';
      if (filePath.isNotEmpty) {
        final parent = _getParentFolderPath(filePath.replaceAll('\\', '/'));
        if (parent.isNotEmpty) {
          folders.add(parent);
        }
      }
    }
    return folders.toList()..sort();
  }
}
