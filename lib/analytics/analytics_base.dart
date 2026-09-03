abstract class Analytics {
  Future<void> track(String name, {Map<String, Object?>? props});
  Future<void> identify(String userId);
  Future<void> reset();
  Future<void> registerSuperProperty(String key, Object? value);

  /// Sets user profile properties, overwriting any existing value.
  Future<void> setProfileProperties(Map<String, Object?> props);

  /// Sets user profile properties only if they are not already set.
  /// Use for immutable facts like signup date.
  Future<void> setProfilePropertiesOnce(Map<String, Object?> props);

  Future<void> incrementProfileProperty(String prop, double by);
}

class AnalyticsEvent {
  static const screenViewed = 'screen_viewed';
  static const createPost = 'create_post';
  static const signUp = 'sign_up';
  static const signIn = 'sign_in';
  static const munroQuestionAnswered = 'munro_question_answered';
  static const bulkLogContinueTapped = 'bulk_log_continue_tapped';
  static const onboardingNotificationsResponse = 'onboarding_notifications_response';
  static const munroViewed = 'munro_viewed';
  static const surveyShown = 'survey_shown';
  static const surveyAnswers = 'survey_answers';
  static const dialogShown = 'dialog_shown';
  static const dialogResponse = 'dialog_response';
  static const branchLinkClicked = 'branch_link_clicked';
  static const munroShared = 'munro_shared';
  static const walkHighlandsMunroLinkClicked = 'walk_highlands_munro_link_clicked';
  static const groupViewFilterApplied = 'group_view_filter_applied';
  static const authHomeCloseButtonTapped = 'auth_home_close_button_tapped';
  static const bulkMunroCompletionsAdded = 'bulk_munro_completions_added';
  static const editPost = "edit_post";
  static const deletePost = "delete_post";
  static const createComment = "create_comment";
  static const deleteComment = "delete_comment";
  static const deleteReview = "delete_review";
  static const createReview = "create_review";
  static const editReview = "edit_review";
  static const likePost = "like_post";
  static const unlikePost = "unlike_post";
  static const feedPaginated = "feed_paginated";
  static const signOut = "sign_out";
  static const deleteAccount = "delete_account";
  static const createPostMunrosSelected = "create_post_munros_selected";
  static const onboardingCompleted = 'onboarding_completed';
  static const onboardingScreenViewed = 'onboarding_screen_viewed';
  static const appShared = 'app_shared';
  static const munroStartingPointClicked = 'munro_starting_point_clicked';
  static const munroDetailsTabViewed = 'munro_details_tab_viewed';

  static const createSavedListCancel = 'create_saved_list_cancel';
  static const createSavedListCreate = 'create_saved_list_create';

  static const munroMoreOptionsPressed = 'munro_more_options_pressed';
  static const munroSaveButtonClicked = 'munro_save_button_clicked';
  static const munroSharePressed = 'munro_share_pressed';

  static const createPostBagMunroButtonPressed = 'create_post_bag_munro_button_pressed';

  static const exploreSearchButtonTapped = 'explore_search_button_tapped';
  static const exploreFilterButtonTapped = 'explore_filter_button_tapped';
  static const searchCleared = 'search_cleared';

  static const settingChanged = 'setting_changed';
  static const profileEditSaved = 'profile_edit_saved';
  static const userSearchQuerySubmitted = 'user_search_query_submitted';
  static const userSearchResultTapped = 'user_search_result_tapped';
  static const pushOpened = 'push_opened';
  static const notificationTapped = 'notification_tapped';
  static const notificationsMarkAllReadTapped = 'notifications_mark_all_read_tapped';
  static const reportSubmitted = 'report_submitted';
  static const achievementTapped = 'achievement_tapped';
  static const munroChallengeGoalSet = 'munro_challenge_goal_set';

  static const ageGateResolved = 'age_gate_resolved';
  static const ageGateConfirmationShown = 'age_gate_confirmation_shown';
  static const ageGateConfirmTapped = 'age_gate_confirm_tapped';
  static const ageGateBirthdatePromptShown = 'age_gate_birthdate_prompt_shown';

  static const onboardingBackTapped = 'onboarding_back_tapped';
  static const onboardingLegalLinkTapped = 'onboarding_legal_link_tapped';
  static const onboardingAuthCtaTapped = 'onboarding_auth_cta_tapped';
  static const bulkLogViewToggled = 'bulk_log_view_toggled';
  static const bulkLogSearchCleared = 'bulk_log_search_cleared';
  static const postCreateFailed = 'post_create_failed';
  static const photoUploadFailed = 'photo_upload_failed';
  static const searchNoResults = 'search_no_results';
  static const mapLoadFailed = 'map_load_failed';
}

class AnalyticsProp {
  static const screen = 'screen';
  static const previousScreen = 'previous_screen';
  static const durationSeconds = 'duration_seconds';
  static const privacy = 'privacy';
  static const method = 'method';
  static const platform = 'platform';
  static const stepNumber = 'step_number';
  static const stepName = 'step_name';
  static const branch = 'branch';
  static const status = 'status';
  static const munroId = 'munro_id';
  static const munroName = 'munro_name';
  static const q1 = 'q1';
  static const q2 = 'q2';
  static const response = 'response';
  static const source = 'source';
  static const gateSource = 'gate_source';
  static const munroCompletionsAdded = "munro_completions_added";
  static const munrosLogged = "munros_logged";
  static const notificationsEnabled = "notifications_enabled";
  static const munroChallengeCount = "munro_challenge_count";
  static const imagesAdded = "images_added";
  static const postId = "post_id";
  static const reviewId = "review_id";
  static const rating = "rating";
  static const text = "text";
  static const postCount = "post_count";
  static const completionDate = "completion_date";
  static const completionStartTime = "completion_start_time";
  static const completionDuration = "completion_duration";
  static const commonlyClimbedWithCount = "commonly_climbed_with_count";
  static const selectedMunroCount = "selected_munro_count";
  static const description = "description";
  static const tabName = "tab_name";
  static const version = "version";
  static const surveyNumber = "survey_number";
  static const achievementCount = "achievement_count";
  static const setting = "setting";
  static const value = "value";
  static const nameChanged = "name_changed";
  static const bioChanged = "bio_changed";
  static const photoChanged = "photo_changed";
  static const resultCount = "result_count";
  static const notificationType = "notification_type";
  static const notificationCount = "notification_count";
  static const notificationId = "notification_id";
  static const coldStart = "cold_start";
  static const reportType = "report_type";
  static const achievementId = "achievement_id";
  static const achievementName = "achievement_name";

  static const linkType = "link_type";
  static const viewMode = "view_mode";
  static const ctaType = "cta_type";
  static const channel = "channel";
  static const campaign = "campaign";
  static const feature = "feature";
  static const routed = "routed";
  static const reason = "reason";
  static const queryLength = "query_length";
  static const query = "query";
  static const dialogName = "dialog_name";
  static const feed = "feed";
  static const surface = "surface";
}

class AnalyticsDialog {
  static const softAppUpdate = 'soft_app_update';
  static const hardAppUpdate = 'hard_app_update';
  static const whatsNew = 'whats_new';
  static const achievementUnlocked = 'achievement_unlocked';
  static const bulkMunroUpdate = 'bulk_munro_update';
  static const annualMunroChallenge = 'annual_munro_challenge';
  static const createPostNoPhotos = 'create_post_no_photos';
  static const reviewPrompt = 'review_prompt';
  static const reviewSentimentPrompt = 'review_sentiment_prompt';
  static const stravaReviewActivity = 'strava_review_activity';
  static const stravaConnect = 'strava_connect';
}

class AnalyticsSurface {
  static const explore = 'explore';
  static const userSearch = 'user_search';
  static const munroPage = 'munro_page';
  static const munroSummaryTile = 'munro_summary_tile';
  static const munroAppBar = 'munro_app_bar';

  static const exploreMap = 'explore_map';
  static const munroOverviewMap = 'munro_overview_map';
  static const munroFullMap = 'munro_full_map';
  static const bulkMunroMap = 'bulk_munro_map';
}

class AnalyticsSource {
  static const firstRunOnboarding = 'first_run_onboarding';
  static const inAppOnboarding = 'in_app_onboarding';
}

class AnalyticsResponse {
  static const yes = 'yes';
  static const no = 'no';
  static const enable = 'enable';
  static const skip = 'skip';
  static const add = 'add';
  static const go = 'go';
  static const dismiss = 'dismiss';
  static const confirmed = 'confirmed';
  static const dismissed = 'dismissed';
  static const updateNow = 'update_now';
  static const openSettings = 'open_settings';
}

class AnalyticsFeed {
  static const friends = 'friends';
  static const global = 'global';
}
