import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  MyAudioHandler() {
    _init();
  }

  void _init() {
    // ── 1. Sync just_audio sequence → audio_service queue + mediaItem ────────
    // sequenceStateStream is the authoritative source of truth for the current
    // playlist and track. Piping it to audio_service drives the OS notification.
    _player.sequenceStateStream.listen((state) {
      try {
        final items = state.effectiveSequence
            .map((src) => src.tag)
            .whereType<MediaItem>()
            .toList();
        queue.add(items);

        // currentIndex is nullable in just_audio 0.10+
        final idx = state.currentIndex;
        if (idx != null && idx >= 0 && idx < items.length) {
          mediaItem.add(items[idx]);
        }
      } catch (_) {}
    });

    // ── 2. Forward all player state changes → OS notification ─────────────
    _player.playbackEventStream.listen((_) => _broadcastState());
    _player.playerStateStream.listen((_) => _broadcastState());
    _player.shuffleModeEnabledStream.listen((_) => _broadcastState());
    _player.loopModeStream.listen((_) => _broadcastState());

    // Auto-advance on track completion
    _player.processingStateStream.listen((state) {
      _broadcastState();
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });

    // Emit an initial idle state immediately
    _broadcastState();
  }

  /// Publishes the current just_audio state to audio_service so the OS
  /// notification and lock-screen media controls stay in sync.
  void _broadcastState() {
    final playing = _player.playing;
    final processingState = {
      ProcessingState.idle: AudioProcessingState.idle,
      ProcessingState.loading: AudioProcessingState.loading,
      ProcessingState.buffering: AudioProcessingState.buffering,
      ProcessingState.ready: AudioProcessingState.ready,
      ProcessingState.completed: AudioProcessingState.completed,
    }[_player.processingState] ??
        AudioProcessingState.idle;

    playbackState.add(PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
      },
      // Indices into controls[] visible in compact notification view
      androidCompactActionIndices: const [0, 1, 3],
      processingState: processingState,
      playing: playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _player.currentIndex,
      shuffleMode: _player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: {
        LoopMode.off: AudioServiceRepeatMode.none,
        LoopMode.one: AudioServiceRepeatMode.one,
        LoopMode.all: AudioServiceRepeatMode.all,
      }[_player.loopMode] ??
          AudioServiceRepeatMode.none,
    ));
  }

  /// Loads a fresh playlist. MediaItems are stored in AudioSource.tag so
  /// sequenceStateStream can automatically push them back to audio_service.
  Future<void> loadPlaylist(List<MediaItem> items) async {
    final sources = items
        .map((item) => AudioSource.uri(Uri.parse(item.id), tag: item))
        .toList();

    // setAudioSources is the modern API in just_audio 0.10+
    await _player.setAudioSources(sources);
    queue.add(items);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) => loadPlaylist(queue);

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
    // Push metadata immediately so the notification renders during load
    this.mediaItem.add(mediaItem);

    final index = queue.value.indexWhere((q) => q.id == mediaItem.id);
    if (index != -1) {
      await skipToQueueItem(index);
    } else {
      final updated = List<MediaItem>.from(queue.value)..add(mediaItem);
      await loadPlaylist(updated);
      await skipToQueueItem(updated.length - 1);
    }
    await play();
  }

  // ── Passthrough controls ──────────────────────────────────────────────────

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index >= 0 && index < queue.value.length) {
      mediaItem.add(queue.value[index]);
      await _player.seek(Duration.zero, index: index);
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enabled = shuffleMode == AudioServiceShuffleMode.all;
    await _player.setShuffleModeEnabled(enabled);
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final mode = {
      AudioServiceRepeatMode.none: LoopMode.off,
      AudioServiceRepeatMode.one: LoopMode.one,
      AudioServiceRepeatMode.all: LoopMode.all,
      AudioServiceRepeatMode.group: LoopMode.all,
    }[repeatMode]!;
    await _player.setLoopMode(mode);
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }
}
