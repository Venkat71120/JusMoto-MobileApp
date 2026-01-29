import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'helper/constant_helper.dart';
import 'helper/firebase_messaging_helper.dart';
import 'helper/notification_helper.dart';

Future<void> initializeFirebase() async {
  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } else {
    await Firebase.initializeApp();
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await initializeFirebase();
  }

  await setupFlutterNotifications();
  final messageData = message.data;
  final sPref = await SharedPreferences.getInstance();
  final strings = sPref.getString('translated_string') ?? "{}";
  var translatedString = jsonDecode(strings);
  final id = messageData['id'] is String
      ? int.tryParse(messageData['id'])
      : messageData['id'];

  String title = message.data['title'] ?? "";
  String description = message.data['body'] ?? "";
  String identity = message.data['identity'] ?? "";
  String type = message.data['type'] ?? "name";
  if (type == "Order") {
    title = description;
    description = "${translatedString["Order Id"] ?? "Order Id"}: #$identity";
  }
  if (type == "Withdraw") {
    title = description;
    description = "${translatedString["Id"] ?? "Id"}: #$identity";
  }
  if (type == "message") {
    var liveChatData = jsonDecode(message.data["livechat"] ?? "{}");

    try {
      title = liveChatData["client"]?["first_name"]?.toString() ?? "";

      description =
          jsonDecode(message.data['body'] ?? "{}")?["message"]?.toString() ??
              "";
    } catch (e) {}
  }
  NotificationHelper().triggerNotification(
    id: id,
    body: description,
    title: title,
    payload: message.data,
    channelName: type,
  );
}

final navigatorKey = GlobalKey<NavigatorState>(debugLabel: "nav_key");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final GoogleMapsFlutterPlatform mapsImplementation =
      GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is GoogleMapsFlutterAndroid) {
    mapsImplementation.useAndroidViewSurface = true;
  }

  if (Firebase.apps.isEmpty) {
    await initializeFirebase();
  }
  sPref ??= await SharedPreferences.getInstance();

  runApp(const MainApp());
}
