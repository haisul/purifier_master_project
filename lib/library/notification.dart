import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Notification {
  bool _notificationState = true;

  bool get state => _notificationState;
  Future<bool> set(bool val) async {
    _notificationState = val;
    Map<String, dynamic> userSet = {
      'notification': val,
    };
    String userSetStr = jsonEncode(userSet);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('userSetStr', userSetStr);
    return val;
  }

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  void initial() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);
  }

  void show(String msg) async {
    if (_notificationState) {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'channel_id',
        'channel_name',
        channelDescription: 'your channel description',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        color: Color.fromARGB(255, 40, 255, 255),
        //largeIcon: DrawableResourceAndroidBitmap('launcher_icon'),
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await _notifications.show(
        0,
        msg,
        '',
        platformChannelSpecifics,
      );
    }
  }
}
