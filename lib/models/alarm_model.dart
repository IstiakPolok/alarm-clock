class AlarmModel {
  final String id;
  final DateTime time;
  final List<bool> repeatDays; // Mon-Sun (7 days)
  final bool isEnabled;
  final bool snoozeEnabled;
  final String soundPath;
  final String label;

  AlarmModel({
    required this.id,
    required this.time,
    required this.repeatDays,
    this.isEnabled = true,
    this.snoozeEnabled = true,
    this.soundPath = 'assets/sounds/default_alarm.mp3',
    this.label = 'Alarm',
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'repeatDays': repeatDays,
      'isEnabled': isEnabled,
      'snoozeEnabled': snoozeEnabled,
      'soundPath': soundPath,
      'label': label,
    };
  }

  // Create from JSON
  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'],
      time: DateTime.parse(json['time']),
      repeatDays: List<bool>.from(json['repeatDays']),
      isEnabled: json['isEnabled'] ?? true,
      snoozeEnabled: json['snoozeEnabled'] ?? true,
      soundPath: json['soundPath'] ?? 'assets/sounds/default_alarm.mp3',
      label: json['label'] ?? 'Alarm',
    );
  }

  // Create a copy with updated fields
  AlarmModel copyWith({
    String? id,
    DateTime? time,
    List<bool>? repeatDays,
    bool? isEnabled,
    bool? snoozeEnabled,
    String? soundPath,
    String? label,
  }) {
    return AlarmModel(
      id: id ?? this.id,
      time: time ?? this.time,
      repeatDays: repeatDays ?? this.repeatDays,
      isEnabled: isEnabled ?? this.isEnabled,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      soundPath: soundPath ?? this.soundPath,
      label: label ?? this.label,
    );
  }
}
