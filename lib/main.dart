import 'package:e_commerce_app_flutter/services/database/alarms_database_helper.dart';
import 'package:e_commerce_app_flutter/services/local_notifications/notifications_manager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  _configFirebaseMessaging();
  NotificationManager.instance.init();
  AlarmProvider.instance.open();

  runApp(App());
}

Future<void> _configFirebaseMessaging() async {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");
      String title = message["notification"]["title"];
      String body = message["notification"]["body"];
      String tag = message["data"]["tag"];
      return showDialog(
        context: Get.context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("$title", textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
              SizedBox(height: 10),
              Text("$body", style: TextStyle(fontSize: 14, height: 1.5)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[RaisedButton(child: Text("Done"), onPressed: () => Navigator.pop(context))],
              ),
            ],
          ),
        ),
      );
    },
    onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
      String title = message["notification"]["title"];
      String body = message["notification"]["body"];
      String tag = message["data"]["tag"];
      return showDialog(
        context: Get.context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("$title", textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
              SizedBox(height: 10),
              Text("$body", style: TextStyle(fontSize: 14, height: 1.5)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[RaisedButton(child: Text("Done"), onPressed: () => Navigator.pop(context))],
              ),
            ],
          ),
        ),
      );
    },
    onResume: (Map<String, dynamic> message) async {
      print("onResume: $message");
      String title = message["notification"]["title"];
      String body = message["notification"]["body"];
      String tag = message["data"]["tag"];
      return showDialog(
        context: Get.context,
        builder: (context) => AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text("$title", textAlign: TextAlign.center, style: TextStyle(fontSize: 24)),
              SizedBox(height: 10),
              Text("$body", style: TextStyle(fontSize: 14, height: 1.5)),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[RaisedButton(child: Text("Done"), onPressed: () => Navigator.pop(context))],
              ),
            ],
          ),
        ),
      );
    },
  );

  IosNotificationSettings iosSettings = const IosNotificationSettings(
    alert: true,
    badge: true,
    provisional: false,
    sound: true,
  );

  await _firebaseMessaging.requestNotificationPermissions(iosSettings);
}
