import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter_music/core/services/audio/audio_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const justAudioChannel = MethodChannel('com.ryanheise.just_audio.methods');
  const audioServiceChannel = MethodChannel('com.ryanheise.audioservice.methods');

  final activePlayerIds = <String>{};

  setUp(() {
    activePlayerIds.clear();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(justAudioChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'init') {
        final id = methodCall.arguments['id'] as String;
        activePlayerIds.add(id);

        final playerChannel = MethodChannel('com.ryanheise.just_audio.methods.$id');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(playerChannel, (MethodCall playerCall) async {
          if (playerCall.method == 'load') {
            return {
              'duration': 180000000,
            };
          }
          return <dynamic, dynamic>{};
        });

        final eventChannel = EventChannel('com.ryanheise.just_audio.events.$id');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(eventChannel, MockStreamHandler.inline(
          onListen: (arguments, sink) {
            sink.success({
              'processingState': 3, // ready
              'updateTime': DateTime.now().millisecondsSinceEpoch,
              'updatePosition': 0,
              'bufferedPosition': 0,
              'duration': 180000000,
              'currentIndex': 0,
            });
          },
          onCancel: (arguments) {},
        ));

        final dataChannel = EventChannel('com.ryanheise.just_audio.data.$id');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockStreamHandler(dataChannel, MockStreamHandler.inline(
          onListen: (arguments, sink) {
            sink.success({
              'volume': 1.0,
              'speed': 1.0,
              'pitch': 1.0,
              'shuffleModeEnabled': false,
              'loopMode': 0,
            });
          },
          onCancel: (arguments) {},
        ));

        return null;
      }
      if (methodCall.method == 'disposePlayer') {
        return <dynamic, dynamic>{};
      }
      if (methodCall.method == 'disposeAllPlayers') {
        return <dynamic, dynamic>{};
      }
      return null;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioServiceChannel, (MethodCall methodCall) async {
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(justAudioChannel, null);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(audioServiceChannel, null);
    for (final id in activePlayerIds) {
      final playerChannel = MethodChannel('com.ryanheise.just_audio.methods.$id');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(playerChannel, null);

      final eventChannel = EventChannel('com.ryanheise.just_audio.events.$id');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(eventChannel, null);

      final dataChannel = EventChannel('com.ryanheise.just_audio.data.$id');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockStreamHandler(dataChannel, null);
    }
  });

  group('MyAudioHandler Tests', () {
    test('should initialize and broadcast idle state', () async {
      final handler = MyAudioHandler();

      expect(handler, isNotNull);
      expect(handler.playbackState.value.playing, isFalse);
      expect(handler.playbackState.value.processingState, AudioProcessingState.idle);
      expect(handler.mediaItem.value, isNull);
    });

    test('should update mediaItem when playMediaItem is called', () async {
      final handler = MyAudioHandler();

      const testItem = MediaItem(
        id: 'content://media/external/audio/media/1',
        album: 'Test Album',
        title: 'Test Song',
        artist: 'Test Artist',
        duration: Duration(minutes: 3),
      );

      // Call playMediaItem which updates mediaItem stream
      await handler.playMediaItem(testItem);

      expect(handler.mediaItem.value, equals(testItem));
    });
  });
}
