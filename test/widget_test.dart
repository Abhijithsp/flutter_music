import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_music/features/music_library/domain/entities/song.dart';
import 'package:flutter_music/features/music_library/data/models/song_model.dart';

void main() {
  group('Song Entity Tests', () {
    test('Songs with the same ID should be equal', () {
      const song1 = Song(
        id: '1',
        title: 'Song One',
        artist: 'Artist One',
        album: 'Album One',
        duration: Duration(minutes: 3),
        uri: 'uri/1',
      );

      const song2 = Song(
        id: '1',
        title: 'Song One - Remastered',
        artist: 'Artist One',
        album: 'Album One',
        duration: Duration(minutes: 3),
        uri: 'uri/1',
      );

      expect(song1, equals(song2));
    });

    test('Songs with different IDs should not be equal', () {
      const song1 = Song(
        id: '1',
        title: 'Song One',
        artist: 'Artist One',
        album: 'Album One',
        duration: Duration(minutes: 3),
        uri: 'uri/1',
      );

      const song2 = Song(
        id: '2',
        title: 'Song One',
        artist: 'Artist One',
        album: 'Album One',
        duration: Duration(minutes: 3),
        uri: 'uri/1',
      );

      expect(song1, isNot(equals(song2)));
    });
  });

  group('SongModel Factory Tests', () {
    test('fromMock creates a valid SongModel', () {
      final model = SongModel.fromMock(
        '100',
        'Test Song',
        'Test Artist',
        'Test Album',
        const Duration(seconds: 180),
        'content://media/external/audio/media/100',
      );

      expect(model.id, '100');
      expect(model.title, 'Test Song');
      expect(model.artist, 'Test Artist');
      expect(model.album, 'Test Album');
      expect(model.duration, const Duration(seconds: 180));
      expect(model.uri, 'content://media/external/audio/media/100');
    });
  });
}
