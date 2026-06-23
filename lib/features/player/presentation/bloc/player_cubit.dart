import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../music_library/domain/entities/song.dart';
import '../../domain/repositories/player_repository.dart';
import '../../domain/usecases/next_song.dart';
import '../../domain/usecases/pause_song.dart';
import '../../domain/usecases/play_song.dart';
import '../../domain/usecases/previous_song.dart';
import 'player_state.dart';

class PlayerCubit extends Cubit<PlayerState> {
  final PlaySong _playSong;
  final PauseSong _pauseSong;
  final NextSong _nextSong;
  final PreviousSong _previousSong;
  final PlayerRepository _playerRepository;

  StreamSubscription? _playbackStateSub;
  StreamSubscription? _mediaItemSub;
  StreamSubscription? _queueSub;

  PlayerCubit({
    required this._playSong,
    required this._pauseSong,
    required this._nextSong,
    required this._previousSong,
    required this._playerRepository,
  }) : super(const PlayerState()) {
    _subscribeToPlaybackStreams();
  }

  void _subscribeToPlaybackStreams() {
    _playbackStateSub = _playerRepository.playbackState.listen((playbackState) {
      emit(state.copyWith(
        isPlaying: playbackState.playing,
        playbackState: playbackState,
      ));
    });

    _mediaItemSub = _playerRepository.currentMediaItem.listen((item) {
      emit(state.copyWith(currentTrack: item));
    });

    _queueSub = _playerRepository.queue.listen((queue) {
      emit(state.copyWith(queue: queue));
    });
  }

  Future<void> playSongItem(Song song, List<Song> playlist) =>
      _playSong(song: song, playlist: playlist);

  Future<void> togglePlay() {
    if (state.isPlaying) {
      return _pauseSong();
    } else {
      return _playSong();
    }
  }

  Future<void> next() => _nextSong();

  Future<void> previous() => _previousSong();

  Future<void> seek(Duration position) => _playerRepository.seek(position);

  @override
  Future<void> close() {
    _playbackStateSub?.cancel();
    _mediaItemSub?.cancel();
    _queueSub?.cancel();
    return super.close();
  }
}
