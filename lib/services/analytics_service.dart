import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import 'package:two_eight_two/services/shared_preferences_service.dart';

class AnalyticsService {
  static Mixpanel? mixpanel;

  static Future<void> init(String mixpanelToken) async {
    // Once you've called this method once, you can access `mixpanel` throughout the rest of your application.
    mixpanel = await Mixpanel.init(mixpanelToken, trackAutomaticEvents: true);
  }

  static Future<void> logEvent({
    required String name,
    Map<String, String>? parameters,
  }) async {
    print("🚀 ~ AnalyticsService ~ logEvent: $name : $parameters");
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
        'q1': {!(q1 == null || q1.trim() == "")}.toString(),
        'q2': {!(q2 == null || q2.trim() == "")}.toString(),
      },
    );
  }

  static Future<void> logAppUpdateDialogShown() async {
    await logEvent(
      name: 'app_update_dialog_shown',
      parameters: {},
    );
  }

  static Future<void> logHardAppUpdateDialogShown() async {
    await logEvent(
      name: 'hard_app_update_dialog_shown',
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

  static Future<void> logDatabaseRead({
    required String method,
    required String collection,
    required int documentCount,
    required String? userId,
    required String? documentId,
    Map<String, dynamic>? additionalData,
  }) async {
    logEvent(name: 'Database Read', parameters: {
      'method': method,
      'collection': collection,
      'documentCount': documentCount.toString(),
      'userId': userId ?? "",
      'documentId': documentId ?? "",
      ...additionalData ?? {},
    });
  }

  static Future<void> logOnboardingCompleted() async {
    await logEvent(
      name: 'Onboarding Progress',
      parameters: {"status": "completed"},
    );
  }

  static Future<void> logOnboardingStarted() async {
    await logEvent(
      name: 'Onboarding Progress',
      parameters: {"status": "started"},
    );
  }
}
