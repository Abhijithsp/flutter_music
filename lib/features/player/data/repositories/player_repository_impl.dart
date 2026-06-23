import 'package:audio_service/audio_service.dart';
import '../../../../core/services/audio/player_controller.dart';
import '../../../music_library/domain/entities/song.dart';
import '../../domain/repositories/player_repository.dart';

class PlayerRepositoryImpl implements PlayerRepository {
  final PlayerController _playerController;

  PlayerRepositoryImpl(this._playerController);

  @override
  Stream<PlaybackState> get playbackState => _playerController.playbackState;

  @override
  Stream<MediaItem?> get currentMediaItem => _playerController.currentMediaItem;

  @override
  Stream<List<MediaItem>> get queue => _playerController.queue;

  @override
  Future<void> play() => _playerController.play();

  @override
  Future<void> pause() => _playerController.pause();

  @override
  Future<void> seek(Duration position) => _playerController.seek(position);

  @override
  Future<void> skipToNext() => _playerController.skipToNext();

  @override
  Future<void> skipToPrevious() => _playerController.skipToPrevious();

  @override
  Future<void> playSong(Song song, List<Song> playlist) async {
    // Convert all domain Songs in the playlist to MediaItems
    final mediaItems = playlist.map((s) {
      return MediaItem(
        id: s.uri,
        album: s.album,
        title: s.title,
        artist: s.artist,
        duration: s.duration,
        artUri: s.artworkUri != null ? Uri.parse(s.artworkUri!) : null,
      );
    }).toList();

    // Avoid reloading the identical queue to prevent playback interruption
    final currentQueue = _playerController.currentQueue;
    bool isSameQueue = currentQueue.length == mediaItems.length;
    if (isSameQueue) {
      for (int i = 0; i < currentQueue.length; i++) {
        if (currentQueue[i].id != mediaItems[i].id) {
          isSameQueue = false;
          break;
        }
      }
    }

    if (!isSameQueue) {
      await _playerController.loadPlaylist(mediaItems);
    }

    final targetItem = mediaItems.firstWhere(
      (item) => item.id == song.uri,
      orElse: () => mediaItems.first,
    );
    await _playerController.playMediaItem(targetItem);
  }
}
