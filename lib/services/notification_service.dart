// lib/services/notification_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isNotificationsEnabled = true;

  // Initialize notification service
  Future<void> init() async {
    tz_data.initializeTimeZones();
    
    // Set default timezone to local
    try {
      tz.setLocalLocation(tz.getLocation('America/New_York')); // Default, will be overridden later
    } catch (e) {
      debugPrint('Error setting timezone: $e');
    }
    
    const AndroidInitializationSettings initializationSettingsAndroid = 
    AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('Notification tapped: ${response.payload}');
      },
    );

    await _loadNotificationPreference();
  }

  // Request notification permissions - comprehensive version
  Future<bool> requestPermissions() async {
    // For iOS
    final bool? iOSResult = await notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    
    // For Android 13+ (API level 33+)
    bool androidResult = true;
    
    // The method to request notification permissions varies by plugin version
    // In newer versions of the plugin, there's a requestNotificationPermissions method
    // In older versions, we need to handle this differently
    
    try {
      // Check if we can request permissions on this device
      final AndroidFlutterLocalNotificationsPlugin? androidPlugin = 
          notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        // This checks if the notification channels are enabled
        final bool? areNotificationsEnabled = await androidPlugin.areNotificationsEnabled();
        androidResult = areNotificationsEnabled ?? true;
        debugPrint('Android notifications enabled: $androidResult');
        
        // On Android 13+, we could direct users to app notification settings if needed
        // but we can't programmatically request permissions like on iOS
      }
    } catch (e) {
      // Handle any errors - this could happen on older Android versions
      debugPrint('Error checking Android notification permissions: $e');
      // Fall back to assuming permissions are granted
      androidResult = true;
    }
    
    final bool combinedResult = (iOSResult ?? true) && androidResult;
    
    // Update enabled state based on permission result
    if (!combinedResult) {
      await setNotificationsEnabled(false);
    }
    
    return combinedResult;
  }

  // Show notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    if (!_isNotificationsEnabled) return;
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await notificationsPlugin.show(
      id,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }
  
  // Schedule notification using timezone
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    if (!_isNotificationsEnabled) return;
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel_id',
      'Scheduled Notifications',
      channelDescription: 'Notifications that are scheduled for a future time',
      importance: Importance.max,
      priority: Priority.high,
    );
    
    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );
    
    await notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.local),
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: 
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    await notificationsPlugin.cancel(id);
  }

  // Cancel notifications
  Future<void> cancelAllNotifications() async {
    await notificationsPlugin.cancelAll();
  }

  // Load preference
  Future<void> _loadNotificationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isNotificationsEnabled = prefs.getBool('isNotificationsEnabled') ?? true;
    } catch (e) {
      debugPrint("Error loading notification preference: $e");
    }
  }

  // Save preference
  Future<void> _saveNotificationPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isNotificationsEnabled', _isNotificationsEnabled);
    } catch (e) {
      debugPrint("Error saving notification preference: $e");
    }
  }

  // Getter
  bool get isNotificationsEnabled => _isNotificationsEnabled;

  // Setter with save
  Future<void> setNotificationsEnabled(bool enabled) async {
    _isNotificationsEnabled = enabled;
    await _saveNotificationPreference();
    
    if (!enabled) {
      await cancelAllNotifications();
    }
  }
}