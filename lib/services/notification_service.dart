import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize timezone for scheduling
    tz.initializeTimeZones();

    // Android Initialization settings
    // Ensure you have an icon named 'ic_launcher' in android/app/src/main/res/mipmap...
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS Initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) {
        // Handle notification tap if needed
      },
    );
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestExactAlarmsPermission();
    } else if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    }
  }

  Future<void> scheduleTaskNotification(int id, String title, String body, DateTime scheduledTime, {String repeat = 'once'}) async {
    tz.TZDateTime scheduledTZDate = tz.TZDateTime.from(scheduledTime, tz.local);
    
    // If the scheduled time is in the past, calculate the next occurrence if it's repeating
    if (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
      if (repeat == 'daily') {
        while (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
          scheduledTZDate = scheduledTZDate.add(const Duration(days: 1));
        }
      } else if (repeat == 'weekly') {
        while (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
          scheduledTZDate = scheduledTZDate.add(const Duration(days: 7));
        }
      } else if (repeat == 'monthly') {
        while (scheduledTZDate.isBefore(tz.TZDateTime.now(tz.local))) {
          scheduledTZDate = tz.TZDateTime(tz.local, scheduledTZDate.year, scheduledTZDate.month + 1, scheduledTZDate.day, scheduledTZDate.hour, scheduledTZDate.minute);
        }
      } else {
        // If 'once' and in the past, don't schedule
        return;
      }
    }

    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'task_reminder_channel',
      'Task Reminders',
      channelDescription: 'Channel for Task Reminder Notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: DarwinNotificationDetails(presentSound: true, presentAlert: true),
    );

    DateTimeComponents? matchDateTimeComponents;
    if (repeat == 'daily') {
      matchDateTimeComponents = DateTimeComponents.time;
    } else if (repeat == 'weekly') {
      matchDateTimeComponents = DateTimeComponents.dayOfWeekAndTime;
    } else if (repeat == 'monthly') {
      matchDateTimeComponents = DateTimeComponents.dayOfMonthAndTime;
    }

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduledTZDate,
      notificationDetails: platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: matchDateTimeComponents,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
  }
}
