import 'package:two_eight_two/models/models.dart';

class StravaScanResult {
  final int activitiesScanned;
  final bool complete;
  final List<StravaScanMatch> matches;

  const StravaScanResult({
    required this.activitiesScanned,
    required this.complete,
    required this.matches,
  });

  static StravaScanResult fromJSON(Map<String, dynamic> json) {
    return StravaScanResult(
      activitiesScanned: json[StravaScanResultFields.activitiesScanned] as int,
      complete: json[StravaScanResultFields.complete] as bool,
      matches: (json[StravaScanResultFields.matches] as List<dynamic>)
          .map((m) => StravaScanMatch.fromJSON(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class StravaScanMatch {
  final int munroId;
  final StravaActivity activity;

  const StravaScanMatch({required this.munroId, required this.activity});

  static StravaScanMatch fromJSON(Map<String, dynamic> json) {
    return StravaScanMatch(
      munroId: json[StravaScanResultFields.munroId] as int,
      activity: StravaActivity.fromJSON(json[StravaScanResultFields.activity] as Map<String, dynamic>),
    );
  }
}

class StravaScanResultFields {
  static const String activitiesScanned = 'activities_scanned';
  static const String complete = 'complete';
  static const String matches = 'matches';
  static const String munroId = 'munro_id';
  static const String activity = 'activity';
}
