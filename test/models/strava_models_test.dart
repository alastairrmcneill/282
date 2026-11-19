import 'package:flutter_test/flutter_test.dart';
import 'package:two_eight_two/models/models.dart';

void main() {
  group('StravaActivity', () {
    test('fromJSON parses the cached activity row', () {
      final activity = StravaActivity.fromJSON({
        'id': 123,
        'user_id': 'user1',
        'activity_type': 'Hike',
        'name': 'Ben Nevis',
        'start_date': '2026-06-01T08:30:00Z',
        'duration_s': 3600,
        'distance_m': 16000.5,
        'elevation_gain_m': 1350,
        'device_name': 'Garmin Forerunner 965',
        'expires_at': '2026-06-08T08:30:00Z',
      });

      expect(activity.id, 123);
      expect(activity.distanceM, 16000.5);
      expect(activity.isGarminRecorded, true);
      expect(activity.stravaUrl.toString(), 'https://www.strava.com/activities/123');
      expect(activity.expiresAt, DateTime.utc(2026, 6, 8, 8, 30));
    });

    test('isGarminRecorded is false without a Garmin device', () {
      final activity = StravaActivity(id: 1, activityType: 'Walk', name: 'x', startDate: DateTime(2026));
      expect(activity.isGarminRecorded, false);
      expect(activity.copy(deviceName: 'Strava App').isGarminRecorded, false);
    });
  });

  group('StravaScanResult', () {
    test('fromJSON parses the scan response', () {
      final result = StravaScanResult.fromJSON({
        'activities_scanned': 250,
        'complete': false,
        'matches': [
          {
            'munro_id': 7,
            'activity': {
              'id': 9,
              'activity_type': 'Hike',
              'name': 'Cairn Gorm',
              'start_date': '2025-05-01T09:00:00Z',
              'duration_s': 10000,
              'distance_m': 12000,
              'elevation_gain_m': 900,
            },
          },
        ],
      });

      expect(result.activitiesScanned, 250);
      expect(result.complete, false);
      expect(result.matches.single.munroId, 7);
      expect(result.matches.single.activity.userId, isNull);
    });
  });

  group('StravaDataDeletion', () {
    test('fromJSON accepts both the table row and the disconnect response', () {
      final fromRow = StravaDataDeletion.fromJSON({
        'id': 'abc',
        'completed_at': '2026-11-19T10:00:00Z',
        'activities_deleted': 2,
        'matches_deleted': 3,
      });
      final fromResponse = StravaDataDeletion.fromJSON({
        'deletion_id': 'def',
        'completed_at': '2026-11-19T10:00:00Z',
        'activities_deleted': 0,
        'matches_deleted': 0,
        'strava_access_revoked': true,
      });

      expect(fromRow.id, 'abc');
      expect(fromRow.matchesDeleted, 3);
      expect(fromResponse.id, 'def');
    });
  });

  group('StravaConnection', () {
    test('fromJSON does not need token columns', () {
      final connection = StravaConnection.fromJSON({
        'user_id': 'user1',
        'strava_athlete_id': 555,
        'scope': 'read,activity:read',
        'connected_at': '2026-11-01T10:00:00Z',
        'revoked_at': null,
        'last_historical_scan_at': null,
      });

      expect(connection.stravaProfileUrl.toString(), 'https://www.strava.com/athletes/555');
      expect(connection.lastHistoricalScanAt, isNull);
    });
  });
}
