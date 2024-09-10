import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:two_eight_two/services/shared_preferences_service.dart';

class AnalyticsService {
  static FirebaseAnalytics? _analytics;
  static Mixpanel? mixpanel;

  static Future<void> init({required String flavor}) async {
    // Once you've called this method once, you can access `mixpanel` throughout the rest of your application.
    String token = dotenv.env['MIXPANEL_TOKEN_${flavor.toUpperCase()}'] ?? "";
    mixpanel = await Mixpanel.init(token, trackAutomaticEvents: true);

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

  static Future<void> logOnboardingScreenViewed({required int screenIndex}) async {
    await logEvent(
      name: 'onboarding_screen_viewed',
      parameters: {
        'screen_index': screenIndex.toString(),
      },
    );
  }

  static Future<void> logMunroViewed({required String munroId, required String munroName}) async {
    await logEvent(
      name: 'munro_viewed',
      parameters: {
        'munro_id': munroId,
        'munro_name': munroName,
      },
    );
  }

  static Future<void> logSurveyShown() async {
    await logEvent(
      name: 'survey_shown',
      parameters: {},
    );
  }

  static Future<void> logSurveyAnswered({required String? q1, required String? q2}) async {
    await logEvent(
      name: 'survey_answers',
      parameters: {
        'q1': {q1 == null || q1 == ""}.toString(),
        'q2': {q2 == null || q2 == ""}.toString(),
      },
    );
  }

  static Future<void> logAppUpdateDialogShown() async {
    await logEvent(
      name: 'app_update_dialog_shown',
      parameters: {},
    );
  }

  static Future<void> logAppUpdateDialogUpdateNow() async {
    await logEvent(
      name: 'app_update_dialog_update_now',
      parameters: {},
    );
  }

  static Future<void> logCreatePostNoPhotos() async {
    await logEvent(
      name: 'create_post_no_photos_dialog_shown',
      parameters: {},
    );
  }

  static Future<void> logCreatePostNoPhotosResponse(String response) async {
    await logEvent(
      name: 'create_post_no_photos_dialog_response',
      parameters: {
        'response': response,
      },
    );
  }
}
