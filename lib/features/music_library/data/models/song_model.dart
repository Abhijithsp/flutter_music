import 'package:on_audio_query/on_audio_query.dart' as query;
import '../../domain/entities/song.dart';

class SongModel extends Song {
  const SongModel({
    required super.id,
    required super.title,
    required super.artist,
    required super.album,
    required super.duration,
    required super.uri,
    super.artworkUri,
    super.path,
  });

  factory SongModel.fromOnAudioQuery(query.SongModel qSong) {
    return SongModel(
      id: qSong.id.toString(),
      title: qSong.title,
      artist: qSong.artist ?? 'Unknown Artist',
      album: qSong.album ?? 'Unknown Album',
      duration: Duration(milliseconds: qSong.duration ?? 0),
      uri: qSong.uri ?? '',
      artworkUri: null,
      path: qSong.data,
    );
  }

  factory SongModel.fromMock(
    String id,
    String title,
    String artist,
    String album,
    Duration duration,
    String uri,
  ) {
    return SongModel(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration,
      uri: uri,
      artworkUri: null,
      path: null,
    );
  }
}
