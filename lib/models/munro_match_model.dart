enum MunroMatchStatus {
  pending,
  confirmed,
  rejected;

  static MunroMatchStatus fromString(String value) {
    return switch (value) {
      'confirmed' => MunroMatchStatus.confirmed,
      'rejected' => MunroMatchStatus.rejected,
      _ => MunroMatchStatus.pending,
    };
  }

  String toJsonString() {
    return switch (this) {
      MunroMatchStatus.confirmed => 'confirmed',
      MunroMatchStatus.rejected => 'rejected',
      MunroMatchStatus.pending => 'pending',
    };
  }
}

class MunroMatch {
  final String id;
  final String userId;
  final int munroId;
  final int stravaActivityId;
  final double? matchDistanceM;
  final MunroMatchStatus status;
  final DateTime detectedAt;
  final DateTime? reviewedAt;

  const MunroMatch({
    required this.id,
    required this.userId,
    required this.munroId,
    required this.stravaActivityId,
    this.matchDistanceM,
    required this.status,
    required this.detectedAt,
    this.reviewedAt,
  });

  static MunroMatch fromJSON(Map<String, dynamic> json) {
    return MunroMatch(
      id: json[MunroMatchFields.id] as String,
      userId: json[MunroMatchFields.userId] as String,
      munroId: json[MunroMatchFields.munroId] as int,
      stravaActivityId: json[MunroMatchFields.stravaActivityId] as int,
      matchDistanceM: json[MunroMatchFields.matchDistanceM] != null
          ? (json[MunroMatchFields.matchDistanceM] as num).toDouble()
          : null,
      status: MunroMatchStatus.fromString(json[MunroMatchFields.status] as String),
      detectedAt: DateTime.parse(json[MunroMatchFields.detectedAt] as String),
      reviewedAt: json[MunroMatchFields.reviewedAt] != null
          ? DateTime.parse(json[MunroMatchFields.reviewedAt] as String)
          : null,
    );
  }

  MunroMatch copy({
    String? id,
    String? userId,
    int? munroId,
    int? stravaActivityId,
    double? matchDistanceM,
    MunroMatchStatus? status,
    DateTime? detectedAt,
    DateTime? reviewedAt,
  }) {
    return MunroMatch(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      munroId: munroId ?? this.munroId,
      stravaActivityId: stravaActivityId ?? this.stravaActivityId,
      matchDistanceM: matchDistanceM ?? this.matchDistanceM,
      status: status ?? this.status,
      detectedAt: detectedAt ?? this.detectedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
    );
  }
}

class MunroMatchFields {
  static String id = "id";
  static String userId = "user_id";
  static String munroId = "munro_id";
  static String stravaActivityId = "strava_activity_id";
  static String matchDistanceM = "match_distance_m";
  static String status = "status";
  static String detectedAt = "detected_at";
  static String reviewedAt = "reviewed_at";
}
