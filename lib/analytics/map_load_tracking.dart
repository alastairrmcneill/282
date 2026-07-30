import 'package:flutter/widgets.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'analytics_base.dart';

const _cooldown = Duration(minutes: 1);
final Map<String, DateTime> _lastReported = {};

void trackMapLoadFailure(
  BuildContext context,
  String surface,
  MapLoadingErrorEventData data,
) {
  final key = '$surface:${data.type.name}';
  final now = DateTime.now();
  final last = _lastReported[key];
  if (last != null && now.difference(last) < _cooldown) return;
  _lastReported[key] = now;

  context.read<Analytics>().track(
    AnalyticsEvent.mapLoadFailed,
    props: {
      AnalyticsProp.surface: surface,
      AnalyticsProp.reason: data.type.name,
      if (data.sourceId != null) AnalyticsProp.source: data.sourceId,
    },
  );
}
