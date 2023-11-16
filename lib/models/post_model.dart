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
  final int likes;

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
    required this.likes,
  });

  // To JSON
  Map<String, dynamic> toJSON() {
    List<Map<String, dynamic>> includedMunrosMaps = [];
    for (var munro in includedMunros) {
      includedMunrosMaps.add(munro.toJSON());
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
      PostFields.likes: likes,
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

    return Post(
      uid: json[PostFields.uid] as String?,
      authorId: json[PostFields.authorId] as String,
      authorDisplayName: json[PostFields.authorDisplayName] as String,
      authorProfilePictureURL: json[PostFields.authorProfilePictureURL] as String?,
      dateTime: (json[PostFields.dateTime] as Timestamp).toDate(),
      imageURLs: newImageURLs,
      title: json[PostFields.title] as String,
      description: json[PostFields.description] as String?,
      includedMunros: inlcudedMunrosList,
      likes: json[PostFields.likes] as int,
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
    int? likes,
  }) {
    return Post(
      uid: uid ?? this.uid,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfilePictureURL: authorProfilePictureURL ?? this.authorProfilePictureURL,
      dateTime: dateTime ?? this.dateTime,
      imageURLs: imageURLs ?? this.imageURLs,
      title: title ?? this.title,
      description: description ?? this.description,
      includedMunros: includedMunros ?? this.includedMunros,
      likes: likes ?? this.likes,
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
  static String likes = "likes";
}
