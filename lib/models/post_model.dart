import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:two_eight_two/models/models.dart';

class Post {
  final String? uid;
  final String authorId;
  final String authorDisplayName;
  final String? authorProfilePictureURL;
  final DateTime dateTime;
  final DateTime? summitedDate;
  final String title;
  final String? description;
  final Map<String, List<String>> imageUrlsMap;
  final List<Munro> includedMunros;
  final List<String> includedMunroIds;
  final int likes;
  final String privacy;

  Post({
    this.uid,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorProfilePictureURL,
    required this.dateTime,
    required this.summitedDate,
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
    List<String> includedMunroIds = [];
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
      PostFields.summitedDate: summitedDate,
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
      inlcudedMunrosList.add(Munro.fromJSON(munro));
    }

    List<String> newIncludedMunroIds = List<String>.empty();

    if (json.containsKey(PostFields.includedMunroIds)) {
      List<dynamic> includedMunroIds = json[PostFields.includedMunroIds];
      newIncludedMunroIds = List<String>.from(includedMunroIds);
    } else {
      newIncludedMunroIds = inlcudedMunrosList.map((Munro munro) => munro.id).toList();
    }

    Map<String, List<String>> newImageURLsMap = {};
    if (json.containsKey(PostFields.imageUrlsMap)) {
      Map<String, dynamic> imageUrlsMap = json[PostFields.imageUrlsMap];
      for (String key in imageUrlsMap.keys) {
        List<dynamic> imageURLs = imageUrlsMap[key];
        List<String> newImageURLs = List<String>.from(imageURLs);

        newImageURLsMap[key] = newImageURLs;
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
      summitedDate: (json[PostFields.dateTime] as Timestamp? ?? json[PostFields.dateTime] as Timestamp).toDate(),
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
    DateTime? summitedDate,
    Map<String, List<String>>? imageUrlsMap,
    String? title,
    String? description,
    List<Munro>? includedMunros,
    List<String>? includedMunroIds,
    int? likes,
    String? privacy,
  }) {
    return Post(
      uid: uid ?? this.uid,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfilePictureURL: authorProfilePictureURL ?? this.authorProfilePictureURL,
      dateTime: dateTime ?? this.dateTime,
      summitedDate: summitedDate ?? this.summitedDate,
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
  static String summitedDate = "summitedDate";
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
