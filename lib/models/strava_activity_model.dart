class StravaActivity {
  final int id;
  final String userId;
  final String activityType;
  final String name;
  final DateTime startDate;
  final double? durationS;
  final double? startLat;
  final double? startLng;
  final double? endLat;
  final double? endLng;
  final double? distanceM;
  final double? elevationGainM;
  final double? elevHighM;
  final String? polyline;
  final DateTime? createdAt;

  const StravaActivity({
    required this.id,
    required this.userId,
    required this.activityType,
    required this.name,
    required this.startDate,
    this.durationS,
    this.startLat,
    this.startLng,
    this.endLat,
    this.endLng,
    this.distanceM,
    this.elevationGainM,
    this.elevHighM,
    this.polyline,
    this.createdAt,
  });

  static StravaActivity fromJSON(Map<String, dynamic> json) {
    return StravaActivity(
      id: json[StravaActivityFields.id] as int,
      userId: json[StravaActivityFields.userId] as String,
      activityType: json[StravaActivityFields.activityType] as String,
      name: json[StravaActivityFields.name] as String,
      startDate: DateTime.parse(json[StravaActivityFields.startDate] as String),
      durationS: json[StravaActivityFields.durationS] != null
          ? (json[StravaActivityFields.durationS] as num).toDouble()
          : null,
      startLat:
          json[StravaActivityFields.startLat] != null ? (json[StravaActivityFields.startLat] as num).toDouble() : null,
      startLng:
          json[StravaActivityFields.startLng] != null ? (json[StravaActivityFields.startLng] as num).toDouble() : null,
      endLat: json[StravaActivityFields.endLat] != null ? (json[StravaActivityFields.endLat] as num).toDouble() : null,
      endLng: json[StravaActivityFields.endLng] != null ? (json[StravaActivityFields.endLng] as num).toDouble() : null,
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
      createdAt: json[StravaActivityFields.createdAt] != null
          ? DateTime.parse(json[StravaActivityFields.createdAt] as String)
          : null,
    );
  }

  StravaActivity copy({
    int? id,
    String? userId,
    String? activityType,
    String? name,
    DateTime? startDate,
    double? durationS,
    double? startLat,
    double? startLng,
    double? endLat,
    double? endLng,
    double? distanceM,
    double? elevationGainM,
    double? elevHighM,
    String? polyline,
    DateTime? createdAt,
  }) {
    return StravaActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      durationS: durationS ?? this.durationS,
      startLat: startLat ?? this.startLat,
      startLng: startLng ?? this.startLng,
      endLat: endLat ?? this.endLat,
      endLng: endLng ?? this.endLng,
      distanceM: distanceM ?? this.distanceM,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      elevHighM: elevHighM ?? this.elevHighM,
      polyline: polyline ?? this.polyline,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class StravaActivityFields {
  static String id = "id";
  static String userId = "user_id";
  static String activityType = "activity_type";
  static String name = "name";
  static String startDate = "start_date";
  static String startLat = "start_lat";
  static String startLng = "start_lng";
  static String endLat = "end_lat";
  static String endLng = "end_lng";
  static String distanceM = "distance_m";
  static String elevationGainM = "elevation_gain_m";
  static String elevHighM = "elev_high_m";
  static String polyline = "polyline";
  static String createdAt = "created_at";
  static String durationS = "duration_s";
}
