import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';
import 'package:two_eight_two/models/models.dart';

class Post {
  final String uid;
  final String authorId;
  final String authorDisplayName;
  final String title;
  final DateTime dateTimeCreated;
  final DateTime? dateTimeCompleted;
  final Map<int, List<String>> imageUrlsMap;
  final List<int> includedMunroIds;
  final int likes;
  final String privacy;
  final String? authorProfilePictureURL;
  final DateTime? completionDate;
  final TimeOfDay? completionStartTime;
  final Duration? completionDuration;
  final String? description;
  final int? munroCountAtPostDateTime;

  Post({
    String? uid,
    required this.authorId,
    String? authorDisplayName,
    this.authorProfilePictureURL,
    DateTime? dateTimeCreated,
    this.dateTimeCompleted,
    this.completionDate,
    this.completionStartTime,
    this.completionDuration,
    String? title,
    this.description,
    Map<int, List<String>>? imageUrlsMap,
    List<int>? includedMunroIds,
    int? likes,
    String? privacy,
    this.munroCountAtPostDateTime,
  })  : uid = uid ?? '',
        authorDisplayName = authorDisplayName ?? '',
        dateTimeCreated = dateTimeCreated ?? DateTime.now(),
        title = title ?? '',
        imageUrlsMap = imageUrlsMap ?? {},
        includedMunroIds = includedMunroIds ?? [],
        likes = likes ?? 0,
        privacy = privacy ?? Privacy.public;

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

    DateTime? completionDate;
    TimeOfDay? completionStartTime;
    Duration? completionDuration;

    if (json[PostFields.completionDate] != null) {
      completionDate = DateTime.parse(json[PostFields.completionDate] as String);
    }

    if (json[PostFields.completionStartTime] != null) {
      completionStartTime = TimeOfDayExtension.from24Hour(json[PostFields.completionStartTime] as String);
    }

    if (json[PostFields.completionDuration] != null) {
      completionDuration = Duration(seconds: json[PostFields.completionDuration] as int);
    }

    return Post(
      uid: json[PostFields.uid] as String?,
      authorId: json[PostFields.authorId] as String? ?? "",
      authorDisplayName: json[PostFields.authorDisplayName] as String? ?? "",
      authorProfilePictureURL: json[PostFields.authorProfilePictureURL] as String? ?? "",
      dateTimeCreated: DateTime.parse(json[PostFields.dateTimeCreated] as String? ?? DateTime.now().toIso8601String()),
      dateTimeCompleted:
          DateTime.parse(json[PostFields.dateTimeCompleted] as String? ?? DateTime.now().toIso8601String()),
      completionDate: completionDate,
      completionStartTime: completionStartTime,
      completionDuration: completionDuration,
      imageUrlsMap: newImageUrlsMap,
      title: json[PostFields.title] as String? ?? "",
      description: json[PostFields.description] as String? ?? "",
      includedMunroIds: newIncludedMunroIds,
      likes: json[PostFields.likes] as int? ?? 0,
      privacy: json[PostFields.privacy] as String? ?? Privacy.public,
      munroCountAtPostDateTime: json[PostFields.munroCountAtPostDateTime] as int?,
    );
  }

  // Copy
  Post copyWith({
    String? uid,
    String? authorId,
    String? authorDisplayName,
    String? authorProfilePictureURL,
    DateTime? dateTimeCreated,
    DateTime? dateTimeCompleted,
    DateTime? completionDate,
    TimeOfDay? completionStartTime,
    Duration? completionDuration,
    Map<int, List<String>>? imageUrlsMap,
    String? title,
    String? description,
    List<Munro>? includedMunros,
    List<int>? includedMunroIds,
    int? likes,
    String? privacy,
    int? munroCountAtPostDateTime,
  }) {
    return Post(
      uid: uid ?? this.uid,
      authorId: authorId ?? this.authorId,
      authorDisplayName: authorDisplayName ?? this.authorDisplayName,
      authorProfilePictureURL: authorProfilePictureURL ?? this.authorProfilePictureURL,
      dateTimeCreated: dateTimeCreated ?? this.dateTimeCreated,
      dateTimeCompleted: dateTimeCompleted ?? this.dateTimeCompleted,
      completionDate: completionDate ?? this.completionDate,
      completionStartTime: completionStartTime ?? this.completionStartTime,
      completionDuration: completionDuration ?? this.completionDuration,
      imageUrlsMap: imageUrlsMap ?? this.imageUrlsMap,
      title: title ?? this.title,
      description: description ?? this.description,
      includedMunroIds: includedMunroIds ?? this.includedMunroIds,
      likes: likes ?? this.likes,
      privacy: privacy ?? this.privacy,
      munroCountAtPostDateTime: munroCountAtPostDateTime ?? this.munroCountAtPostDateTime,
    );
  }
}

class PostFields {
  static String uid = "id";
  static String authorId = "author_id";
  static String authorDisplayName = "author_display_name";
  static String authorProfilePictureURL = "author_profile_picture_url";
  static String dateTimeCreated = "date_time_created";
  static String dateTimeCompleted = "date_time_completed";
  static String completionDate = "completion_date";
  static String completionStartTime = "completion_start_time";
  static String completionDuration = "completion_duration";
  static String imageUrlsMap = "image_urls";
  static String title = "title";
  static String description = "description";
  static String includedMunroIds = "included_munro_ids";
  static String likes = "likes";
  static String privacy = "privacy";
  static String userId = "user_id";
  static String munroCountAtPostDateTime = "munro_count_at_post_date_time";
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
