class StravaActivity {
  final int id;
  final String? userId;
  final String activityType;
  final String name;
  final DateTime startDate;
  final double? durationS;
  final double? distanceM;
  final double? elevationGainM;
  final String? deviceName;
  final DateTime? expiresAt;
  final DateTime? createdAt;

  const StravaActivity({
    required this.id,
    this.userId,
    required this.activityType,
    required this.name,
    required this.startDate,
    this.durationS,
    this.distanceM,
    this.elevationGainM,
    this.deviceName,
    this.expiresAt,
    this.createdAt,
  });

  Uri get stravaUrl => Uri.https('www.strava.com', '/activities/$id');

  bool get isGarminRecorded => deviceName?.toLowerCase().contains('garmin') ?? false;

  static double? _toDouble(dynamic value) => value != null ? (value as num).toDouble() : null;

  static DateTime? _toDateTime(dynamic value) => value != null ? DateTime.parse(value as String) : null;

  static StravaActivity fromJSON(Map<String, dynamic> json) {
    return StravaActivity(
      id: json[StravaActivityFields.id] as int,
      userId: json[StravaActivityFields.userId] as String?,
      activityType: json[StravaActivityFields.activityType] as String,
      name: json[StravaActivityFields.name] as String,
      startDate: DateTime.parse(json[StravaActivityFields.startDate] as String),
      durationS: _toDouble(json[StravaActivityFields.durationS]),
      distanceM: _toDouble(json[StravaActivityFields.distanceM]),
      elevationGainM: _toDouble(json[StravaActivityFields.elevationGainM]),
      deviceName: json[StravaActivityFields.deviceName] as String?,
      expiresAt: _toDateTime(json[StravaActivityFields.expiresAt]),
      createdAt: _toDateTime(json[StravaActivityFields.createdAt]),
    );
  }

  StravaActivity copy({
    int? id,
    String? userId,
    String? activityType,
    String? name,
    DateTime? startDate,
    double? durationS,
    double? distanceM,
    double? elevationGainM,
    String? deviceName,
    DateTime? expiresAt,
    DateTime? createdAt,
  }) {
    return StravaActivity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      activityType: activityType ?? this.activityType,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      durationS: durationS ?? this.durationS,
      distanceM: distanceM ?? this.distanceM,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      deviceName: deviceName ?? this.deviceName,
      expiresAt: expiresAt ?? this.expiresAt,
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
  static String distanceM = "distance_m";
  static String elevationGainM = "elevation_gain_m";
  static String deviceName = "device_name";
  static String expiresAt = "expires_at";
  static String createdAt = "created_at";
  static String durationS = "duration_s";
}
