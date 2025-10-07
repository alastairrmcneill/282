import 'package:two_eight_two/models/models.dart';

class Post {
  final String? uid;
  final String authorId;
  final String? authorDisplayName;
  final String? authorProfilePictureURL;
  final DateTime dateTimeCreated;
  final DateTime? summitedDateTime;
  final Duration? duration;
  final String title;
  final String? description;
  final Map<int, List<String>> imageUrlsMap;
  final List<int> includedMunroIds;
  final int likes;
  final String privacy;

  Post({
    this.uid,
    required this.authorId,
    this.authorDisplayName,
    this.authorProfilePictureURL,
    required this.dateTimeCreated,
    required this.summitedDateTime,
    this.duration,
    required this.imageUrlsMap,
    required this.title,
    this.description,
    required this.includedMunroIds,
    required this.likes,
    required this.privacy,
  });

  // To JSON
  Map<String, dynamic> toJSON() {
    return {
      PostFields.authorId: authorId,
      PostFields.title: title,
      PostFields.description: description,
      PostFields.dateTimeCreated: dateTimeCreated.toIso8601String(),
      PostFields.privacy: privacy,
    };
  }

  // From JSON
  static Post fromJSON(Map<String, dynamic> json) {
    List<dynamic> includedMunroIds = json[PostFields.includedMunroIds] as List<dynamic>? ?? [];
    List<int> newIncludedMunroIds = [];
    for (var includedMunroId in includedMunroIds) {
      if (includedMunroId != null) {
        newIncludedMunroIds.add(includedMunroId);
      }
    }

    Map<String, dynamic> imageUrls = (json[PostFields.imageUrlsMap] as Map<String, dynamic>?) ?? {};
    Map<int, List<String>> newImageUrlsMap = {};
    imageUrls.forEach((key, value) {
      newImageUrlsMap[int.parse(key)] = List<String>.from(value);
    });

    return Post(
      uid: json[PostFields.uid] as String?,
      authorId: json[PostFields.authorId] as String,
      authorDisplayName: json[PostFields.authorDisplayName] as String,
      authorProfilePictureURL: json[PostFields.authorProfilePictureURL] as String?,
      dateTimeCreated: DateTime.parse(json[PostFields.dateTimeCreated] as String),
      summitedDateTime:
          DateTime.parse(json[PostFields.summitedDateTime] as String? ?? DateTime.now().toIso8601String()),
      imageUrlsMap: newImageUrlsMap,
      title: json[PostFields.title] as String,
      description: json[PostFields.description] as String?,
      includedMunroIds: newIncludedMunroIds,
      likes: json[PostFields.likes] as int,
      privacy: json[PostFields.privacy] as String? ?? Privacy.public,
    );
  }

  // Copy
  Post copyWith({
    String? uid,
    String? authorId,
    String? authorDisplayName,
    String? authorProfilePictureURL,
    DateTime? dateTimeCreated,
    DateTime? summitedDateTime,
    Map<int, List<String>>? imageUrlsMap,
    String? title,
    String? description,
    List<Munro>? includedMunros,
    List<int>? includedMunroIds,
    int? likes,
    String? privacy,
  }) {
    return Post(
      uid: uid ?? this.uid,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfilePictureURL: authorProfilePictureURL ?? this.authorProfilePictureURL,
      dateTimeCreated: dateTimeCreated ?? this.dateTimeCreated,
      summitedDateTime: summitedDateTime ?? this.summitedDateTime,
      imageUrlsMap: imageUrlsMap ?? this.imageUrlsMap,
      title: title ?? this.title,
      description: description ?? this.description,
      includedMunroIds: includedMunroIds ?? this.includedMunroIds,
      likes: likes ?? this.likes,
      privacy: privacy ?? this.privacy,
    );
  }
}

class PostFields {
  static String uid = "id";
  static String authorId = "author_id";
  static String authorDisplayName = "author_display_name";
  static String authorProfilePictureURL = "author_profile_picture_url";
  static String dateTimeCreated = "date_time_created";
  static String summitedDateTime = "summited_date_time";
  static String imageUrlsMap = "image_urls";
  static String title = "title";
  static String description = "description";
  static String includedMunroIds = "included_munro_ids";
  static String likes = "likes";
  static String privacy = "privacy";
  static String userId = "user_id";
}

class Privacy {
  static String public = "public";
  static String friends = "friends";
  static String private = "private";
  static String hidden = "hidden";
}

class PrivacyDescriptions {
  static String public = "Visible to everyone. Your post will show up in the global feed.";
  static String friends = "Visible to friends. Your post will show up in your friends' feeds.";
  static String private =
      "Visible to only you. Your post will not show up in any feeds and will only be seen on your profile.";
  static String hidden = "Hidden";
}
