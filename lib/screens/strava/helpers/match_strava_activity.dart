import 'dart:math';

import 'package:two_eight_two/models/models.dart';

class StravaMunroMatch {
  final Munro munro;
  final StravaActivity stravaActivity;

  const StravaMunroMatch({
    required this.munro,
    required this.stravaActivity,
  });
}

List<StravaMunroMatch> matchStravaActivity({
  required StravaActivity activity,
  required List<Munro> munros,
  required StravaMatchingConfig config,
}) {
  if (!config.candidateTypes.contains(activity.activityType)) return [];
  if (!(_inBox(activity.startLat, activity.startLng, config) || _inBox(activity.endLat, activity.endLng, config))) {
    return [];
  }
  if ((activity.elevHighM ?? 0) < config.elevHighThresholdM) return [];

  final polyline = activity.polyline;
  if (polyline == null || polyline.isEmpty) return [];

  final points = _decodePolyline(polyline);
  final radiusM = config.radiusM;
  final matches = <StravaMunroMatch>[];
  for (final munro in munros) {
    var closest = double.infinity;
    for (final point in points) {
      final d = _haversineM(point.$1, point.$2, munro.lat, munro.lng);
      if (d < closest) closest = d;
      if (closest < radiusM) break;
    }
    if (closest < radiusM) {
      matches.add(StravaMunroMatch(munro: munro, stravaActivity: activity));
    }
  }
  return matches;
}

bool _inBox(double? lat, double? lng, StravaMatchingConfig config) {
  if (lat == null || lng == null) return false;
  return lat >= config.boxMinLat && lat <= config.boxMaxLat && lng >= config.boxMinLng && lng <= config.boxMaxLng;
}

List<(double, double)> _decodePolyline(String encoded) {
  var index = 0, lat = 0, lng = 0;
  final coords = <(double, double)>[];
  while (index < encoded.length) {
    var shift = 0, result = 0;
    int byte;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    shift = 0;
    result = 0;
    do {
      byte = encoded.codeUnitAt(index++) - 63;
      result |= (byte & 0x1f) << shift;
      shift += 5;
    } while (byte >= 0x20);
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    coords.add((lat / 1e5, lng / 1e5));
  }
  return coords;
}

double _haversineM(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371000.0;
  double toRad(double d) => d * pi / 180;
  final dLat = toRad(lat2 - lat1);
  final dLng = toRad(lng2 - lng1);
  final sinDLat = sin(dLat / 2);
  final sinDLng = sin(dLng / 2);
  final a = sinDLat * sinDLat + cos(toRad(lat1)) * cos(toRad(lat2)) * sinDLng * sinDLng;
  return r * 2 * atan2(sqrt(a), sqrt(1 - a));
}
