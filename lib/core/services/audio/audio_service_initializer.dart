import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import '../../constants/audio_constants.dart';
import 'audio_handler.dart';

class AudioServiceInitializer {
  static Future<AudioHandler> init() async {
    // Configure the audio session for music playback (handles audio focus,
    // interruptions from calls, etc.)
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    return await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: AudioConstants.notificationChannelId,
        androidNotificationChannelName: AudioConstants.notificationChannelName,
        // Keep notification alive – critical for Nothing Phone and other aggressive
        // battery OEMs. androidNotificationOngoing:false + androidStopForegroundOnPause:false
        // is a valid combination that keeps the service in the foreground even when paused.
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: false,
        androidShowNotificationBadge: true,
        // Small monochrome or default verified launcher icon
        androidNotificationIcon: 'drawable/ic_stat_music',
      ),
    );
  }
}
