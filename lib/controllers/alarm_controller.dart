import 'package:get/get.dart';
import '../models/alarm_model.dart';
import '../services/storage_service.dart';
import '../services/alarm_scheduler.dart';

class AlarmController extends GetxController {
  final StorageService _storageService = StorageService();
  final AlarmScheduler _alarmScheduler = AlarmScheduler();

  // Observable list of alarms
  final RxList<AlarmModel> alarms = <AlarmModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAlarms();
  }

  // Load alarms from storage
  Future<void> loadAlarms() async {
    try {
      final loadedAlarms = await _storageService.loadAlarms();
      alarms.value = loadedAlarms;

      // Reschedule all enabled alarms
      for (var alarm in loadedAlarms) {
        if (alarm.isEnabled) {
          await _alarmScheduler.scheduleAlarm(alarm);
        }
      }
    } catch (e) {
      print('Error loading alarms: $e');
      Get.snackbar(
        'Error',
        'Failed to load alarms',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Add a new alarm
  Future<void> addAlarm(AlarmModel alarm) async {
    try {
      alarms.add(alarm);
      await _saveAlarms();

      // Schedule the alarm
      if (alarm.isEnabled) {
        await _alarmScheduler.scheduleAlarm(alarm);
      }

      Get.snackbar(
        'Success',
        'Alarm added successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error adding alarm: $e');
      Get.snackbar(
        'Error',
        'Failed to add alarm',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Update an existing alarm
  Future<void> updateAlarm(AlarmModel updatedAlarm) async {
    try {
      final index = alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
      if (index != -1) {
        alarms[index] = updatedAlarm;
        await _saveAlarms();

        // Reschedule the alarm
        await _alarmScheduler.scheduleAlarm(updatedAlarm);

        Get.snackbar(
          'Success',
          'Alarm updated successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('Error updating alarm: $e');
      Get.snackbar(
        'Error',
        'Failed to update alarm',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Delete an alarm
  Future<void> deleteAlarm(String alarmId) async {
    try {
      alarms.removeWhere((alarm) => alarm.id == alarmId);
      await _saveAlarms();

      // Cancel the scheduled alarm
      await _alarmScheduler.cancelAlarm(alarmId);

      Get.snackbar(
        'Success',
        'Alarm deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error deleting alarm: $e');
      Get.snackbar(
        'Error',
        'Failed to delete alarm',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Toggle alarm enabled/disabled
  Future<void> toggleAlarm(String alarmId, bool isEnabled) async {
    try {
      final index = alarms.indexWhere((alarm) => alarm.id == alarmId);
      if (index != -1) {
        final updatedAlarm = alarms[index].copyWith(isEnabled: isEnabled);
        alarms[index] = updatedAlarm;
        await _saveAlarms();

        // Schedule or cancel the alarm
        await _alarmScheduler.scheduleAlarm(updatedAlarm);
      }
    } catch (e) {
      print('Error toggling alarm: $e');
      Get.snackbar(
        'Error',
        'Failed to toggle alarm',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Save alarms to storage
  Future<void> _saveAlarms() async {
    await _storageService.saveAlarms(alarms);
  }
}
