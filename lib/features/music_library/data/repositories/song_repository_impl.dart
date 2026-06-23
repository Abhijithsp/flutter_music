import '../../domain/entities/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../datasources/local_song_datasource.dart';

class SongRepositoryImpl implements SongRepository {
  final LocalSongDatasource _datasource;

  SongRepositoryImpl(this._datasource);

  @override
  Future<List<Song>> getSongs() {
    return _datasource.getLocalSongs();
  }
}
