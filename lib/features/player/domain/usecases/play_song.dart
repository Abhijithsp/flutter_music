import '../../../music_library/domain/entities/song.dart';
import '../repositories/player_repository.dart';

class PlaySong {
  final PlayerRepository _repository;

  PlaySong(this._repository);

  Future<void> call({Song? song, List<Song>? playlist}) {
    if (song != null && playlist != null) {
      return _repository.playSong(song, playlist);
    }
    return _repository.play();
  }
}
