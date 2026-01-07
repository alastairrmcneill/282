abstract class Analytics {
  Future<void> track(String name, {Map<String, Object?>? props});
  Future<void> identify(String userId);
  Future<void> reset();
}

class AnalyticsEvent {
  static const screenViewed = 'screen_viewed';
  static const createPost = 'create_post';
  static const signUp = 'sign_up';
  static const onboardingScreenViewed = 'onboarding_screen_viewed';
  static const onboardingProgress = 'onboarding_progress';
  static const munroViewed = 'munro_viewed';
  static const surveyShown = 'survey_shown';
  static const surveyAnswers = 'survey_answers';
  static const appUpdateDialogShown = 'app_update_dialog_shown';
  static const hardAppUpdateDialogShown = 'hard_app_update_dialog_shown';
  static const appUpdateDialogUpdateNow = 'app_update_dialog_update_now';
  static const createPostNoPhotosDialogShown = 'create_post_no_photos_dialog_shown';
  static const createPostNoPhotosDialogResponse = 'create_post_no_photos_dialog_response';
  static const branchLinkClicked = 'branch_link_clicked';
  static const munroShared = 'munro_shared';
  static const weatherMetOfficeLinkClicked = 'weather_met_office_link_clicked';
  static const walkHighlandsMunroLinkClicked = 'walk_highlands_munro_link_clicked';
  static const saveMunroButtonClicked = 'save_munro_button_clicked';
  static const groupViewFilterApplied = 'group_view_filter_applied';
  static const authHomeCloseButtonTapped = 'auth_home_close_button_tapped';
  static const bulkMunroUpdateDidalogShown = 'bulk_munro_update_dialog_shown';
  static const annualMunroChallengeDialogShown = 'annual_munro_challenge_dialog_shown';
  static const annualMunroChallengeDialogConfirmed = 'annual_munro_challenge_dialog_confirmed';
}

class AnalyticsProp {
  static const screen = 'screen';
  static const previousScreen = 'previous_screen';
  static const durationSeconds = 'duration_seconds';

  static const privacy = 'privacy';
  static const showPrivacyOption = 'show_privacy_option';

  static const method = 'method';
  static const platform = 'platform';

  static const screenIndex = 'screen_index';

  static const status = 'status';

  static const munroId = 'munro_id';
  static const munroName = 'munro_name';

  static const q1 = 'q1';
  static const q2 = 'q2';

  static const response = 'response';

  static const source = 'source';
}
