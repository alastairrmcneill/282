class StravaConnection {
  final String userId;
  final int stravaAthleteId;
  final String accessToken;
  final String refreshToken;
  final DateTime tokenExpiresAt;
  final String scope;
  final DateTime connectedAt;
  final DateTime? revokedAt;

  const StravaConnection({
    required this.userId,
    required this.stravaAthleteId,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenExpiresAt,
    required this.scope,
    required this.connectedAt,
    this.revokedAt,
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
}
