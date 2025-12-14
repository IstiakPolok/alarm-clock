import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../models/alarm_model.dart';
import 'notification_service.dart';
import 'audio_service.dart';

class AlarmScheduler {
  static final AlarmScheduler _instance = AlarmScheduler._internal();
  factory AlarmScheduler() => _instance;
  AlarmScheduler._internal();

  // Initialize alarm manager
  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
  }

  // Schedule an alarm
  Future<void> scheduleAlarm(AlarmModel alarm) async {
    if (!alarm.isEnabled) {
      await cancelAlarm(alarm.id);
      return;
    }

    final now = DateTime.now();
    DateTime scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    // If the alarm time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Check if this is a repeating alarm
    final isRepeating = alarm.repeatDays.any((day) => day);

    if (isRepeating) {
      // For repeating alarms, schedule periodic alarm
      await AndroidAlarmManager.periodic(
        const Duration(days: 1),
        alarm.id.hashCode,
        _alarmCallback,
        startAt: scheduledTime,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: alarm.toJson(),
      );
    } else {
      // For one-time alarms
      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        alarm.id.hashCode,
        _alarmCallback,
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
        params: alarm.toJson(),
      );
    }

    print('Alarm scheduled for: $scheduledTime');
  }

  // Cancel an alarm
  Future<void> cancelAlarm(String alarmId) async {
    await AndroidAlarmManager.cancel(alarmId.hashCode);
    print('Alarm cancelled: $alarmId');
  }

  // Callback function that runs when alarm triggers
  // This must be a top-level or static function
  @pragma('vm:entry-point')
  static Future<void> _alarmCallback(
    int id,
    Map<String, dynamic> params,
  ) async {
    print('Alarm triggered! ID: $id');

    try {
      // Create alarm model from params
      final alarm = AlarmModel.fromJson(params);

      // Check if alarm should trigger today (for repeating alarms)
      if (!_shouldTriggerToday(alarm)) {
        print('Alarm skipped - not scheduled for today');
        return;
      }

      // Show notification
      final notificationService = NotificationService();
      await notificationService.initializeForBackground();
      await notificationService.showAlarmNotification(
        id: id,
        title: alarm.label,
        body: 'Time to wake up!',
      );

      // Play alarm sound
      final audioService = AudioService();
      await audioService.playAlarm(alarm.soundPath);

      // Auto-stop alarm after 5 minutes if not stopped manually
      Future.delayed(const Duration(minutes: 5), () async {
        await audioService.stop();
      });
    } catch (e) {
      print('Error in alarm callback: $e');
    }
  }

  // Check if alarm should trigger today based on repeat days
  static bool _shouldTriggerToday(AlarmModel alarm) {
    final now = DateTime.now();
    final weekday = now.weekday; // 1 = Monday, 7 = Sunday

    // Convert to our format (0 = Monday, 6 = Sunday)
    final dayIndex = weekday - 1;

    // If no repeat days are set, it's a one-time alarm
    if (alarm.repeatDays.every((day) => !day)) {
      return true;
    }

    // Check if today is in the repeat days
    return alarm.repeatDays[dayIndex];
  }

  // Snooze alarm (reschedule for 5 minutes later)
  Future<void> snoozeAlarm(AlarmModel alarm) async {
    final snoozeTime = DateTime.now().add(const Duration(minutes: 5));

    await AndroidAlarmManager.oneShotAt(
      snoozeTime,
      alarm.id.hashCode,
      _alarmCallback,
      exact: true,
      wakeup: true,
      params: alarm.toJson(),
    );

    print('Alarm snoozed until: $snoozeTime');
  }
}
