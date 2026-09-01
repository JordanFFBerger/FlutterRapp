import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';

import 'models.dart';

class ScheduleService {
  ScheduleService._();
  static final instance = ScheduleService._();

  final _notifications = FlutterLocalNotificationsPlugin();
  static const notificationId = 7301;
  Future<void>? _initialization;

  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const apple = DarwinInitializationSettings();
    await _notifications.initialize(
      const InitializationSettings(android: android, iOS: apple),
    );
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (Platform.isAndroid) {
      return await _notifications
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          true;
    }
    return await _notifications
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        true;
  }

  Future<void> schedule(MorningSettings settings) async {
    await initialize();
    await _notifications.cancel(notificationId);
    if (!settings.enabled) return;

    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      settings.hour,
      settings.minute,
    );
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));

    await _notifications.zonedSchedule(
      notificationId,
      'Your good morning message is ready',
      'Tap to review and send it to ${settings.contacts.length} ${settings.contacts.length == 1 ? 'person' : 'people'}.',
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_message_daily',
          'Daily morning message',
          channelDescription: 'A daily reminder to send your morning message.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<bool> openMessageComposer(MorningSettings settings) async {
    final recipients = settings.contacts.map((c) => c.phone).join(',');
    if (recipients.isEmpty) return false;
    final separator = Platform.isIOS ? '&' : '?';
    final uri = Uri.parse(
      'sms:$recipients${separator}body=${Uri.encodeQueryComponent(settings.message)}',
    );
    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}
