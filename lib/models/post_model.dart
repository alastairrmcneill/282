import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:two_eight_two/models/models.dart';

class Post {
  final String? uid;
  final String authorId;
  final String authorDisplayName;
  final String? authorProfilePictureURL;
  final DateTime dateTime;
  final DateTime? summitedDateTime;
  final Duration? duration;
  final String title;
  final String? description;
  final Map<int, List<String>> imageUrlsMap;
  final List<Munro> includedMunros;
  final List<int> includedMunroIds;
  final int likes;
  final String privacy;

  Post({
    this.uid,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorProfilePictureURL,
    required this.dateTime,
    required this.summitedDateTime,
    required this.duration,
    required this.imageUrlsMap,
    required this.title,
    this.description,
    required this.includedMunros,
    required this.includedMunroIds,
    required this.likes,
    required this.privacy,
  });

  // To JSON
  Map<String, dynamic> toJSON() {
    List<Map<String, dynamic>> includedMunrosMaps = [];
    List<int> includedMunroIds = [];
    for (var munro in includedMunros) {
      includedMunrosMaps.add(munro.toJSON());
      includedMunroIds.add(munro.id);
    }

    return {
      PostFields.uid: uid,
      PostFields.authorId: authorId,
      PostFields.authorDisplayName: authorDisplayName,
      PostFields.authorProfilePictureURL: authorProfilePictureURL,
      PostFields.dateTime: dateTime,
      PostFields.summitedDateTime: summitedDateTime,
      PostFields.duration: duration?.inMilliseconds,
      PostFields.imageUrlsMap: imageUrlsMap,
      PostFields.title: title,
      PostFields.description: description,
      PostFields.includedMunros: includedMunrosMaps,
      PostFields.includedMunroIds: includedMunroIds,
      PostFields.likes: likes,
      PostFields.privacy: privacy,
    };
  }

  // From JSON
  static Post fromJSON(Map<String, dynamic> json) {
    List<dynamic> includedMunrosMaps = json[PostFields.includedMunros];

    List<Munro> inlcudedMunrosList = [];
    for (var munro in includedMunrosMaps) {
      inlcudedMunrosList.add(Munro.fromPost(munro));
    }

    List<int> newIncludedMunroIds = List<int>.empty();

    if (json.containsKey(PostFields.includedMunroIds)) {
      List<dynamic> includedMunroIds = json[PostFields.includedMunroIds];
      newIncludedMunroIds = List<String>.from(includedMunroIds).map((e) => int.parse(e)).toList();
    } else {
      newIncludedMunroIds = inlcudedMunrosList.map((Munro munro) => munro.id).toList();
    }

    Map<int, List<String>> newImageURLsMap = {};
    if (json.containsKey(PostFields.imageUrlsMap)) {
      Map<String, dynamic> imageUrlsMap = json[PostFields.imageUrlsMap];
      for (String key in imageUrlsMap.keys) {
        List<dynamic> imageURLs = imageUrlsMap[key];
        List<String> newImageURLs = List<String>.from(imageURLs);

        newImageURLsMap[int.parse(key)] = newImageURLs;
      }
    } else {
      List<dynamic> imageURLs = json[PostFields.imageURLs];
      List<String> newImageURLs = List<String>.from(imageURLs);

      newImageURLsMap[newIncludedMunroIds[0]] = newImageURLs;
    }

    return Post(
      uid: json[PostFields.uid] as String?,
      authorId: json[PostFields.authorId] as String,
      authorDisplayName: json[PostFields.authorDisplayName] as String,
      authorProfilePictureURL: json[PostFields.authorProfilePictureURL] as String?,
      dateTime: (json[PostFields.dateTime] as Timestamp).toDate(),
      summitedDateTime:
          (json[PostFields.summitedDateTime] as Timestamp? ?? json[PostFields.dateTime] as Timestamp).toDate(),
      duration: Duration(milliseconds: json[PostFields.duration] as int? ?? 0),
      imageUrlsMap: newImageURLsMap,
      title: json[PostFields.title] as String,
      description: json[PostFields.description] as String?,
      includedMunros: inlcudedMunrosList,
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
    DateTime? dateTime,
    DateTime? summitedDateTime,
    Duration? duration,
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
      dateTime: dateTime ?? this.dateTime,
      summitedDateTime: summitedDateTime ?? this.summitedDateTime,
      duration: duration ?? this.duration,
      imageUrlsMap: imageUrlsMap ?? this.imageUrlsMap,
      title: title ?? this.title,
      description: description ?? this.description,
      includedMunros: includedMunros ?? this.includedMunros,
      includedMunroIds: includedMunroIds ?? this.includedMunroIds,
      likes: likes ?? this.likes,
      privacy: privacy ?? this.privacy,
    );
  }
}

class PostFields {
  static String uid = "uid";
  static String authorId = "authorId";
  static String authorDisplayName = "authorDisplayName";
  static String authorProfilePictureURL = "authorProfilePictureURL";
  static String dateTime = "dateTime";
  static String summitedDateTime = "summitedDateTime";
  static String duration = "duration";
  static String imageURLs = "imageURLs";
  static String imageUrlsMap = "imageUrlsMap";
  static String title = "title";
  static String description = "description";
  static String includedMunros = "includedMunros";
  static String includedMunroIds = "includedMunroIds";
  static String likes = "likes";
  static String privacy = "privacy";
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
