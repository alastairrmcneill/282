import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String? uid;
  String? firstName;
  String? lastName;
  String? displayName;
  String? searchName;
  String? bio;
  String? profilePictureURL;
  String? fcmToken;
  final String? appVersion;
  final String? platform;
  final String? signInMethod;
  final DateTime? dateCreated;
  final String? profileVisibility;

  AppUser({
    this.uid,
    this.displayName,
    this.searchName,
    this.firstName,
    this.lastName,
    this.profilePictureURL,
    this.bio,
    this.fcmToken,
    this.appVersion,
    this.platform,
    this.signInMethod,
    this.dateCreated,
    this.profileVisibility,
  });

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      AppUserFields.uid: uid,
      AppUserFields.firstName: firstName,
      AppUserFields.lastName: lastName,
      AppUserFields.bio: bio,
      AppUserFields.profilePictureURL: profilePictureURL,
      AppUserFields.fcmToken: fcmToken,
      AppUserFields.appVersion: appVersion,
      AppUserFields.platform: platform,
      AppUserFields.signInMethod: signInMethod,
      AppUserFields.profileVisibility: profileVisibility,
    };
  }

  static AppUser fromJSON(Map<String, dynamic> json) {
    return AppUser(
      uid: json[AppUserFields.uid] as String?,
      firstName: json[AppUserFields.firstName] as String?,
      lastName: json[AppUserFields.lastName] as String?,
      displayName: json[AppUserFields.displayName] as String?,
      searchName: json[AppUserFields.searchName] as String?,
      bio: json[AppUserFields.bio] as String?,
      profilePictureURL: json[AppUserFields.profilePictureURL] as String?,
      fcmToken: json[AppUserFields.fcmToken] as String?,
      appVersion: json[AppUserFields.appVersion] as String?,
      platform: json[AppUserFields.platform] as String?,
      signInMethod: json[AppUserFields.signInMethod] as String?,
      dateCreated: DateTime.parse(json[AppUserFields.dateCreated] as String? ?? DateTime.now().toUtc().toString()),
      profileVisibility: json[AppUserFields.profileVisibility] as String?,
    );
  }

  AppUser copyWith({
    String? uid,
    String? displayName,
    String? searchName,
    String? firstName,
    String? lastName,
    String? profilePictureURL,
    String? bio,
    String? fcmToken,
    String? appVersion,
    String? platform,
    String? signInMethod,
    DateTime? dateCreated,
    String? profileVisibility,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      searchName: searchName ?? this.searchName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureURL: profilePictureURL ?? this.profilePictureURL,
      bio: bio ?? this.bio,
      fcmToken: fcmToken ?? this.fcmToken,
      appVersion: appVersion ?? this.appVersion,
      platform: platform ?? this.platform,
      signInMethod: signInMethod ?? this.signInMethod,
      dateCreated: dateCreated ?? this.dateCreated,
      profileVisibility: profileVisibility ?? this.profileVisibility,
    );
  }

  // From firebase
  static AppUser? appUserFromFirebaseUser(User? firebaseUser) {
    if (firebaseUser == null) return null;

    return AppUser(uid: firebaseUser.uid);
  }

  @override
  String toString() => '''AppUser(
      ${AppUserFields.uid}: $uid,
      ${AppUserFields.displayName}: $displayName,
      ${AppUserFields.searchName}: $searchName,
      ${AppUserFields.firstName}: $firstName,
      ${AppUserFields.lastName}: $lastName,
      ${AppUserFields.profilePictureURL}: $profilePictureURL,
      ${AppUserFields.bio}: $bio,
      ${AppUserFields.fcmToken}:$fcmToken,
      ${AppUserFields.appVersion}: $appVersion,
      ${AppUserFields.platform}: $platform,
      ${AppUserFields.signInMethod}: $signInMethod,
      ${AppUserFields.dateCreated}: $dateCreated,
      ${AppUserFields.profileVisibility}: $profileVisibility,
      )''';
}

class AppUserFields {
  static String uid = 'id';
  static String displayName = 'display_name';
  static String searchName = 'search_name';
  static String firstName = 'first_name';
  static String lastName = 'last_name';
  static String profilePictureURL = 'profile_picture_url';
  static String bio = 'bio';
  static String fcmToken = 'fcm_token';
  static String appVersion = 'app_version';
  static String platform = 'platform';
  static String signInMethod = 'sign_in_method';
  static String dateCreated = 'date_created';
  static String profileVisibility = 'profile_visibility';
}
