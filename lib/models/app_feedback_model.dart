class AppFeedback {
  final String? uid;
  final String userId;
  final DateTime dateProvided;
  final DateTime surveyDate;
  final String feedback1;
  final String feedback2;
  final String version;
  final String platform;

  AppFeedback({
    this.uid,
    required this.userId,
    required this.dateProvided,
    required this.surveyDate,
    required this.feedback1,
    required this.feedback2,
    required this.version,
    required this.platform,
  });

  Map<String, dynamic> toJSON() {
    return {
      'uid': uid,
      'userId': userId,
      'dateProvided': dateProvided,
      'surveyDate': surveyDate,
      'feedback1': feedback1,
      'feedback2': feedback2,
      'version': version,
      'platform': platform,
    };
  }

  factory AppFeedback.fromJSON(Map<String, dynamic> json) {
    return AppFeedback(
      uid: json['uid'],
      userId: json['userId'],
      dateProvided: json['dateProvided'],
      surveyDate: json['surveyDate'],
      feedback1: json['feedback1'],
      feedback2: json['feedback2'],
      version: json['version'],
      platform: json['platform'],
    );
  }

  AppFeedback copyWith({
    String? uid,
    String? userId,
    DateTime? dateProvided,
    DateTime? surveyDate,
    String? feedback1,
    String? feedback2,
    String? version,
    String? platform,
  }) {
    return AppFeedback(
      uid: uid ?? this.uid,
      userId: userId ?? this.userId,
      dateProvided: dateProvided ?? this.dateProvided,
      surveyDate: surveyDate ?? this.surveyDate,
      feedback1: feedback1 ?? this.feedback1,
      feedback2: feedback2 ?? this.feedback2,
      version: version ?? this.version,
      platform: platform ?? this.platform,
    );
  }
}
