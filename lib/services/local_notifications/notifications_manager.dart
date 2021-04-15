import 'package:e_commerce_app_flutter/models/Alarm.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationManager {
  NotificationManager._();

  static final instance = NotificationManager._();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future init() async {
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings();
    final InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS, macOS: initializationSettingsMacOS);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: selectNotification);
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) async {
    // display a dialog with the notification details, tap ok to go to another page
    showDialog(
      context: Get.context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            child: Text('Ok'),
            onPressed: () async {
              print("pressed");
              // Navigator.of(context, rootNavigator: true).pop();
              // await Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => SecondScreen(payload),
              //   ),
              // );
            },
          )
        ],
      ),
    );
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
    print(payload);
    // await Navigator.push(
    //   Get.context,
    //   MaterialPageRoute<void>(builder: (context) => SecondScreen(payload)),
    // );
  }

  Future setAlarmNotifications(Alarm alarm) async {
    tz.initializeTimeZones();

    final String currentTimeZone = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(currentTimeZone));

    DateTime loopDateTime = alarm.alarmingStartDate;

    while (alarm.alarmingEndDate.difference(loopDateTime).inDays >= 0) {
      for (DateTime notificationTime in alarm.alarmingTimes) {
        DateTime notificationScheduledTime = DateTime(
          loopDateTime.year,
          loopDateTime.month,
          loopDateTime.day,
          notificationTime.hour,
          notificationTime.minute,
        );

        if (notificationScheduledTime.difference(DateTime.now()).inMinutes <= 0) continue;

        int notificationScheduledID = alarm.notificationID +
            (alarm.alarmingEndDate.difference(alarm.alarmingStartDate).inDays -
                alarm.alarmingEndDate.difference(loopDateTime).inDays) +
            alarm.alarmingTimes.indexOf(notificationTime);

        await flutterLocalNotificationsPlugin.zonedSchedule(
          notificationScheduledID,
          "${alarm.title}",
          "${alarm.description}",
          tz.TZDateTime.from(notificationScheduledTime, tz.local),
          NotificationDetails(
            android: AndroidNotificationDetails(
              'alarm',
              'Alarms',
              'This notification channel is specified to alarms.',
              groupKey: "${alarm.notificationID}",
              importance: Importance.max,
              priority: Priority.max,
            ),
          ),
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }

      loopDateTime = loopDateTime.add(Duration(days: alarm.daysScheduled));
    }
  }

  Future clearAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
