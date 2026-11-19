import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:two_eight_two/models/models.dart';

class StravaFunctionsRepository {
  final SupabaseClient _db;

  StravaFunctionsRepository(this._db);

  Future<Uri> oauthStartUrl() async {
    final response = await _db.functions.invoke('strava-oauth-start');
    return Uri.parse((response.data as Map<String, dynamic>)['url'] as String);
  }

  Future<StravaScanResult> scanActivities() async {
    final response = await _db.functions.invoke('strava-scan-activities');
    return StravaScanResult.fromJSON(response.data as Map<String, dynamic>);
  }

  Future<StravaDataDeletion> disconnectAndDelete() async {
    final response = await _db.functions.invoke('strava-disconnect');
    return StravaDataDeletion.fromJSON(response.data as Map<String, dynamic>);
  }
}
