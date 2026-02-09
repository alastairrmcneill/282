abstract class Analytics {
  Future<void> track(String name, {Map<String, Object?>? props});
  Future<void> identify(String userId);
  Future<void> reset();
}

class AnalyticsEvent {
  static const screenViewed = 'screen_viewed';
  static const createPost = 'create_post';
  static const signUp = 'sign_up';
  static const inAppOnboardingScreenViewed = 'in_app_onboarding_screen_viewed';
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
  static const weatherMetOfficeLinkClicked = 'weather_met_office_link_clicked';
  static const walkHighlandsMunroLinkClicked = 'walk_highlands_munro_link_clicked';
  static const saveMunroButtonClicked = 'save_munro_button_clicked';
  static const groupViewFilterApplied = 'group_view_filter_applied';
  static const authHomeCloseButtonTapped = 'auth_home_close_button_tapped';
  static const bulkMunroUpdateDidalogShown = 'bulk_munro_update_dialog_shown';
  static const annualMunroChallengeDialogShown = 'annual_munro_challenge_dialog_shown';
  static const annualMunroChallengeDialogConfirmed = 'annual_munro_challenge_dialog_confirmed';
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
  static const paginateFriendsFeed = "paginate_friends_feed";
  static const paginateGlobalFeed = "paginate_global_feed";
  static const signOut = "sign_out";
  static const deleteAccount = "delete_account";
  static const selectCommonlyClimbedMunros = "select_commonly_climbed_munros_screen";
  static const onboardingCompleted = 'onboarding_completed';
  static const onboardingStarted = 'onboarding_started';
  static const onboardingScreenViewed = 'onboarding_screen_viewed';
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
  static const munroCompletionsAdded = "munro_completions_added";
  static const munroChallengeCount = "munro_challenge_count";
  static const imagesAdded = "images_added";
  static const postId = "post_id";
  static const reviewId = "review_id";
  static const rating = "rating";
  static const text = "text";
  static const postCount = "post_count";
  static var completionDate = "completion_date";
  static var completionStartTime = "completion_start_time";
  static var completionDuration = "completion_duration";
  static const commonlyClimbedWithCount = "commonly_climbed_with_count";
  static const selectedMunroCount = "selected_munro_count";
}
