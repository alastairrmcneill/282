import 'package:flutter/material.dart';

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
            ? TimeOfDay(
                hour: int.parse((json[MunroCompletionFields.completionStartTime] as String).split(":")[0]),
                minute: int.parse((json[MunroCompletionFields.completionStartTime] as String).split(":")[1]),
              )
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
        if (completionStartTime != null) MunroCompletionFields.completionStartTime: completionStartTime,
        if (completionDuration != null) MunroCompletionFields.completionDuration: completionDuration!.inSeconds,
      };
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
