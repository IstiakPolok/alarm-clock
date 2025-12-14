import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/alarm_model.dart';

class StorageService {
  static const String _alarmsKey = 'alarms';

  // Save all alarms to local storage
  Future<void> saveAlarms(List<AlarmModel> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = alarms.map((alarm) => alarm.toJson()).toList();
    await prefs.setString(_alarmsKey, jsonEncode(alarmsJson));
  }

  // Load all alarms from local storage
  Future<List<AlarmModel>> loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsString = prefs.getString(_alarmsKey);

    if (alarmsString == null || alarmsString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> alarmsJson = jsonDecode(alarmsString);
      return alarmsJson.map((json) => AlarmModel.fromJson(json)).toList();
    } catch (e) {
      print('Error loading alarms: $e');
      return [];
    }
  }

  // Clear all alarms
  Future<void> clearAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_alarmsKey);
  }
}
