import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  MyAudioHandler() {
    _init();
  }

  void _init() {
    // ── 1. Sync current index and queue to mediaItem ────────────────────────
    // Combine current index stream and queue stream to keep mediaItem in sync.
    // This handles both changing tracks and loading a new playlist correctly,
    // avoiding race conditions between just_audio and audio_service.
    Rx.combineLatest2<List<MediaItem>, int?, MediaItem?>(
      queue,
      _player.currentIndexStream,
      (queueList, index) {
        if (index != null && index >= 0 && index < queueList.length) {
          return queueList[index];
        }
        return null;
      },
    ).listen((item) {
      if (item != null) {
        mediaItem.add(item);
      }
    });

    // ── 2. Forward player state changes to audio_service ───────────────────
    _player.playbackEventStream.listen((_) => _broadcastState());
    _player.playerStateStream.listen((_) => _broadcastState());
    _player.shuffleModeEnabledStream.listen((_) => _broadcastState());
    _player.loopModeStream.listen((_) => _broadcastState());

    // Auto-advance on completion
    _player.processingStateStream.listen((state) {
      _broadcastState();
      if (state == ProcessingState.completed) {
        skipToNext();
      }
    });

    _broadcastState();
  }

  /// Broadcasts the player state to audio_service to keep the OS notification in sync.
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
        MediaAction.play,
        MediaAction.pause,
        MediaAction.skipToNext,
        MediaAction.skipToPrevious,
        MediaAction.stop,
      },
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

  /// Loads the playlist into the player.
  Future<void> loadPlaylist(List<MediaItem> items) async {
    final sources = items
        .map((item) => AudioSource.uri(Uri.parse(item.id), tag: item))
        .toList();

    // Update queue first so the combined stream can emit the correct mediaItem
    // as soon as just_audio resolves the index.
    queue.add(items);

    // setAudioSources is the modern API in just_audio 0.10+
    await _player.setAudioSources(sources);
  }

  @override
  Future<void> updateQueue(List<MediaItem> queue) => loadPlaylist(queue);

  @override
  Future<void> playMediaItem(MediaItem mediaItem) async {
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
