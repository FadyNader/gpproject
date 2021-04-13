import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  _configFirebaseMessaging();

  runApp(App());
}

Future<void> _configFirebaseMessaging() async {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  _firebaseMessaging.configure(
    onMessage: (Map<String, dynamic> message) async {
      print("onMessage: $message");
    },
    onLaunch: (Map<String, dynamic> message) async {
      print("onLaunch: $message");
    },
    onResume: (Map<String, dynamic> message) async {
      print("onResume: $message");
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
