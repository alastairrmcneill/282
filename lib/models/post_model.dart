import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:two_eight_two/models/models.dart';

class Post {
  final String? uid;
  final String authorId;
  final String authorDisplayName;
  final String? authorProfilePictureURL;
  final DateTime dateTime;
  final String title;
  final String? description;
  final List<String> imageURLs;
  final List<Munro> includedMunros;
  final List<int> includedMunroIds;
  final int likes;
  final bool public;

  Post({
    this.uid,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorProfilePictureURL,
    required this.dateTime,
    required this.imageURLs,
    required this.title,
    this.description,
    required this.includedMunros,
    required this.includedMunroIds,
    required this.likes,
    required this.public,
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
      PostFields.imageURLs: imageURLs,
      PostFields.title: title,
      PostFields.description: description,
      PostFields.includedMunros: includedMunrosMaps,
      PostFields.includedMunroIds: includedMunroIds,
      PostFields.likes: likes,
      PostFields.public: public,
    };
  }

  // From JSON
  static Post fromJSON(Map<String, dynamic> json) {
    List<dynamic> imageURLs = json[PostFields.imageURLs];
    List<String> newImageURLs = List<String>.from(imageURLs);

    List<dynamic> includedMunrosMaps = json[PostFields.includedMunros];

    List<Munro> inlcudedMunrosList = [];
    for (var munro in includedMunrosMaps) {
      inlcudedMunrosList.add(Munro.fromJSON(munro));
    }

    List<int> newIncludedMunroIds = List<int>.empty();

    if (json.containsKey(PostFields.includedMunroIds)) {
      List<dynamic> includedMunroIds = json[PostFields.includedMunroIds];
      newIncludedMunroIds = List<int>.from(includedMunroIds);
    } else {
      newIncludedMunroIds =
          inlcudedMunrosList.map((Munro munro) => munro.id).toList();
    }

    return Post(
      uid: json[PostFields.uid] as String?,
      authorId: json[PostFields.authorId] as String,
      authorDisplayName: json[PostFields.authorDisplayName] as String,
      authorProfilePictureURL:
          json[PostFields.authorProfilePictureURL] as String?,
      dateTime: (json[PostFields.dateTime] as Timestamp).toDate(),
      imageURLs: newImageURLs,
      title: json[PostFields.title] as String,
      description: json[PostFields.description] as String?,
      includedMunros: inlcudedMunrosList,
      includedMunroIds: newIncludedMunroIds,
      likes: json[PostFields.likes] as int,
      public: json[PostFields.public] as bool? ?? true,
    );
  }

  // Copy
  Post copyWith({
    String? uid,
    String? authorId,
    String? authorDisplayName,
    String? authorProfilePictureURL,
    DateTime? dateTime,
    List<String>? imageURLs,
    String? title,
    String? description,
    List<Munro>? includedMunros,
    List<int>? includedMunroIds,
    int? likes,
    bool? public,
  }) {
    return Post(
      uid: uid ?? this.uid,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfilePictureURL:
          authorProfilePictureURL ?? this.authorProfilePictureURL,
      dateTime: dateTime ?? this.dateTime,
      imageURLs: imageURLs ?? this.imageURLs,
      title: title ?? this.title,
      description: description ?? this.description,
      includedMunros: includedMunros ?? this.includedMunros,
      includedMunroIds: includedMunroIds ?? this.includedMunroIds,
      likes: likes ?? this.likes,
      public: public ?? this.public,
    );
  }
}

class PostFields {
  static String uid = "uid";
  static String authorId = "authorId";
  static String authorDisplayName = "authorDisplayName";
  static String authorProfilePictureURL = "authorProfilePictureURL";
  static String dateTime = "dateTime";
  static String imageURLs = "imageURLs";
  static String title = "title";
  static String description = "description";
  static String includedMunros = "includedMunros";
  static String includedMunroIds = "includedMunroIds";
  static String likes = "likes";
  static String public = "public";
}
