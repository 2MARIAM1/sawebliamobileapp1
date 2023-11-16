import 'dart:typed_data';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../pages/newmission.dart';

class FirebaseApi {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("logoicon");

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
    );

    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    final fCMtoken = await _firebaseMessaging.getToken();
    print('Token: $fCMtoken');
  }

  Future<NotificationDetails> _notificationDetails() async {
    AndroidNotificationDetails _androidNotificationDetails =
        AndroidNotificationDetails(
      'mychannel_id',
      'mychannel_name',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      sound: RawResourceAndroidNotificationSound('notificationtone'),
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 300, 200, 300, 200, 300]),
    );
    return NotificationDetails(android: _androidNotificationDetails);
  }

  Future<void> showNotification(RemoteMessage message) async {
    final details = await _notificationDetails();

    // await flutterLocalNotificationsPlugin
    //     .resolvePlatformSpecificImplementation<
    //         AndroidFlutterLocalNotificationsPlugin>()
    //     ?.createNotificationChannel(_androidNotificationDetails);
    flutterLocalNotificationsPlugin.show(
        0, message.notification?.title, message.notification?.body, details);
  }
}
