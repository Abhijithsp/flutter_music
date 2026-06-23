import '../repositories/player_repository.dart';

class NextSong {
  final PlayerRepository _repository;

  NextSong(this._repository);

  Future<void> call() {
    return _repository.skipToNext();
  }
}
