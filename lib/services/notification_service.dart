import 'package:flutter/material.dart';

class NotificationService {
  Future<void> init() async {
    // Do nothing
    debugPrint('Notifications are temporarily disabled');
  }

  Future<bool> requestPermissions() async {
    return false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Do nothing
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    // Do nothing
  }

  // Other methods can be left as empty stubs
  Future<void> cancelNotification(int id) async {}
  Future<void> cancelAllNotifications() async {}
}