class MunroCompletion {
  String? id;
  String userId;
  int munroId;
  DateTime dateTimeCompleted;
  String? postId;

  MunroCompletion({
    this.id,
    required this.userId,
    required this.munroId,
    required this.dateTimeCompleted,
    this.postId,
  });

  factory MunroCompletion.fromJSON(Map<String, dynamic> json) => MunroCompletion(
        id: json[MunroCompletionFields.id] as String?,
        userId: json[MunroCompletionFields.userId] as String,
        munroId: json[MunroCompletionFields.munroId] as int,
        dateTimeCompleted: DateTime.parse(json[MunroCompletionFields.dateTimeCompleted] as String),
        postId: json[MunroCompletionFields.postId] as String?,
      );

  Map<String, dynamic> toJSON() => {
        if (id != null) MunroCompletionFields.id: id,
        MunroCompletionFields.userId: userId,
        MunroCompletionFields.munroId: munroId,
        MunroCompletionFields.dateTimeCompleted: dateTimeCompleted.toIso8601String(),
        MunroCompletionFields.postId: postId,
      };
}

class MunroCompletionFields {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String munroId = 'munro_id';
  static const String dateTimeCompleted = 'date_time_completed';
  static const String postId = 'post_id';
}
