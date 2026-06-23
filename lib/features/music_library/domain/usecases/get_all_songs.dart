import '../entities/song.dart';
import '../repositories/song_repository.dart';

class GetAllSongs {
  final SongRepository _repository;

  GetAllSongs(this._repository);

  Future<List<Song>> call() {
    return _repository.getSongs();
  }
}
