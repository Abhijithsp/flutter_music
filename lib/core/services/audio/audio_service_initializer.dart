import 'package:audio_service/audio_service.dart';
import '../../constants/audio_constants.dart';
import 'audio_handler.dart';

class AudioServiceInitializer {
  static Future<AudioHandler> init() async {
    return await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: AudioConstants.notificationChannelId,
        androidNotificationChannelName: AudioConstants.notificationChannelName,
        androidNotificationOngoing: true,
        androidShowNotificationBadge: true,
      ),
    );
  }
}
