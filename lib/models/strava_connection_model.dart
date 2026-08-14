enum HistoricalScanStatus {
  pending,
  inProgress,
  completed,
  failed;

  static HistoricalScanStatus fromString(String value) {
    return switch (value) {
      'in_progress' => HistoricalScanStatus.inProgress,
      'completed' => HistoricalScanStatus.completed,
      'failed' => HistoricalScanStatus.failed,
      _ => HistoricalScanStatus.pending,
    };
  }

  String toJsonString() {
    return switch (this) {
      HistoricalScanStatus.inProgress => 'in_progress',
      HistoricalScanStatus.completed => 'completed',
      HistoricalScanStatus.failed => 'failed',
      HistoricalScanStatus.pending => 'pending',
    };
  }
}

class HistoricalScanProgress {
  final int activitiesScanned;
  final int munrosFound;
  final int? pageCursor;

  const HistoricalScanProgress({
    required this.activitiesScanned,
    required this.munrosFound,
    this.pageCursor,
  });

  factory HistoricalScanProgress.fromJSON(Map<String, dynamic> json) => HistoricalScanProgress(
        activitiesScanned: json['activities_scanned'] as int? ?? 0,
        munrosFound: json['munros_found'] as int? ?? 0,
        pageCursor: json['page_cursor'] as int?,
      );

  Map<String, dynamic> toJSON() => {
        'activities_scanned': activitiesScanned,
        'munros_found': munrosFound,
        'page_cursor': pageCursor,
      };
}

class StravaConnection {
  final String userId;
  final int stravaAthleteId;
  final String accessToken;
  final String refreshToken;
  final DateTime tokenExpiresAt;
  final String scope;
  final DateTime connectedAt;
  final DateTime? revokedAt;
  final HistoricalScanStatus historicalScanStatus;
  final HistoricalScanProgress? historicalScanProgress;
  final DateTime? historicalScanCompletedAt;

  const StravaConnection({
    required this.userId,
    required this.stravaAthleteId,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiresAt,
    required this.scope,
    required this.connectedAt,
    this.revokedAt,
    required this.historicalScanStatus,
    this.historicalScanProgress,
    this.historicalScanCompletedAt,
  });

  factory StravaConnection.fromJSON(Map<String, dynamic> json) => StravaConnection(
        userId: json[StravaConnectionFields.userId] as String,
        stravaAthleteId: json[StravaConnectionFields.stravaAthleteId] as int,
        accessToken: json[StravaConnectionFields.accessToken] as String,
        refreshToken: json[StravaConnectionFields.refreshToken] as String,
        tokenExpiresAt: DateTime.parse(json[StravaConnectionFields.tokenExpiresAt] as String),
        scope: json[StravaConnectionFields.scope] as String,
        connectedAt: DateTime.parse(json[StravaConnectionFields.connectedAt] as String),
        revokedAt: json[StravaConnectionFields.revokedAt] != null
            ? DateTime.parse(json[StravaConnectionFields.revokedAt] as String)
            : null,
        historicalScanStatus: HistoricalScanStatus.fromString(
          json[StravaConnectionFields.historicalScanStatus] as String? ?? 'pending',
        ),
        historicalScanProgress: json[StravaConnectionFields.historicalScanProgress] != null
            ? HistoricalScanProgress.fromJSON(
                json[StravaConnectionFields.historicalScanProgress] as Map<String, dynamic>)
            : null,
        historicalScanCompletedAt: json[StravaConnectionFields.historicalScanCompletedAt] != null
            ? DateTime.parse(json[StravaConnectionFields.historicalScanCompletedAt] as String)
            : null,
      );

  Map<String, dynamic> toJSON() => {
        StravaConnectionFields.userId: userId,
        StravaConnectionFields.stravaAthleteId: stravaAthleteId,
        StravaConnectionFields.accessToken: accessToken,
        StravaConnectionFields.refreshToken: refreshToken,
        StravaConnectionFields.tokenExpiresAt: tokenExpiresAt.toIso8601String(),
        StravaConnectionFields.scope: scope,
        StravaConnectionFields.connectedAt: connectedAt.toIso8601String(),
        StravaConnectionFields.revokedAt: revokedAt?.toIso8601String(),
        StravaConnectionFields.historicalScanStatus: historicalScanStatus.toJsonString(),
        StravaConnectionFields.historicalScanProgress: historicalScanProgress?.toJSON(),
        StravaConnectionFields.historicalScanCompletedAt: historicalScanCompletedAt?.toIso8601String(),
      };

  StravaConnection copyWith({
    String? userId,
    int? stravaAthleteId,
    String? accessToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
    String? scope,
    DateTime? connectedAt,
    DateTime? revokedAt,
    HistoricalScanStatus? historicalScanStatus,
    HistoricalScanProgress? historicalScanProgress,
    DateTime? historicalScanCompletedAt,
  }) {
    return StravaConnection(
      userId: userId ?? this.userId,
      stravaAthleteId: stravaAthleteId ?? this.stravaAthleteId,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      tokenExpiresAt: tokenExpiresAt ?? this.tokenExpiresAt,
      scope: scope ?? this.scope,
      connectedAt: connectedAt ?? this.connectedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      historicalScanStatus: historicalScanStatus ?? this.historicalScanStatus,
      historicalScanProgress: historicalScanProgress ?? this.historicalScanProgress,
      historicalScanCompletedAt: historicalScanCompletedAt ?? this.historicalScanCompletedAt,
    );
  }
}

class StravaConnectionFields {
  static const String userId = 'user_id';
  static const String stravaAthleteId = 'strava_athlete_id';
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String tokenExpiresAt = 'token_expires_at';
  static const String scope = 'scope';
  static const String connectedAt = 'connected_at';
  static const String revokedAt = 'revoked_at';
  static const String historicalScanStatus = 'historical_scan_status';
  static const String historicalScanProgress = 'historical_scan_progress';
  static const String historicalScanCompletedAt = 'historical_scan_completed_at';
}
