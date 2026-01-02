import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'services/notification_service.dart';
import 'services/alarm_scheduler.dart';
import 'views/alarm_list_screen.dart';
 
void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  await _initializeServices();

  runApp(const MyApp());
}

Future<void> _initializeServices() async {
  try {
    // Initialize notification service
    await NotificationService().initialize();
    print('Notification service initialized');

    // Initialize alarm scheduler
    await AlarmScheduler().initialize();
    print('Alarm scheduler initialized');
  } catch (e) {
    print('Error initializing services: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Alarm Clock',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
      ),
      home: AlarmListScreen(),
    );
  }
}
