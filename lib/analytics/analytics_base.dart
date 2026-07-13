abstract class Analytics {
  Future<void> track(String name, {Map<String, Object?>? props});
  Future<void> identify(String userId);
  Future<void> reset();
}

class AnalyticsEvent {
  static const screenViewed = 'screen_viewed';
  static const createPost = 'create_post';
  static const signUp = 'sign_up';
  static const signIn = 'sign_in';
  static const munroQuestionAnswered = 'munro_question_answered';
  static const bulkLogContinueTapped = 'bulk_log_continue_tapped';
  static const onboardingNotificationsResponse = 'onboarding_notifications_response';
  static const inAppOnboardingProgress = 'in_app_onboarding_progress';
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
  static const walkHighlandsMunroLinkClicked = 'walk_highlands_munro_link_clicked';
  static const saveMunroButtonClicked = 'save_munro_button_clicked';
  static const groupViewFilterApplied = 'group_view_filter_applied';
  static const authHomeCloseButtonTapped = 'auth_home_close_button_tapped';
  static const bulkMunroUpdateDidalogShown = 'bulk_munro_update_dialog_shown';
  static const bulkMunroUpdateDialogResponse = 'bulk_munro_update_dialog_response';
  static const annualMunroChallengeDialogShown = 'annual_munro_challenge_dialog_shown';
  static const annualMunroChallengeDialogConfirmed = 'annual_munro_challenge_dialog_confirmed';
  static const annualMunroChallengeDialogDismissed = 'annual_munro_challenge_dialog_dismissed';
  static const bulkMunroCompletionsAdded = 'bulk_munro_completions_added';
  static const whatsNewDialogShown = 'whats_new_dialog_shown';
  static const achievementUnlockedDialogShown = 'achievement_unlocked_dialog_shown';
  static const editPost = "edit_post";
  static const deletePost = "delete_post";
  static const createComment = "create_comment";
  static const deleteComment = "delete_comment";
  static const deleteReview = "delete_review";
  static const createReview = "create_review";
  static const editReview = "edit_review";
  static const likePost = "like_post";
  static const unlikePost = "unlike_post";
  static const paginateFriendsFeed = "paginate_friends_feed";
  static const paginateGlobalFeed = "paginate_global_feed";
  static const signOut = "sign_out";
  static const deleteAccount = "delete_account";
  static const selectCommonlyClimbedMunros = "select_commonly_climbed_munros_screen";
  static const onboardingCompleted = 'onboarding_completed';
  static const onboardingStarted = 'onboarding_started';
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
  static const exploreSearchClearTapped = 'explore_search_clear_tapped';

  static const settingChanged = 'setting_changed';
  static const profileEditSaved = 'profile_edit_saved';
  static const userSearchQuerySubmitted = 'user_search_query_submitted';
  static const userSearchClearTapped = 'user_search_clear_tapped';
  static const userSearchResultTapped = 'user_search_result_tapped';
  static const notificationTapped = 'notification_tapped';
  static const notificationsMarkAllReadTapped = 'notifications_mark_all_read_tapped';
  static const reportSubmitted = 'report_submitted';
  static const achievementTapped = 'achievement_tapped';
  static const munroChallengeGoalSet = 'munro_challenge_goal_set';

  static const ageGateResolved = 'age_gate_resolved';
  static const ageGateConfirmationShown = 'age_gate_confirmation_shown';
  static const ageGateConfirmTapped = 'age_gate_confirm_tapped';
  static const ageGateBirthdatePromptShown = 'age_gate_birthdate_prompt_shown';
}

class AnalyticsProp {
  static const screen = 'screen';
  static const previousScreen = 'previous_screen';
  static const durationSeconds = 'duration_seconds';
  static const privacy = 'privacy';
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
  static const munroCompletionsAdded = "munro_completions_added";
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
  static const reportType = "report_type";
  static const achievementId = "achievement_id";
  static const achievementName = "achievement_name";
}
