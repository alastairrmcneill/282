import 'package:flutter/material.dart';
import 'package:two_eight_two/extensions/extensions.dart';

class MunroCompletion {
  String? id;
  DateTime? dateTimeCreated;
  String userId;
  int munroId;
  DateTime dateTimeCompleted;
  String? postId;
  DateTime? completionDate;
  TimeOfDay? completionStartTime;
  Duration? completionDuration;

  MunroCompletion({
    this.id,
    this.dateTimeCreated,
    required this.userId,
    required this.munroId,
    required this.dateTimeCompleted,
    this.postId,
    this.completionDate,
    this.completionStartTime,
    this.completionDuration,
  });

  factory MunroCompletion.fromJSON(Map<String, dynamic> json) => MunroCompletion(
        id: json[MunroCompletionFields.id] as String?,
        userId: json[MunroCompletionFields.userId] as String,
        munroId: json[MunroCompletionFields.munroId] as int,
        dateTimeCompleted: DateTime.parse(json[MunroCompletionFields.dateTimeCompleted] as String),
        dateTimeCreated: DateTime.parse(json[MunroCompletionFields.dateTimeCreated] as String),
        postId: json[MunroCompletionFields.postId] as String?,
        completionDate: json[MunroCompletionFields.completionDate] != null
            ? DateTime.parse(json[MunroCompletionFields.completionDate] as String)
            : null,
        completionStartTime: json[MunroCompletionFields.completionStartTime] != null
            ? TimeOfDayExtension.from24Hour(json[MunroCompletionFields.completionStartTime] as String)
            : null,
        completionDuration: json[MunroCompletionFields.completionDuration] != null
            ? Duration(seconds: json[MunroCompletionFields.completionDuration] as int)
            : null,
      );

  Map<String, dynamic> toJSON() => {
        if (id != null) MunroCompletionFields.id: id,
        if (dateTimeCreated != null) MunroCompletionFields.dateTimeCreated: dateTimeCreated!.toIso8601String(),
        MunroCompletionFields.userId: userId,
        MunroCompletionFields.munroId: munroId,
        MunroCompletionFields.dateTimeCompleted: dateTimeCompleted.toIso8601String(),
        MunroCompletionFields.postId: postId,
        if (completionDate != null) MunroCompletionFields.completionDate: completionDate!.toIso8601String(),
        if (completionStartTime != null) MunroCompletionFields.completionStartTime: completionStartTime!.format24Hour(),
        if (completionDuration != null) MunroCompletionFields.completionDuration: completionDuration!.inSeconds,
      };

  MunroCompletion copyWith({
    String? id,
    DateTime? dateTimeCreated,
    String? userId,
    int? munroId,
    DateTime? dateTimeCompleted,
    String? postId,
    DateTime? completionDate,
    TimeOfDay? completionStartTime,
    Duration? completionDuration,
  }) {
    return MunroCompletion(
      id: id ?? this.id,
      dateTimeCreated: dateTimeCreated ?? this.dateTimeCreated,
      userId: userId ?? this.userId,
      munroId: munroId ?? this.munroId,
      dateTimeCompleted: dateTimeCompleted ?? this.dateTimeCompleted,
      postId: postId ?? this.postId,
      completionDate: completionDate ?? this.completionDate,
      completionStartTime: completionStartTime ?? this.completionStartTime,
      completionDuration: completionDuration ?? this.completionDuration,
    );
  }
}

class MunroCompletionFields {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String munroId = 'munro_id';
  static const String dateTimeCompleted = 'date_time_completed';
  static const String postId = 'post_id';
  static const String completionDate = 'completion_date';
  static const String completionStartTime = 'completion_start_time';
  static const String completionDuration = 'completion_duration';
  static const String dateTimeCreated = 'date_time_created';
}
