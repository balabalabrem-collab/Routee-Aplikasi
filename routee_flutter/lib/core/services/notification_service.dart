import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/launcher_icon');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings);

    // Request permission on Android 13+
    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
  }

  Future<void> showNearbyAlert(String spotName) async {
    const androidDetails = AndroidNotificationDetails(
      'routee_nearby',
      'Hampir Sampai',
      channelDescription: 'Notifikasi saat mendekati destinasi',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF6C63FF),
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      1,
      '📍 Hampir Sampai!',
      'Kamu sekitar 300m dari $spotName — bersiap-siaplah!',
      details,
    );
  }

  Future<void> showArrivedAlert(String spotName) async {
    const androidDetails = AndroidNotificationDetails(
      'routee_arrived',
      'Sampai di Destinasi',
      channelDescription: 'Notifikasi saat tiba di destinasi',
      importance: Importance.max,
      priority: Priority.max,
      color: Color(0xFF6C63FF),
      playSound: true,
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      2,
      '🎉 Selamat Datang!',
      'Kamu sudah tiba di $spotName. Selamat menikmati!',
      details,
    );
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
