import '../../domain/entities/song.dart';

enum LibraryStatus { initial, loading, success, failure, permissionDenied }

class LibraryState {
  final LibraryStatus status;
  final List<Song> songs;
  final String? errorMessage;

  const LibraryState({
    this.status = LibraryStatus.initial,
    this.songs = const [],
    this.errorMessage,
  });

  LibraryState copyWith({
    LibraryStatus? status,
    List<Song>? songs,
    String? errorMessage,
  }) {
    return LibraryState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
