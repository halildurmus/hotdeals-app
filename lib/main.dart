import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'src/app.dart';
import 'src/firebase_messaging_listener.dart';
import 'src/models/categories.dart';
import 'src/models/current_route.dart';
import 'src/models/push_notification.dart';
import 'src/models/stores.dart';
import 'src/services/connection_service.dart';
import 'src/services/firestore_service.dart';
import 'src/services/spring_service.dart';
import 'src/services/spring_service_impl.dart';
import 'src/services/sqlite_service.dart';
import 'src/services/sqlite_service_impl.dart';
import 'src/settings/settings.controller.impl.dart';
import 'src/settings/settings.service.impl.dart';
import 'src/settings/settings_controller.dart';
import 'src/utils/tr_short_messages.dart';
import 'src/widgets/loading_dialog.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes a new Firebase App instance.
  await Firebase.initializeApp();

  // Fetches the default FCM token for this device.
  await FirebaseMessaging.instance.getToken();

  // Sets a message handler function which is called when the app is in the
  // background or terminated.
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // Registers Singleton classes.
  final GetIt getIt = GetIt.I;
  getIt.registerSingleton<CurrentRoute>(CurrentRoute());
  getIt.registerSingleton<ConnectionService>(ConnectionService());
  getIt.registerSingleton<SQLiteService<PushNotification>>(SQLiteServiceImpl());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<SpringService>(SpringServiceImpl());
  getIt.registerSingleton<Categories>(Categories());
  getIt.registerSingleton<Stores>(Stores());
  getIt.registerSingleton<LoadingDialog>(const LoadingDialog());

  // Fetches categories and stores.
  try {
    await Future.wait<dynamic>(
      <Future<dynamic>>[
        getIt.get<Categories>().getCategories(),
        getIt.get<Stores>().getStores(),
      ],
    );
  } on Exception catch (e) {
    print('Failed to fetch categories and stores in main!');
    print(e);
  }

  // Initializes the ConnectionService.
  getIt.get<ConnectionService>().initialize();

  // Loads the sqlite database.
  await getIt.get<SQLiteService<PushNotification>>().load();

  // Calculates the unread notifications count if there is a signed in user.
  if (FirebaseAuth.instance.currentUser != null) {
    await getIt
        .get<SQLiteService<PushNotification>>()
        .calculateUnreadNotifications();
  }

  // Initializes a new SharedPreferences instance.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Sets up the SettingsController, and registers it as a Singleton class.
  getIt.registerSingleton<SettingsController>(
      SettingsControllerImpl(SettingsServiceImpl(prefs)));

  // Loads the user's preferred settings.
  await getIt.get<SettingsController>().loadSettings();

  // Registers Turkish short messages for timeago.
  timeago.setLocaleMessages('tr_short', TrShortMessages());

  // Runs the app with MyApp attached to the screen.
  runApp(const MyApp());
}
