class StravaConnection {
  final String userId;
  final int stravaAthleteId;
  final String scope;
  final DateTime connectedAt;
  final DateTime? revokedAt;
  final DateTime? lastHistoricalScanAt;

  const StravaConnection({
    required this.userId,
    required this.stravaAthleteId,
    required this.scope,
    required this.connectedAt,
    this.revokedAt,
    this.lastHistoricalScanAt,
  });

  Uri get stravaProfileUrl => Uri.https('www.strava.com', '/athletes/$stravaAthleteId');

  factory StravaConnection.fromJSON(Map<String, dynamic> json) => StravaConnection(
        userId: json[StravaConnectionFields.userId] as String,
        stravaAthleteId: json[StravaConnectionFields.stravaAthleteId] as int,
        scope: json[StravaConnectionFields.scope] as String,
        connectedAt: DateTime.parse(json[StravaConnectionFields.connectedAt] as String),
        revokedAt: json[StravaConnectionFields.revokedAt] != null
            ? DateTime.parse(json[StravaConnectionFields.revokedAt] as String)
            : null,
        lastHistoricalScanAt: json[StravaConnectionFields.lastHistoricalScanAt] != null
            ? DateTime.parse(json[StravaConnectionFields.lastHistoricalScanAt] as String)
            : null,
      );

  StravaConnection copyWith({
    String? userId,
    int? stravaAthleteId,
    String? scope,
    DateTime? connectedAt,
    DateTime? revokedAt,
    DateTime? lastHistoricalScanAt,
  }) {
    return StravaConnection(
      userId: userId ?? this.userId,
      stravaAthleteId: stravaAthleteId ?? this.stravaAthleteId,
      scope: scope ?? this.scope,
      connectedAt: connectedAt ?? this.connectedAt,
      revokedAt: revokedAt ?? this.revokedAt,
      lastHistoricalScanAt: lastHistoricalScanAt ?? this.lastHistoricalScanAt,
    );
  }
}

class StravaConnectionFields {
  static const String userId = 'user_id';
  static const String stravaAthleteId = 'strava_athlete_id';
  static const String scope = 'scope';
  static const String connectedAt = 'connected_at';
  static const String revokedAt = 'revoked_at';
  static const String lastHistoricalScanAt = 'last_historical_scan_at';

  // Tokens are not readable by clients, so only these columns are ever selected.
  static const String selectable = '$userId, $stravaAthleteId, $scope, $connectedAt, $revokedAt, $lastHistoricalScanAt';
}
