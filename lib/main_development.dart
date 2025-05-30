import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/services/services.dart';
import 'package:two_eight_two/support/theme.dart';

main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await PushNotificationService.initPushNotificaitons();
  await RemoteConfigService.init();
  await dotenv.load();
  await AnalyticsService.init(flavor: "Development");
  await DeepLinkService.initBranchLinks(flavor: "Development", navigatorKey: navigatorKey);
  FlutterError.onError = (FlutterErrorDetails details) => Log.fatal(details);
  MapboxOptions.setAccessToken(dotenv.env["MAPBOX_TOKEN"] ?? "");

  await SentryFlutter.init(
    (options) {
      options.dsn = 'https://bfa467006bce072639aca5c3a7474f3c@o4506950554353664.ingest.us.sentry.io/4506950555664384';
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
