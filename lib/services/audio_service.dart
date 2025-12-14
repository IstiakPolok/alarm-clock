import 'package:just_audio/just_audio.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  // Play alarm sound
  Future<void> playAlarm(String soundPath) async {
    try {
      // Stop any currently playing alarm
      await stop();

      // Set the audio source
      await _audioPlayer.setAsset(soundPath);

      // Set looping mode
      await _audioPlayer.setLoopMode(LoopMode.one);

      // Set volume to maximum
      await _audioPlayer.setVolume(1.0);

      // Play the alarm
      await _audioPlayer.play();
      _isPlaying = true;

      print('Playing alarm sound: $soundPath');
    } catch (e) {
      print('Error playing alarm: $e');
    }
  }

  // Stop alarm sound
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      print('Alarm stopped');
    } catch (e) {
      print('Error stopping alarm: $e');
    }
  }

  // Dispose audio player
  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
