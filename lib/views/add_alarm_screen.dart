import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/alarm_controller.dart';
import '../models/alarm_model.dart';

class AddAlarmScreen extends StatefulWidget {
  final AlarmModel? existingAlarm;

  const AddAlarmScreen({super.key, this.existingAlarm});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  final AlarmController controller = Get.find();

  late DateTime selectedTime;
  late List<bool> repeatDays;
  late bool snoozeEnabled;
  late String label;
  late TextEditingController labelController;

  @override
  void initState() {
    super.initState();

    // Initialize with existing alarm data or defaults
    if (widget.existingAlarm != null) {
      selectedTime = widget.existingAlarm!.time;
      repeatDays = List.from(widget.existingAlarm!.repeatDays);
      snoozeEnabled = widget.existingAlarm!.snoozeEnabled;
      label = widget.existingAlarm!.label;
    } else {
      final now = DateTime.now();
      selectedTime = DateTime(now.year, now.month, now.day, 7, 0);
      repeatDays = List.filled(7, false);
      snoozeEnabled = true;
      label = 'Alarm';
    }

    labelController = TextEditingController(text: label);
  }

  @override
  void dispose() {
    labelController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedTime),
    );

    if (picked != null) {
      setState(() {
        selectedTime = DateTime(
          selectedTime.year,
          selectedTime.month,
          selectedTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _saveAlarm() {
    final alarm = AlarmModel(
      id:
          widget.existingAlarm?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      time: selectedTime,
      repeatDays: repeatDays,
      isEnabled: true,
      snoozeEnabled: snoozeEnabled,
      label: labelController.text.isEmpty ? 'Alarm' : labelController.text,
    );

    if (widget.existingAlarm != null) {
      controller.updateAlarm(alarm);
    } else {
      controller.addAlarm(alarm);
    }

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingAlarm != null ? 'Edit Alarm' : 'Add Alarm'),
        actions: [
          TextButton(
            onPressed: _saveAlarm,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time Picker
          Card(
            elevation: 2,
            child: InkWell(
              onTap: _selectTime,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Text(
                      'Alarm Time',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('hh:mm a').format(selectedTime),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Label Input
          TextField(
            controller: labelController,
            decoration: const InputDecoration(
              labelText: 'Label',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label),
            ),
          ),

          const SizedBox(height: 24),

          // Repeat Days
          const Text(
            'Repeat',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildRepeatDaysSelector(),

          const SizedBox(height: 24),

          // Snooze Toggle
          Card(
            elevation: 1,
            child: SwitchListTile(
              title: const Text('Snooze'),
              subtitle: const Text('Allow 5-minute snooze'),
              value: snoozeEnabled,
              onChanged: (value) {
                setState(() {
                  snoozeEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 24),

          // Cancel Button
          OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Cancel', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatDaysSelector() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(7, (index) {
        return GestureDetector(
          onTap: () {
            setState(() {
              repeatDays[index] = !repeatDays[index];
            });
          },
          child: CircleAvatar(
            radius: 24,
            backgroundColor: repeatDays[index]
                ? Theme.of(context).primaryColor
                : Colors.grey[300],
            child: Text(
              days[index].substring(0, 1),
              style: TextStyle(
                color: repeatDays[index] ? Colors.white : Colors.black54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
