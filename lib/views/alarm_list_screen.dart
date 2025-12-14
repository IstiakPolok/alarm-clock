import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/alarm_controller.dart';
import '../models/alarm_model.dart';
import 'add_alarm_screen.dart';

class AlarmListScreen extends StatelessWidget {
  final AlarmController controller = Get.put(AlarmController());

  AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alarm Clock'),
        centerTitle: true,
        elevation: 2,
      ),
      body: Obx(() {
        if (controller.alarms.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.alarm_off, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No Alarms Set',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: controller.alarms.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final alarm = controller.alarms[index];
            return AlarmTile(alarm: alarm);
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddAlarmScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AlarmTile extends StatelessWidget {
  final AlarmModel alarm;
  final AlarmController controller = Get.find();

  AlarmTile({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Get.to(() => AddAlarmScreen(existingAlarm: alarm));
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        DateFormat('hh:mm a').format(alarm.time),
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: alarm.isEnabled ? Colors.black : Colors.grey,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            alarm.label,
            style: TextStyle(
              fontSize: 14,
              color: alarm.isEnabled ? Colors.black87 : Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _getRepeatText(alarm.repeatDays),
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: alarm.isEnabled,
            onChanged: (val) {
              final newAlarm = alarm.copyWith(isEnabled: val);
              controller.updateAlarm(newAlarm);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: const Text('Are you sure you want to delete this alarm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteAlarm(alarm.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _getRepeatText(List<bool> repeatDays) {
    if (repeatDays.every((element) => !element)) return 'Once';
    if (repeatDays.every((element) => element)) return 'Everyday';

    // Check if Weekdays (Mon-Fri)
    bool isWeekdays = true;
    for (int i = 0; i < 5; i++) {
      if (!repeatDays[i]) isWeekdays = false;
    }
    for (int i = 5; i < 7; i++) {
      if (repeatDays[i]) isWeekdays = false;
    }
    if (isWeekdays) return 'Weekdays';

    // Check if Weekends (Sat-Sun)
    bool isWeekends = true;
    for (int i = 0; i < 5; i++) {
      if (repeatDays[i]) isWeekends = false;
    }
    if (!repeatDays[5] || !repeatDays[6]) isWeekends = false;
    if (isWeekends) return 'Weekends';

    // Show individual days
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    List<String> activeDays = [];
    for (int i = 0; i < 7; i++) {
      if (repeatDays[i]) activeDays.add(days[i]);
    }
    return activeDays.join(', ');
  }
}
