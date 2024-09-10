class AppFeedback {
  final String? uid;
  final String userId;
  final DateTime dateProvided;
  final int surveyNumber;
  final String feedback1;
  final String feedback2;
  final String version;
  final String platform;

  AppFeedback({
    this.uid,
    required this.userId,
    required this.dateProvided,
    required this.surveyNumber,
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
      'surveyNumber': surveyNumber,
      'feedback1': feedback1,
      'feedback2': feedback2,
      'version': version,
      'platform': platform,
    };
  }

  AppFeedback copyWith({
    String? uid,
    String? userId,
    DateTime? dateProvided,
    int? surveyNumber,
    String? feedback1,
    String? feedback2,
    String? version,
    String? platform,
  }) {
    return AppFeedback(
      uid: uid ?? this.uid,
      userId: userId ?? this.userId,
      dateProvided: dateProvided ?? this.dateProvided,
      surveyNumber: surveyNumber ?? this.surveyNumber,
      feedback1: feedback1 ?? this.feedback1,
      feedback2: feedback2 ?? this.feedback2,
      version: version ?? this.version,
      platform: platform ?? this.platform,
    );
  }
}
