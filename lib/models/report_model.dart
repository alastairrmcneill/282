class Report {
  final String? uid;
  final String reporterId;
  final String contentId;
  final DateTime dateTime;
  final String comment;
  final String type;
  final bool completed;

  Report({
    this.uid,
    required this.reporterId,
    required this.contentId,
    required this.dateTime,
    required this.comment,
    required this.type,
    required this.completed,
  });

  Map<String, dynamic> toJSON() {
    return {
      'uid': uid,
      'reporterId': reporterId,
      'contentId': contentId,
      'dateTime': dateTime,
      'comment': comment,
      'type': type,
      'completed': completed,
    };
  }

  Report copyWith({
    String? uid,
    String? reporterId,
    String? contentId,
    DateTime? dateTime,
    String? comment,
    String? type,
    bool? completed,
  }) {
    return Report(
      uid: uid ?? this.uid,
      reporterId: reporterId ?? this.reporterId,
      contentId: contentId ?? this.contentId,
      dateTime: dateTime ?? this.dateTime,
      comment: comment ?? this.comment,
      type: type ?? this.type,
      completed: completed ?? this.completed,
    );
  }
}
