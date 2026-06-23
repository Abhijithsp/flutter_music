import '../repositories/player_repository.dart';

class PauseSong {
  final PlayerRepository _repository;

  PauseSong(this._repository);

  Future<void> call() {
    return _repository.pause();
  }
}
