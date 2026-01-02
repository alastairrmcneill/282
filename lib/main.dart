import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart' hide SentryLogger;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/app_providers.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/logging/logging.dart';

main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  print("🚀 ~ main ~ config: ${config.toString()}");
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final mixpanel = await Mixpanel.init(config.mixpanelToken, trackAutomaticEvents: true);

  // await PushNotificationService.initPushNotificaitons(); //TODO fix
  MapboxOptions.setAccessToken(config.mapboxToken);
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
    accessToken: () async => FirebaseAuth.instance.currentUser?.getIdToken(false),
  );

  await FirebaseAuth.instance.currentUser?.getIdToken(true);

  final logger = SentryLogger();
  FlutterError.onError = (details) {
    logger.fatal(details.exception, stackTrace: details.stack);
  };

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.environment = config.env == AppEnvironment.prod ? "Prod" : "Dev";
      options.attachScreenshot = true;
      options.enableNativeCrashHandling = true;
    },
    appRunner: () => runApp(MultiProvider(
      providers: [
        Provider<Logger>.value(value: logger),
        ...buildRepositories(
          Supabase.instance.client,
          FirebaseAuth.instance,
          GoogleSignIn.instance,
          prefs,
          mixpanel,
          FirebaseStorage.instance,
          FirebaseRemoteConfig.instance,
        ),
        ...buildGlobalStates(config.env),
      ],
      child: App(environment: config.env),
    )),
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: MyColors.backgroundColor,
  ));
}
