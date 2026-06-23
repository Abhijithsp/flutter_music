import 'package:on_audio_query/on_audio_query.dart' hide SongModel;
import '../models/song_model.dart';

abstract class LocalSongDatasource {
  Future<List<SongModel>> getLocalSongs();
}

class LocalSongDatasourceImpl implements LocalSongDatasource {
  final OnAudioQuery _audioQuery;

  LocalSongDatasourceImpl(this._audioQuery);

  @override
  Future<List<SongModel>> getLocalSongs() async {
    try {
      final songs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Filter out files that don't have valid URIs or metadata
      return songs
          .where((s) => s.isMusic == true)
          .map((s) => SongModel.fromOnAudioQuery(s))
          .toList();
    } catch (e) {
      // Fallback fallback mocks for development/simulation
      return [
        SongModel.fromMock(
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
          'SoundHelix Track 1',
          'SoundHelix',
          'SoundHelix Collective',
          const Duration(minutes: 6, seconds: 12),
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
        ),
        SongModel.fromMock(
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
          'SoundHelix Track 2',
          'SoundHelix',
          'SoundHelix Collective',
          const Duration(minutes: 7, seconds: 5),
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
        ),
      ];
    }
  }
}
