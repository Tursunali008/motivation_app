import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class QuoteProvider extends ChangeNotifier {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  QuoteProvider() {
    _initializeNotifications();
    _scheduleDailyNotification();
  }

  void _initializeNotifications() {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSSettings = DarwinInitializationSettings();
    const settings =
        InitializationSettings(android: androidSettings, iOS: iOSSettings);
    flutterLocalNotificationsPlugin.initialize(settings);

    tz.initializeTimeZones();
  }

  Future<void> _scheduleDailyNotification() async {
    final quotes = await _fetchQuotes();
    final randomQuote = quotes[
        (quotes.length * tz.TZDateTime.now(tz.local).microsecond) %
            quotes.length];

    const androidDetails = AndroidNotificationDetails(
      'quote_channel',
      'Daily Quotes',
      channelDescription: 'Notifications for Daily Motivational Quotes',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iOSDetails = DarwinNotificationDetails();
    final notificationDetails =
        const NotificationDetails(android: androidDetails, iOS: iOSDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Motivational Quote',
      randomQuote['text'],
      _nextInstanceOfEightAM(),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  tz.TZDateTime _nextInstanceOfEightAM() {
    final now = tz.TZDateTime.now(tz.local);
    final scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 8);

    return scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;
  }

  Future<List<dynamic>> _fetchQuotes() async {
    final response = await http.get(Uri.parse('https://type.fit/api/quotes'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load quotes');
    }
  }
}
