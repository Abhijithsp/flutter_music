import 'package:audio_service/audio_service.dart';

class PlayerState {
  final bool isPlaying;
  final MediaItem? currentTrack;
  final PlaybackState? playbackState;
  final List<MediaItem> queue;

  const PlayerState({
    this.isPlaying = false,
    this.currentTrack,
    this.playbackState,
    this.queue = const [],
  });

  PlayerState copyWith({
    bool? isPlaying,
    MediaItem? currentTrack,
    PlaybackState? playbackState,
    List<MediaItem>? queue,
  }) {
    return PlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      currentTrack: currentTrack ?? this.currentTrack,
      playbackState: playbackState ?? this.playbackState,
      queue: queue ?? this.queue,
    );
  }
}
