import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:two_eight_two/services/shared_preferences_service.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static Mixpanel? mixpanel;

  static Future<void> init({required String flavor}) async {
    // Once you've called this method once, you can access `mixpanel` throughout the rest of your application.
    mixpanel = await Mixpanel.init("883b6c76f333637c8d85b499ca6ba1ec", trackAutomaticEvents: true);

    print("Mixpanel Token: ${dotenv.env['MIXPANEL_TOKEN_${flavor.toUpperCase()}']}");

    _analytics = FirebaseAnalytics.instance;
    await _analytics?.setAnalyticsCollectionEnabled(true);
  }

  static Future<void> logEvent({
    required String name,
    Map<String, String>? parameters,
  }) async {
    print('Logging event: $name : $parameters');
    await _analytics?.logEvent(name: name, parameters: parameters);
    await mixpanel?.track(
      name,
      properties: parameters,
    );
  }

  static Future<void> logPostCreation({
    required String privacy,
    required bool showPrivacyOption,
  }) async {
    await logEvent(
      name: 'create_post',
      parameters: {
        'privacy': privacy,
        'show_privacy_option': showPrivacyOption.toString(),
      },
    );
  }

  static Future<void> logSignUp({
    required String method,
    required String platform,
  }) async {
    await logEvent(
      name: 'sign_up',
      parameters: {
        'method': method,
        'platform': platform,
      },
    );
  }

  static Future<void> logOpen() async {
    int openCount = await SharedPreferencesService.getOpenCount();
    openCount += 1;
    print('Open count: $openCount');
    SharedPreferencesService.setOpenCount(openCount);

    if (openCount == 2 || openCount == 3 || openCount == 5 || openCount == 10) {
      logEvent(
        name: 'app_open',
        parameters: {
          'open_count': openCount.toString(),
        },
      );
    }
  }
}
