class StravaMatchingConfig {
  final int id;
  final List<String> candidateTypes;
  final double radiusM;
  final double elevHighThresholdM;
  final double boxMinLat;
  final double boxMaxLat;
  final double boxMinLng;
  final double boxMaxLng;

  StravaMatchingConfig({
    required this.id,
    required this.candidateTypes,
    required this.radiusM,
    required this.elevHighThresholdM,
    required this.boxMinLat,
    required this.boxMaxLat,
    required this.boxMinLng,
    required this.boxMaxLng,
  });

  factory StravaMatchingConfig.fromJson(Map<String, dynamic> json) {
    final boundingBox = json['bounding_box'] as Map<String, dynamic>;
    return StravaMatchingConfig(
      id: json['id'] as int,
      candidateTypes: List<String>.from(json['candidate_types'] as List),
      radiusM: (json['radius_m'] as num).toDouble(),
      elevHighThresholdM: (json['elev_high_threshold_m'] as num).toDouble(),
      boxMinLat: (boundingBox['sw_lat'] as num).toDouble(),
      boxMaxLat: (boundingBox['ne_lat'] as num).toDouble(),
      boxMinLng: (boundingBox['sw_lng'] as num).toDouble(),
      boxMaxLng: (boundingBox['ne_lng'] as num).toDouble(),
    );
  }
}

class StravaMatchingConfigFields {
  static const String id = 'id';
  static const String candidateTypes = 'candidate_types';
  static const String radiusM = 'radius_m';
  static const String elevHighThresholdM = 'elev_high_threshold_m';
  static const String boxMinLat = 'box_min_lat';
  static const String boxMaxLat = 'box_max_lat';
  static const String boxMinLng = 'box_min_lng';
  static const String boxMaxLng = 'box_max_lng';
}
