import '../repositories/player_repository.dart';

class PreviousSong {
  final PlayerRepository _repository;

  PreviousSong(this._repository);

  Future<void> call() {
    return _repository.skipToPrevious();
  }
}
