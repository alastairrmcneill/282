import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppUser {
  final String? uid;
  String? displayName;
  String? searchName;
  String? firstName;
  String? lastName;
  String? profilePictureURL;
  int? followersCount;
  int? followingCount;
  String? bio;
  String? fcmToken;
  List<String>? blockedUsers;
  final List<Map<String, dynamic>>? personalMunroData;
  final Map<String, dynamic>? achievements;
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
    this.followersCount,
    this.followingCount,
    this.bio,
    this.fcmToken,
    this.blockedUsers,
    this.personalMunroData = personalMunroDataExample,
    this.achievements,
    this.appVersion,
    this.platform,
    this.signInMethod,
    this.dateCreated,
    this.profileVisibility,
  });

  List<Map<String, dynamic>>? get personalMunroDataAsString {
    return personalMunroData?.map((munroData) {
      if (munroData['id'] is int) {
        // Convert id to string if it's an int
        return {...munroData, 'id': munroData['id'].toString()};
      }
      return munroData;
    }).toList();
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      AppUserFields.uid: uid,
      AppUserFields.displayName: displayName,
      AppUserFields.searchName: searchName,
      AppUserFields.firstName: firstName,
      AppUserFields.lastName: lastName,
      AppUserFields.profilePictureURL: profilePictureURL,
      AppUserFields.followersCount: followersCount,
      AppUserFields.followingCount: followingCount,
      AppUserFields.bio: bio,
      AppUserFields.fcmToken: fcmToken,
      AppUserFields.blockedUsers: blockedUsers,
      AppUserFields.personalMunroData: personalMunroDataAsString,
      AppUserFields.achievements: achievements,
      AppUserFields.appVersion: appVersion,
      AppUserFields.platform: platform,
      AppUserFields.signInMethod: signInMethod,
      AppUserFields.dateCreated: dateCreated,
      AppUserFields.profileVisibility: profileVisibility,
    };
  }

  static AppUser fromJSON(Map<String, dynamic> json) {
    List<dynamic> personalMunroData = json[AppUserFields.personalMunroData];
    List<Map<String, dynamic>> listPersonalMunroData = List<Map<String, dynamic>>.from(personalMunroData);

    List<Map<String, dynamic>> listPersonalMunroDataWithString = listPersonalMunroData.map((munroData) {
      if (munroData['id'] is int) {
        return {...munroData, 'id': munroData['id'].toString()};
      }
      return munroData;
    }).toList();

    List<dynamic>? rawBlockedUsers = json[AppUserFields.blockedUsers] as List<dynamic>?;
    List<String> blockedUsers = List<String>.from(rawBlockedUsers ?? []);

    return AppUser(
      uid: json[AppUserFields.uid] as String?,
      displayName: json[AppUserFields.displayName] as String?,
      searchName: json[AppUserFields.searchName] as String?,
      firstName: json[AppUserFields.firstName] as String?,
      lastName: json[AppUserFields.lastName] as String?,
      profilePictureURL: json[AppUserFields.profilePictureURL] as String?,
      followersCount: json[AppUserFields.followersCount] as int? ?? 0,
      followingCount: json[AppUserFields.followingCount] as int? ?? 0,
      bio: json[AppUserFields.bio] as String?,
      fcmToken: json[AppUserFields.fcmToken] as String?,
      blockedUsers: blockedUsers,
      personalMunroData: listPersonalMunroDataWithString,
      achievements: json[AppUserFields.achievements] as Map<String, dynamic>? ?? {},
      appVersion: json[AppUserFields.appVersion] as String?,
      platform: json[AppUserFields.platform] as String?,
      signInMethod: json[AppUserFields.signInMethod] as String?,
      dateCreated: (json[AppUserFields.dateCreated] as Timestamp?)?.toDate(),
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
    int? followersCount,
    int? followingCount,
    String? bio,
    String? fcmToken,
    List<String>? blockedUsers,
    List<Map<String, dynamic>>? personalMunroData,
    Map<String, dynamic>? achievements,
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
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      bio: bio ?? this.bio,
      fcmToken: fcmToken ?? this.fcmToken,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      personalMunroData: personalMunroData ?? this.personalMunroData,
      achievements: achievements ?? this.achievements,
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
      ${AppUserFields.followingCount}: $followersCount, 
      ${AppUserFields.followersCount}: $followersCount, 
      ${AppUserFields.personalMunroData}: $personalMunroData, 
      ${AppUserFields.achievements}: $achievements,
      ${AppUserFields.bio}: $bio,
      ${AppUserFields.fcmToken}:$fcmToken,
      ${AppUserFields.blockedUsers}: $blockedUsers,
      ${AppUserFields.appVersion}: $appVersion,
      ${AppUserFields.platform}: $platform,
      ${AppUserFields.signInMethod}: $signInMethod,
      ${AppUserFields.dateCreated}: $dateCreated,
      ${AppUserFields.profileVisibility}: $profileVisibility,
      )''';
}

class AppUserFields {
  static String uid = 'uid';
  static String displayName = 'displayName';
  static String searchName = 'searchName';
  static String firstName = 'firstName';
  static String lastName = 'lastName';
  static String profilePictureURL = 'profilePictureURL';
  static String personalMunroData = 'personalMunroData';
  static String followingCount = 'followingCount';
  static String followersCount = 'followersCount';
  static String bio = 'bio';
  static String fcmToken = 'fcmToken';
  static String blockedUsers = 'blockedUsers';
  static String munroChallenges = 'munroChallenges';
  static String achievements = 'achievements';
  static String appVersion = 'appVersion';
  static String platform = 'platform';
  static String signInMethod = 'signInMethod';
  static String dateCreated = 'dateCreated';
  static String profileVisibility = 'profileVisibility';
}

const List<Map<String, dynamic>> personalMunroDataExample = [
  {"id": "1", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "2", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "3", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "4", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "5", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "6", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "7", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "8", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "9", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "10", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "11", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "12", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "13", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "14", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "15", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "16", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "17", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "18", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "19", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "20", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "21", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "22", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "23", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "24", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "25", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "26", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "27", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "28", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "29", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "30", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "31", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "32", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "33", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "34", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "35", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "36", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "37", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "38", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "39", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "40", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "41", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "42", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "43", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "44", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "45", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "46", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "47", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "48", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "49", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "50", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "51", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "52", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "53", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "54", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "55", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "56", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "57", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "58", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "59", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "60", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "61", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "62", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "63", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "64", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "65", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "66", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "67", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "68", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "69", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "70", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "71", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "72", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "73", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "74", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "75", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "76", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "77", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "78", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "79", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "80", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "81", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "82", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "83", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "84", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "85", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "86", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "87", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "88", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "89", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "90", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "91", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "92", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "93", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "94", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "95", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "96", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "97", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "98", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "99", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "100", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "101", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "102", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "103", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "104", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "105", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "106", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "107", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "108", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "109", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "110", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "111", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "112", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "113", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "114", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "115", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "116", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "117", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "118", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "119", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "120", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "121", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "122", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "123", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "124", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "125", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "126", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "127", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "128", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "129", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "130", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "131", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "132", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "133", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "134", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "135", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "136", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "137", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "138", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "139", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "140", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "141", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "142", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "143", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "144", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "145", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "146", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "147", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "148", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "149", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "150", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "151", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "152", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "153", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "154", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "155", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "156", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "157", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "158", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "159", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "160", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "161", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "162", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "163", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "164", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "165", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "166", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "167", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "168", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "169", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "170", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "171", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "172", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "173", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "174", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "175", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "176", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "177", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "178", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "179", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "180", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "181", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "182", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "183", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "184", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "185", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "186", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "187", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "188", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "189", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "190", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "191", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "192", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "193", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "194", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "195", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "196", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "197", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "198", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "199", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "200", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "201", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "202", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "203", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "204", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "205", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "206", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "207", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "208", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "209", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "210", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "211", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "212", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "213", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "214", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "215", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "216", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "217", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "218", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "219", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "220", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "221", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "222", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "223", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "224", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "225", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "226", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "227", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "228", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "229", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "230", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "231", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "232", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "233", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "234", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "235", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "236", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "237", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "238", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "239", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "240", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "241", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "242", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "243", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "244", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "245", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "246", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "247", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "248", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "249", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "250", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "251", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "252", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "253", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "254", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "255", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "256", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "257", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "258", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "259", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "260", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "261", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "262", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "263", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "264", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "265", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "266", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "267", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "268", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "269", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "270", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "271", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "272", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "273", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "274", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "275", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "276", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "277", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "278", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "279", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "280", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "281", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
  {"id": "282", "summited": false, "summitedDate": null, "saved": false, "summitedDates": []},
];
