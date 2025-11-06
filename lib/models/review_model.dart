class Review {
  final String? uid;
  final int munroId;
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
      ReviewFields.munroId: munroId,
      ReviewFields.authorId: authorId,
      ReviewFields.rating: rating,
      ReviewFields.text: text,
    };
  }

  // From
  static Review fromJSON(Map<String, dynamic> json) {
    return Review(
      uid: json[ReviewFields.uid] as String?,
      munroId: json[ReviewFields.munroId] as int,
      authorId: json[ReviewFields.authorId] as String,
      authorDisplayName: json[ReviewFields.authorDisplayName] as String,
      authorProfilePictureURL: json[ReviewFields.authorProfilePictureURL] as String?,
      dateTime: DateTime.parse(json[ReviewFields.dateTime] as String),
      rating: json[ReviewFields.rating] as int,
      text: json[ReviewFields.text] as String,
    );
  }

  // Copy
  Review copyWith({
    String? uid,
    int? munroId,
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
  static const String uid = 'id';
  static const String munroId = 'munro_id';
  static const String authorId = 'author_id';
  static const String authorDisplayName = 'author_display_name';
  static const String authorProfilePictureURL = 'author_profile_picture_url';
  static const String dateTime = 'date_time_created';
  static const String rating = 'rating';
  static const String text = 'text';
}
