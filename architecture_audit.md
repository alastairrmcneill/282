# Service Inventory & Dependencies

## Current Services (list all files in /services/)

1. **Achievement service**: gets the user achievements and stores them in notifier, marks one as acknowledged once it has been shown on screen. Unmarks one if the user deletes some munro completions. It also sets the munro challenges which are a special type of achievement which can be edited by the user. Dependent on the user state to know who the logged in user is

2. **Analytics service**: All static methods. Has a main log_event method which prints to the console and logs an event with properties to Mixpanel. The other methods are all just specific events that the user might want to track.

3. **Auth service**: responsible for getting the current user from firebase, handling google, apple and email registration and sign up, signout and delete user. It logs analytics depending on the login type, it creates users in the user service, it prompts the user for notification access through the PushNotificationService, and handles navigation post sign up or sign in. As well as logging errors and showing loading overlays.

4. **Blocked User service**: Manages user blocking functionality. Allows users to block other users and loads blocked users list. Creates BlockedUserRelationship objects and updates UserState with blocked users list. Depends on UserState and AuthService for current user context, and BlockedUserDatabase for persistence.

5. **Deep Link service**: Handles Branch deep links for sharing munros. Initializes Branch SDK, listens for deep link clicks, and handles navigation to specific munro screens. Also provides munro sharing functionality via Branch links. Depends on MunroState, SettingsService, UserService, SavedListService, and AnalyticsService. Uses complex navigation logic and error handling.

6. **Following service**: Manages user following/follower relationships. Handles follow/unfollow operations, loads followers and following lists with pagination. Updates ProfileState and FollowersState. Shows loading overlays and error dialogs. Depends on UserState, ProfileState, FollowersState, and FollowingRelationshipsDatabase.

7. **Group Filter service**: Manages friend selection for filtering munros by completion status. Loads friends list, searches friends, handles selection/deselection, and filters munros based on selected friends' completions. Updates GroupFilterState and MunroState. Depends on UserState and MunroCompletionsDatabase.

8. **Like service**: Manages post likes functionality. Handles liking/unliking posts, gets liked post IDs, manages user like state, and retrieves post likes with pagination. Updates multiple states (UserLikeState, FeedState, ProfileState, LikesState). Depends on UserState and LikeDatabase.

9. **Log service**: Centralized error logging utility. Provides static methods for error and fatal logging. In debug mode prints to console, in production sends to Sentry. Simple utility service with no dependencies on other services.

10. **Munro Completion service**: Manages munro completion records. Gets user completions, handles bulk updates, marks munros as completed when posts are created, and removes completions. Updates MunroCompletionState and depends on UserState, BulkMunroUpdateState, and MunroCompletionsDatabase.

11. **Munro Picture service**: Manages photos associated with munros and profiles. Gets munro pictures with pagination, gets profile pictures with pagination, uploads munro pictures from posts, and deletes munro pictures. Updates MunroDetailState and ProfileState. Depends on UserState, MunroPicturesDatabase, and StorageService.

12. **Munro service**: Simple service for loading munro data. Loads the complete list of munros from database and updates MunroState. Depends on MunroDatabase for data persistence.

13. **Post service**: Complex service managing post creation, editing, and feeds. Handles image upload, post creation/editing, munro completion marking, picture uploads, and manages friends/global feeds with pagination. Updates multiple states and depends on many services (MunroCompletionService, MunroPictureService, StorageService, LikeService, etc.).

14. **Profile service**: Manages user profile loading and operations. Loads user profiles, checks following status, loads profile posts and munro completions. Updates ProfileState and depends on UserState, FollowingRelationshipsDatabase, PostService, and MunroPictureService.

15. **Push Notification service**: Handles Firebase Cloud Messaging integration. Manages notification permissions, FCM token handling, background notification processing, and navigation to notification screens. Includes iOS APNS token handling and graceful error handling. Depends on UserState, SettingsState, and UserService.

16. **Remote Config service**: Manages Firebase Remote Config for feature flags and dynamic configuration. Initializes config, provides getters for different data types, and defines config field constants. Simple utility service with no dependencies on other services.

17. **Report service**: Handles content reporting functionality. Creates reports for inappropriate content with user comments and report types. Updates ReportState and depends on UserState and ReportDatabase.

18. **Review service**: Manages munro reviews and ratings. Handles review creation, editing, deletion, and retrieval with pagination. Updates CreateReviewState and ReviewsState. Depends on UserState, MunroState, and ReviewDatabase. Also triggers munro data reload after review operations.

19. **Saved List service**: Manages user's saved munro lists. Handles list creation, reading, updating, deletion, and munro add/remove operations. Updates SavedListState and depends on UserState and SavedListDatabase/SavedListMunroDatabase.

20. **Search service**: Manages user search functionality. Provides user search with pagination and result filtering (excludes blocked users). Updates UserSearchState and depends on UserState and UserService.

21. **Shared Preferences service**: Handles local storage using SharedPreferences. Manages various app settings like bulk dialog preferences, map settings, feedback survey tracking, app version tracking, onboarding status, and app usage counting. Utility service with no dependencies.

22. **Storage service**: Manages Firebase Storage operations. Handles image compression and upload for profile pictures and post images, and image deletion. Includes timeout handling and error management. Utility service with no service dependencies.

23. **User service**: Manages user CRUD operations and profile updates. Handles user creation, updating, reading, deletion, search, profile visibility, and profile picture updates. Updates UserState and ProfileState. Depends on AuthService, StorageService, and various databases.

24. **Weather service**: Fetches weather forecasts for munros using OpenWeatherMap API. Gets 7-day forecasts for selected munros with temperature unit conversion. Updates WeatherState and depends on SettingsState and MunroState.

## Current Providers (list all files with State/Notifier)

1. **AchievementsState**: Manages achievement-related state using ChangeNotifier. Tracks achievement loading status (initial/loading/loaded/error), stores list of user achievements, manages recently completed achievements queue, holds current achievement being viewed, and tracks achievement form count for UI. Provides setters for all state properties with automatic UI notifications. Includes reset() method for partial state clearing and resetAll() for complete state reset. Used primarily by Achievement Service and achievement-related screens.

2. **MunroCompletionState**: Manages user's munro completion records. Tracks loading status, error state, and list of MunroCompletion objects. Provides computed property completedMunroIds as a Set for efficient lookups. Simple state with basic CRUD operations and reset functionality. Used by Munro Completion Service.

3. **ReviewsState**: Handles munro review data with pagination support. Manages review loading status, list of Review objects, with methods for adding reviews (pagination), replacing specific reviews (after edits), and removing reviews. Tracks loading/paginating states separately. Used by Review Service and munro detail screens.

4. **SettingsState**: Manages application settings including push notifications, metric units (height/temperature), and default post visibility. Simple settings state with boolean flags and string values. Each setting has individual setter with notification. Used throughout the app for user preferences.

5. **GroupFilterState**: Complex state for friend-based munro filtering. Manages friends list with pagination, selected friends for filtering, loading states (including separate paginating state). Provides methods for friend selection/deselection, search clearing, and full reset. Used by Group Filter Service.

6. **NavigationState**: Simple navigation helper state. Tracks navigation status and stores route string for programmatic navigation. Basic state with minimal functionality. Used for deep linking and navigation coordination.

7. **NotificationsState**: Manages user notifications with pagination. Handles Notif objects list, loading states, and individual notification read status updates. Supports adding notifications for pagination and reset functionality. Used by notification screens and push notification handling.

8. **FlavorState**: Environment/flavor state holder. Simply stores AppEnvironment (dev/prod) with no additional state management. Immutable after creation. Used for environment-specific behavior.

9. **LayoutState**: UI layout helper state. Currently only manages bottom navigation bar height for responsive design. Simple numeric state with setter. Used for UI layout calculations.

10. **GlobalMunroCompletionState**: Specialized state for global munro completion statistics. Uses dependency injection with repository pattern. Fetches and stores total completion count with proper error handling and logging. More advanced state with async operation and repository dependency.

11. **ReportState**: Content reporting state. Manages report form data including content ID, report type, and comment text. Simple form state with individual field setters. Used by content reporting functionality.

12. **WeatherState**: Weather forecast state for munros. Stores list of Weather objects for 7-day forecast, loading status, and error handling. Simple state used by Weather Service for munro weather display.

13. **MunroState**: Complex central state for munro data and filtering (284 lines). Manages complete munro list, filtered lists, selected munro, search filters, map bounds, sort options, completion status sync, and multiple specialized filtered lists (create post, bulk update). Includes sophisticated filtering logic, bounds calculations, and state synchronization. Critical state used throughout the app.

14. **FollowersState**: Manages follower/following relationships with history tracking. Complex state with navigation history for both followers and following lists. Supports pagination, back navigation through history stacks, and clearing. Used by profile and following screens with sophisticated navigation patterns.

15. **ProfileState**: Comprehensive profile state with history navigation (175 lines). Manages profile data, following status, current user checks, posts, profile photos, munro completions. Implements history stacks for navigation, supports photo status tracking separately, and handles complex profile updates. Central state for all profile-related functionality.

16. **UserLikeState**: User post like tracking state. Manages liked posts as sets for efficient lookup, tracks recently liked/unliked posts for optimistic UI updates, and handles like state synchronization. Includes cleanup methods and reset functionality. Used by feed and post interactions.

17. **FeedState**: Social feed state manager. Handles both friends and global post feeds separately, supports pagination for both feeds, post updates (likes, edits), and post removal. Central state for all social feed functionality with dual feed support.

18. **UserState**: Core user authentication and profile state. Manages current user data, blocked users list, loading status, and error handling. Includes special method for updating user without notification. Critical state used throughout the app for authentication and user context.

19. **SavedListState**: User's saved munro lists management. Handles list of SavedList objects with full CRUD operations (add, update, remove), loading states, and error handling. Used by saved lists functionality and munro saving features.

20. **UserSearchState**: User search functionality state. Manages search results as list of AppUser objects, supports pagination with addUsers method, and handles search loading states. Used by user search screens and friend discovery.

## Current Navigation Points

1. **home_screen.dart**: the main landing screen for the app has calls to the lots of services in its init method: SettingsSerivce.loadSettings(context), UserService.readCurrentUser(context), MunroService.loadMunroData(context), MunroCompletionService.getUserMunroCompletions(context), AchievementService.getUserAchievements(context), BlockedUserService.loadBlockedUsers(context), SavedListService.readUserSavedLists(context), PushNotificationService.checkAndUpdateFCMToken(context). I also access lots of these services when navigating between tabs to load data for that tab, meaning the data loads every time the tab is clicked. PostService.getGlobalFeed(context), PostService.getFriendsFeed(context), NotificationsService.getUserNotifications(context), SavedListService.readUserSavedLists(context), ProfileService.loadUserFromUid(context, userId: user.uid!) are all accessed before navigating to the appropriate tab. I also access the following providers in the build method: final user = Provider.of<AppUser?>(context, listen: false), NavigationState navigationState = Provider.of<NavigationState>(context, listen: false), ProfileState profileState = Provider.of<ProfileState>(context, listen: false), FollowersState followersState = Provider.of<FollowersState>(context, listen: false), MunroState munroState = Provider.of<MunroState>(context, listen: false). This screen does a lot of the heavy lifting before going into other screens.

2. **notifications_screen.dart**: Accessed via '/notifications' route. In initState, accesses NotificationsState via Provider.of for setting up pagination scroll listener. Service calls include NotificationsService.paginateUserNotifications(context) for scroll pagination, NotificationsService.getUserNotifications(context) for refresh, and NotificationsService.markAllNotificationsAsRead(context) when leaving screen via PopScope. Uses Consumer<NotificationsState> in build method.

3. **profile_screen.dart**: Accessed via '/profile' route. In initState, accesses ProfileState for pagination scroll controller setup. Service calls include PostService.paginateProfilePosts(context) for scroll pagination, BlockedUserService.blockUser(context, userId: profileState.profile?.id) for user blocking, and various Provider.of calls for ReportState when reporting users. Uses Consumer<ProfileState> in build method.

4. **munro_screen.dart**: Accessed via '/munro' route. In initState, calls AnalyticsService.logMunroViewed() immediately with munro details from MunroState. Service calls include MunroService.loadMunroData(context) for pull-to-refresh. Accesses MunroState via Provider.of. Contains complex nested widgets that make additional service calls (MunroWeatherWidget calls WeatherService.getWeather).

5. **create_post_screen.dart**: Accessed via '/posts/create' route. No direct service calls in initState, but uses Consumer<CreatePostState> for reactive UI. In post-creation flow, navigates to CreateReviewsScreen and accesses CreateReviewState and MunroState via Provider.of for review setup. Service calls are handled within the CreatePostState and PostService.

6. **likes_screen.dart**: Accessed via '/posts/likes' route. In initState, sets up scroll controller with pagination listener that calls LikeService.paginatePostLikes(context). Accesses LikesState via Provider.of for scroll control logic.

7. **reviews_screen.dart**: Accessed via '/reviews' route. In initState, sets up scroll controller with pagination listener that calls ReviewService.paginateMunroReviews(context). Accesses ReviewsState via Provider.of for scroll control logic.

8. **settings_screen.dart**: Accessed via '/settings' route. In build method, accesses AppUser via Provider.of<AppUser?> and FlavorState via Provider.of<FlavorState>. No service calls in this main settings screen, but navigates to sub-settings screens that make service calls.

9. **notification_settings_screen.dart**: Accessed via '/settings/notifications' route. Accesses SettingsState via Provider.of in build method. Service calls include SettingsSerivce.setBoolSetting() for setting persistence, PushNotificationService.applyFCMToken(context) when enabling notifications, and PushNotificationService.removeFCMToken(context) when disabling.

10. **weather_screen.dart**: Accessed via weather navigation. Uses WeatherService.getWeather(context) in MunroWeatherWidget initState. Accesses WeatherState, SettingsState, and MunroState via Provider.of.

11. **achievements_completed_screen.dart**: Accessed via '/achievements_completed' route. No service calls in initState (only confetti controller setup), but uses Provider.of<AchievementsState> and likely calls AchievementService methods through user interactions.

12. **user_search_screen.dart**: Likely contains SearchService.search() and SearchService.paginateSearch() calls with UserSearchState management, following the same pagination pattern as other screens.

13. **group_filter_screen.dart**: Contains GroupFilterService calls for loading friends, searching, and managing selections. Uses GroupFilterState for managing filter selections and friend lists.

14. **munro_photo_gallery_screen.dart**: Contains MunroPictureService.paginateMunroPictures() calls and MunroDetailState management for photo browsing.

15. **bulk_munro_update_screen.dart**: Contains MunroCompletionService.bulkUpdateMunros() calls and BulkMunroUpdateState management for bulk operations.

## Problem Areas Identified

- **No separation of concerns**: there is lots of linked logic between the layers of services, repos, and UI
- **Navigation**: is handled in lots of different places
- **App start up** is inconsistent. The app falls over when opening notifications, it falls over when restarting through flutter and is slow to start up.
