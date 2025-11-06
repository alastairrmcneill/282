class Profile {
  String? id;
  String? firstName;
  String? lastName;
  String? displayName;
  String? searchName;
  String? bio;
  String? profilePictureURL;
  String? fcmToken;
  String? appVersion;
  String? platform;
  String? signInMethod;
  DateTime? dateTimeCreated;
  String? profileVisibility;
  int? followersCount;
  int? followingCount;
  int? annualGoalTarget;
  int? annualGoalProgress;
  String? annualGoalId;
  int? annualGoalYear;
  int? munrosCompleted;

  Profile({
    this.id,
    this.firstName,
    this.lastName,
    this.displayName,
    this.searchName,
    this.profilePictureURL,
    this.bio,
    this.fcmToken,
    this.appVersion,
    this.platform,
    this.signInMethod,
    this.dateTimeCreated,
    this.profileVisibility,
    this.followersCount,
    this.followingCount,
    this.annualGoalTarget,
    this.annualGoalProgress,
    this.annualGoalId,
    this.annualGoalYear,
    this.munrosCompleted,
  });

  static Profile fromJSON(Map<String, dynamic> json) {
    return Profile(
      id: json[ProfileFields.id] as String?,
      firstName: json[ProfileFields.firstName] as String?,
      lastName: json[ProfileFields.lastName] as String?,
      displayName: json[ProfileFields.displayName] as String?,
      searchName: json[ProfileFields.searchName] as String?,
      bio: json[ProfileFields.bio] as String?,
      profilePictureURL: json[ProfileFields.profilePictureURL] as String?,
      fcmToken: json[ProfileFields.fcmToken] as String?,
      appVersion: json[ProfileFields.appVersion] as String?,
      platform: json[ProfileFields.platform] as String?,
      signInMethod: json[ProfileFields.signInMethod] as String?,
      dateTimeCreated:
          DateTime.parse(json[ProfileFields.dateTimeCreated] as String? ?? DateTime.now().toUtc().toString()),
      profileVisibility: json[ProfileFields.profileVisibility] as String?,
      followersCount: json[ProfileFields.followersCount] as int?,
      followingCount: json[ProfileFields.followingCount] as int?,
      annualGoalProgress: json[ProfileFields.annualGoalProgress] as int?,
      annualGoalTarget: json[ProfileFields.annualGoalTarget] as int?,
      annualGoalId: json[ProfileFields.annualGoalId] as String?,
      annualGoalYear: int.tryParse(json[ProfileFields.annualGoalYear] as String? ?? '') ?? 0,
      munrosCompleted: json[ProfileFields.munrosCompleted] as int?,
    );
  }

  Profile copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? displayName,
    String? searchName,
    String? bio,
    String? profilePictureURL,
    String? fcmToken,
    String? appVersion,
    String? platform,
    String? signInMethod,
    DateTime? dateTimeCreated,
    String? profileVisibility,
    int? followersCount,
    int? followingCount,
    int? annualGoalTarget,
    int? annualGoalProgress,
    String? annualGoalId,
    int? annualGoalYear,
    int? munrosCompleted,
  }) {
    return Profile(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      searchName: searchName ?? this.searchName,
      bio: bio ?? this.bio,
      profilePictureURL: profilePictureURL ?? this.profilePictureURL,
      fcmToken: fcmToken ?? this.fcmToken,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      signInMethod: signInMethod ?? this.signInMethod,
      dateTimeCreated: dateTimeCreated ?? this.dateTimeCreated,
      profileVisibility: profileVisibility ?? this.profileVisibility,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      annualGoalTarget: annualGoalTarget ?? this.annualGoalTarget,
      annualGoalProgress: annualGoalProgress ?? this.annualGoalProgress,
      annualGoalId: annualGoalId ?? this.annualGoalId,
      annualGoalYear: annualGoalYear ?? this.annualGoalYear,
      munrosCompleted: munrosCompleted ?? this.munrosCompleted,
    );
  }

  @override
  String toString() {
    return '''Profile {${ProfileFields.id}: $id, 
              ${ProfileFields.firstName}: $firstName, 
              ${ProfileFields.lastName}: $lastName, 
              ${ProfileFields.displayName}: $displayName, 
              ${ProfileFields.searchName}: $searchName, 
              ${ProfileFields.bio}: $bio, 
              ${ProfileFields.profilePictureURL}: $profilePictureURL, 
              ${ProfileFields.fcmToken}: $fcmToken, 
              ${ProfileFields.appVersion}: $appVersion, 
              ${ProfileFields.platform}: $platform, 
              ${ProfileFields.signInMethod}: $signInMethod, 
              ${ProfileFields.dateTimeCreated}: $dateTimeCreated, 
              ${ProfileFields.profileVisibility}: $profileVisibility, 
              ${ProfileFields.followersCount}: $followersCount, 
              ${ProfileFields.followingCount}: $followingCount, 
              ${ProfileFields.annualGoalTarget}: $annualGoalTarget, 
              ${ProfileFields.annualGoalProgress}: $annualGoalProgress, 
              ${ProfileFields.annualGoalId}: $annualGoalId, 
              ${ProfileFields.annualGoalYear}: $annualGoalYear,
              ${ProfileFields.munrosCompleted}: $munrosCompleted}''';
  }
}

class ProfileFields {
  static String id = 'id';
  static String firstName = 'first_name';
  static String lastName = 'last_name';
  static String displayName = 'display_name';
  static String searchName = 'search_name';
  static String bio = 'bio';
  static String profilePictureURL = 'profile_picture_url';
  static String fcmToken = 'fcm_token';
  static String appVersion = 'app_version';
  static String platform = 'platform';
  static String signInMethod = 'sign_in_method';
  static String dateTimeCreated = 'date_time_created';
  static String profileVisibility = 'profile_visibility';
  static String followersCount = 'followers_count';
  static String followingCount = 'following_count';
  static String annualGoalTarget = 'annual_goal_target';
  static String annualGoalProgress = 'annual_goal_progress';
  static String annualGoalId = 'annual_goal_id';
  static String annualGoalYear = 'annual_goal_year';
  static String munrosCompleted = 'munros_completed';
}
