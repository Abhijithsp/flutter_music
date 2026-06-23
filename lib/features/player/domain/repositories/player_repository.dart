import 'package:audio_service/audio_service.dart';
import '../../../music_library/domain/entities/song.dart';

abstract class PlayerRepository {
  Stream<PlaybackState> get playbackState;
  Stream<MediaItem?> get currentMediaItem;
  Stream<List<MediaItem>> get queue;

  Future<void> play();
  Future<void> pause();
  Future<void> seek(Duration position);
  Future<void> skipToNext();
  Future<void> skipToPrevious();
  Future<void> playSong(Song song, List<Song> playlist);
}
