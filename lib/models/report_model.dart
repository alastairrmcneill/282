class Report {
  final String reporterId;
  final String contentId;
  final String comment;
  final String type;

  Report({
    required this.reporterId,
    required this.contentId,
    required this.comment,
    required this.type,
  });

  Map<String, dynamic> toJSON() {
    return {
      'reporter_id': reporterId,
      'content_id': contentId,
      'comment': comment,
      'type': type,
    };
  }

  Report copyWith({
    String? reporterId,
    String? contentId,
    String? comment,
    String? type,
  }) {
    return Report(
      reporterId: reporterId ?? this.reporterId,
      contentId: contentId ?? this.contentId,
      comment: comment ?? this.comment,
      type: type ?? this.type,
    );
  }
}
