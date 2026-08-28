import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart' hide SentryLogger;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/app.dart';
import 'package:two_eight_two/app_providers.dart';
import 'package:two_eight_two/config/app_config.dart';
import 'package:two_eight_two/config/onboarding_config.dart';
import 'package:two_eight_two/helpers/helpers.dart';
import 'package:two_eight_two/push/push.dart';
import 'package:two_eight_two/support/theme.dart';
import 'package:two_eight_two/logging/logging.dart';

main() async {
  SentryWidgetsFlutterBinding.ensureInitialized();

  final config = AppConfig.fromEnvironment();
  await Firebase.initializeApp();
  final prefs = await SharedPreferences.getInstance();
  final mixpanel = await Mixpanel.init(config.mixpanelToken, trackAutomaticEvents: true);
  mixpanel.setServerURL("https://api-eu.mixpanel.com");
  await mixpanel.registerSuperProperties({'onboarding_version': onboardingVersion});

  MapboxOptions.setAccessToken(config.mapboxToken);
  if (kDebugMode) {
    // Styles are being iterated on in Mapbox Studio; never render a stale cached copy in dev.
    await MapboxMapsOptions.clearData();
  }
  final logger = SentryLogger();

  await Supabase.initialize(
    url: config.supabaseUrl,
    anonKey: config.supabaseAnonKey,
    accessToken: () async {
      try {
        return await withNetworkRetry(
          () => FirebaseAuth.instance.currentUser?.getIdToken(false),
        );
      } catch (error, stackTrace) {
        // Falls back to the anon key for this request rather than crashing the
        // Postgrest/Realtime call that triggered the token refresh — Supabase
        // will simply retry with a fresh token next time one is needed.
        logger.logPossibleNetworkError(
          'Failed to refresh Supabase access token',
          error,
          stackTrace: stackTrace,
        );
        return null;
      }
    },
  );

  await FirebaseAuth.instance.currentUser?.getIdToken(true);

  FlutterError.onError = (details) {
    // Framework-level errors can surface transient network failures (e.g. an
    // image fetch failing mid-load while the app is backgrounded) — treat
    // those the same as everywhere else instead of reporting them as fatal.
    if (isTransientNetworkError(details.exception)) {
      logger.info(
        'Flutter error (transient network error): ${details.exceptionAsString()}',
        context: {'error': details.exception.toString()},
      );
    } else {
      logger.fatal(details.exception, stackTrace: details.stack);
    }
  };

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final googleSignIn = GoogleSignIn.instance;
  await googleSignIn.initialize(
    serverClientId: config.googleWebClientId,
  );

  final packageInfo = await PackageInfo.fromPlatform();

  await SentryFlutter.init(
    (options) {
      options.dsn = config.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.environment = config.env == AppEnvironment.prod ? "Prod" : "Dev";
      options.attachScreenshot = true;
      options.enableNativeCrashHandling = true;
      options.beforeSend = (event, hint) {
        // Some transient network failures (e.g. an image download aborted
        // mid-request) are thrown outside FlutterError.onError's reach and
        // would otherwise still get reported as unresolved production errors.
        final throwable = event.throwable;
        if (throwable != null && isTransientNetworkError(throwable)) {
          logger.info(
            'Suppressed transient network error from Sentry report',
            context: {'error': throwable.toString()},
          );
          return null;
        }
        if (isNoisyBackgroundAnr(event)) {
          logger.info('Suppressed system-frame-only background ANR from Sentry report');
          return null;
        }
        return event;
      };
    },
    appRunner: () => runApp(MultiProvider(
      providers: [
        Provider<Logger>.value(value: logger),
        ...buildRepositories(
          Supabase.instance.client,
          FirebaseAuth.instance,
          googleSignIn,
          prefs,
          mixpanel,
          FirebaseStorage.instance,
          FirebaseRemoteConfig.instance,
          packageInfo,
        ),
        ...buildGlobalStates(config.env),
      ],
      child: App(environment: config.env),
    )),
  );

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: MyLightColors().background,
  ));
}
