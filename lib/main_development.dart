import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  print("🚀 ~ main ~ config: ${config.toString()}");
  await Firebase.initializeApp();

  await PushNotificationService.initPushNotificaitons();
  await RemoteConfigService.init();
  await AnalyticsService.init(config.mixpanelToken);
  await DeepLinkService.initBranchLinks(flavor: "Development", navigatorKey: navigatorKey);
  FlutterError.onError = (FlutterErrorDetails details) => Log.fatal(details);
  MapboxOptions.setAccessToken(config.mapboxToken);
  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
    accessToken: () async => FirebaseAuth.instance.currentUser?.getIdToken(false),
  );

  await FirebaseAuth.instance.currentUser?.getIdToken(true);

  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.environment = "Dev";
      options.attachScreenshot = true;
      options.enableNativeCrashHandling = true;
    },
    appRunner: () => runApp(App(flavor: "Development")),
  );

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: MyColors.backgroundColor,
  ));
}
