import 'package:audioplayers/audioplayers.dart';

class AlarmManager {
  AlarmManager._internal();
  static final AlarmManager instance = AlarmManager._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _isAlarmPlaying = false;

  Future<void> playEmergency() async {
    if (_isAlarmPlaying) return;
    _isAlarmPlaying = true;
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.play(AssetSource('sounds/alarm_high.mp3'));
    } catch (e) {
      _isAlarmPlaying = false;
    }
  }

  Future<void> stopAlarm() async {
    if (!_isAlarmPlaying) return;
    await _player.stop();
    _isAlarmPlaying = false;
  }
}
