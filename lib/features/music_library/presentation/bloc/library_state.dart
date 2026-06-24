import '../../domain/entities/song.dart';

enum LibraryStatus { initial, loading, success, failure, permissionDenied }

class LibraryState {
  final LibraryStatus status;
  final List<Song> songs;
  final String? errorMessage;
  final bool isScanning;
  final List<String> excludedFolders;
  final List<String> includedFolders;
  final bool autoScan;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.songs = const [],
    this.errorMessage,
    this.isScanning = false,
    this.excludedFolders = const [],
    this.includedFolders = const [],
    this.autoScan = true,
  });

  LibraryState copyWith({
    LibraryStatus? status,
    List<Song>? songs,
    String? errorMessage,
    bool? isScanning,
    List<String>? excludedFolders,
    List<String>? includedFolders,
    bool? autoScan,
  }) {
    return LibraryState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      errorMessage: errorMessage ?? this.errorMessage,
      isScanning: isScanning ?? this.isScanning,
      excludedFolders: excludedFolders ?? this.excludedFolders,
      includedFolders: includedFolders ?? this.includedFolders,
      autoScan: autoScan ?? this.autoScan,
    );
  }
}
