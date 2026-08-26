enum StravaActivitySource {
  historicalScan,
  webhook;

  static StravaActivitySource fromString(String value) {
    return switch (value) {
      'webhook' => StravaActivitySource.webhook,
      _ => StravaActivitySource.historicalScan,
    };
  }

  String toJsonString() {
    return switch (this) {
      StravaActivitySource.historicalScan => 'historical_scan',
      StravaActivitySource.webhook => 'webhook',
    };
  }
}

enum StravaActivityMatchStatus {
  pending,
  noMatch,
  matched,
  skippedManual,
  skippedType,
  skippedOutOfRegion;

  static StravaActivityMatchStatus fromString(String value) {
    return switch (value) {
      'no_match' => StravaActivityMatchStatus.noMatch,
      'matched' => StravaActivityMatchStatus.matched,
      'skipped_manual' => StravaActivityMatchStatus.skippedManual,
      'skipped_type' => StravaActivityMatchStatus.skippedType,
      'skipped_out_of_region' => StravaActivityMatchStatus.skippedOutOfRegion,
      _ => StravaActivityMatchStatus.pending,
    };
  }

  String toJsonString() {
    return switch (this) {
      StravaActivityMatchStatus.pending => 'pending',
      StravaActivityMatchStatus.noMatch => 'no_match',
      StravaActivityMatchStatus.matched => 'matched',
      StravaActivityMatchStatus.skippedManual => 'skipped_manual',
      StravaActivityMatchStatus.skippedType => 'skipped_type',
      StravaActivityMatchStatus.skippedOutOfRegion => 'skipped_out_of_region',
    };
  }
}

class StravaActivity {
  final int id;
  final String userId;
  final StravaActivitySource source;
  final String activityType;
  final String name;
  final DateTime startDate;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final double? distanceM;
  final double? elevationGainM;
  final double? elevHighM;
  final String? polyline;
  final StravaActivityMatchStatus matchStatus;
  final DateTime createdAt;

  const StravaActivity({
    required this.id,
    required this.userId,
    required this.source,
    required this.activityType,
    required this.name,
    required this.startDate,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.distanceM,
    this.elevationGainM,
    this.elevHighM,
    this.polyline,
    required this.matchStatus,
    required this.createdAt,
  });

  static MapEntry<double, double>? _parsePoint(dynamic value) {
    // Supabase returns `point` columns as a "(x,y)" string
    if (value == null) return null;
    final match = RegExp(r'\(([^,]+),([^)]+)\)').firstMatch(value as String);
    if (match == null) return null;
    return MapEntry(double.parse(match.group(1)!), double.parse(match.group(2)!));
  }

  static StravaActivity fromJSON(Map<String, dynamic> json) {
    final start = _parsePoint(json[StravaActivityFields.startLatlng]);
    final end = _parsePoint(json[StravaActivityFields.endLatlng]);
    return StravaActivity(
      id: json[StravaActivityFields.id] as int,
      userId: json[StravaActivityFields.userId] as String,
      source: StravaActivitySource.fromString(json[StravaActivityFields.source] as String),
      activityType: json[StravaActivityFields.activityType] as String,
      name: json[StravaActivityFields.name] as String,
      startDate: DateTime.parse(json[StravaActivityFields.startDate] as String),
      startLat: start?.value,
      startLng: start?.key,
      endLat: end?.value,
      endLng: end?.key,
      distanceM: json[StravaActivityFields.distanceM] != null
          ? (json[StravaActivityFields.distanceM] as num).toDouble()
          : null,
      elevationGainM: json[StravaActivityFields.elevationGainM] != null
          ? (json[StravaActivityFields.elevationGainM] as num).toDouble()
          : null,
      elevHighM: json[StravaActivityFields.elevHighM] != null
          ? (json[StravaActivityFields.elevHighM] as num).toDouble()
          : null,
      polyline: json[StravaActivityFields.polyline] as String?,
      matchStatus: StravaActivityMatchStatus.fromString(json[StravaActivityFields.matchStatus] as String),
      createdAt: DateTime.parse(json[StravaActivityFields.createdAt] as String),
    );
  }

  StravaActivity copy({
    int? id,
    String? userId,
    StravaActivitySource? source,
    String? activityType,
    String? name,
    DateTime? startDate,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
    double? distanceM,
    double? elevationGainM,
    double? elevHighM,
    String? polyline,
    StravaActivityMatchStatus? matchStatus,
    DateTime? createdAt,
  }) {
    return StravaActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      source: source ?? this.source,
      activityType: activityType ?? this.activityType,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      distanceM: distanceM ?? this.distanceM,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      elevHighM: elevHighM ?? this.elevHighM,
      polyline: polyline ?? this.polyline,
      matchStatus: matchStatus ?? this.matchStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StravaActivityFields {
  static String id = "id";
  static String userId = "user_id";
  static String source = "source";
  static String activityType = "activity_type";
  static String name = "name";
  static String startDate = "start_date";
  static String startLatlng = "start_latlng";
  static String endLatlng = "end_latlng";
  static String distanceM = "distance_m";
  static String elevationGainM = "elevation_gain_m";
  static String elevHighM = "elev_high_m";
  static String polyline = "polyline";
  static String matchStatus = "match_status";
  static String createdAt = "created_at";
}
