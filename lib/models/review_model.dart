import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String? uid;
  final String munroId;
  final String authorId;
  final String authorDisplayName;
  final String? authorProfilePictureURL;
  final DateTime dateTime;
  final int rating;
  final String text;

  Review({
    this.uid,
    required this.munroId,
    required this.authorId,
    required this.authorDisplayName,
    required this.authorProfilePictureURL,
    required this.dateTime,
    required this.rating,
    required this.text,
  });

  // To JSON
  Map<String, dynamic> toJSON() {
    return {
      ReviewFields.uid: uid,
      ReviewFields.munroId: munroId,
      ReviewFields.authorId: authorId,
      ReviewFields.authorDisplayName: authorDisplayName,
      ReviewFields.authorProfilePictureURL: authorProfilePictureURL,
      ReviewFields.dateTime: dateTime,
      ReviewFields.rating: rating,
      ReviewFields.text: text,
    };
  }

  // To Supabase
  Map<String, dynamic> toSupabase() {
    return {
      ReviewFields.munroIdSupabase: munroId,
      ReviewFields.authorIdSupabase: authorId,
      ReviewFields.rating: rating,
      ReviewFields.text: text,
    };
  }

  // From JSON
  static Review fromJSON(Map<String, dynamic> json) {
    return Review(
      uid: json[ReviewFields.uid] as String?,
      munroId: json[ReviewFields.munroId] as String,
      authorId: json[ReviewFields.authorId] as String,
      authorDisplayName: json[ReviewFields.authorDisplayName] as String,
      authorProfilePictureURL: json[ReviewFields.authorProfilePictureURL] as String?,
      dateTime: (json[ReviewFields.dateTime] as Timestamp).toDate(),
      rating: json[ReviewFields.rating] as int,
      text: json[ReviewFields.text] as String,
    );
  }

  // From Supabase
  static Review fromSupabase(Map<String, dynamic> json) {
    return Review(
      uid: json[ReviewFields.uidSupabase] as String?,
      munroId: (json[ReviewFields.munroIdSupabase] as int).toString(),
      authorId: json[ReviewFields.authorIdSupabase] as String,
      authorDisplayName: json[ReviewFields.authorDisplayNameSupabase] as String,
      authorProfilePictureURL: json[ReviewFields.authorProfilePictureURLSupabase] as String?,
      dateTime: DateTime.parse(json[ReviewFields.dateTimeSupabase] as String),
      rating: json[ReviewFields.rating] as int,
      text: json[ReviewFields.text] as String,
    );
  }

  // Copy
  Review copyWith({
    String? uid,
    String? munroId,
    String? authorId,
    String? authorDisplayName,
    String? authorProfilePictureURL,
    DateTime? dateTime,
    int? rating,
    String? text,
  }) {
    return Review(
      uid: uid ?? this.uid,
      munroId: munroId ?? this.munroId,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfilePictureURL: authorProfilePictureURL ?? this.authorProfilePictureURL,
      dateTime: dateTime ?? this.dateTime,
      rating: rating ?? this.rating,
      text: text ?? this.text,
    );
  }
}

class ReviewFields {
  static const String uid = 'uid';
  static const String munroId = 'munroId';
  static const String authorId = 'authorId';
  static const String authorDisplayName = 'authorDisplayName';
  static const String authorProfilePictureURL = 'authorProfilePictureURL';
  static const String dateTime = 'dateTime';
  static const String rating = 'rating';
  static const String text = 'text';

  static const String uidSupabase = 'id';
  static const String munroIdSupabase = 'munro_id';
  static const String authorIdSupabase = 'author_id';
  static const String authorDisplayNameSupabase = 'author_display_name';
  static const String authorProfilePictureURLSupabase = 'author_profile_picture_url';
  static const String dateTimeSupabase = 'date_time_created';
}
