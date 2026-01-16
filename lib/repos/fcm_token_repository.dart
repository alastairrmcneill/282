import 'package:supabase_flutter/supabase_flutter.dart';

class FcmTokenFields {
  static const String id = 'id';
  static const String userId = 'user_id';
  static const String deviceId = 'device_id';
  static const String token = 'token';
  static const String platform = 'platform';
  static const String pushEnabled = 'push_enabled';
  static const String isActive = 'is_active';
  static const String appVersion = 'app_version';
  static const String osVersion = 'os_version';
  static const String deviceModel = 'device_model';
  static const String lastUsedAt = 'last_used_at';
  static const String lastError = 'last_error';
  static const String createdAt = 'created_at';
  static const String updatedAt = 'updated_at';
}

class FcmTokenRepository {
  final SupabaseClient _db;

  FcmTokenRepository(this._db);

  SupabaseQueryBuilder get _table => _db.from('user_fcm_tokens');

  Future<void> upsertToken({
    required String userId,
    required String deviceId,
    required String token,
    required String platform,
    String? appVersion,
    String? osVersion,
    String? deviceModel,
  }) async {
    await _table.delete().eq(FcmTokenFields.token, token).eq(FcmTokenFields.userId, userId);

    await _table.upsert(
      {
        FcmTokenFields.userId: userId,
        FcmTokenFields.deviceId: deviceId,
        FcmTokenFields.token: token,
        FcmTokenFields.platform: platform,
        FcmTokenFields.appVersion: appVersion,
        FcmTokenFields.osVersion: osVersion,
        FcmTokenFields.deviceModel: deviceModel,
        FcmTokenFields.isActive: true,
        FcmTokenFields.lastUsedAt: DateTime.now().toIso8601String(),
      },
      onConflict: '${FcmTokenFields.userId},${FcmTokenFields.deviceId}',
    );
  }

  Future<void> setTokenPushEnabled({
    required String userId,
    required String deviceId,
    required bool enabled,
  }) async {
    await _table
        .update({FcmTokenFields.pushEnabled: enabled})
        .eq(FcmTokenFields.userId, userId)
        .eq(FcmTokenFields.deviceId, deviceId);
  }

  Future<void> deactivateToken({
    required String userId,
    required String deviceId,
  }) async {
    await _table
        .update({FcmTokenFields.isActive: false})
        .eq(FcmTokenFields.userId, userId)
        .eq(FcmTokenFields.deviceId, deviceId);
  }

  Future<void> activateToken({
    required String userId,
    required String deviceId,
  }) async {
    await _table
        .update({FcmTokenFields.isActive: true})
        .eq(FcmTokenFields.userId, userId)
        .eq(FcmTokenFields.deviceId, deviceId);
  }

  Future<void> deleteToken({
    required String userId,
    required String deviceId,
  }) async {
    await _table.delete().eq(FcmTokenFields.userId, userId).eq(FcmTokenFields.deviceId, deviceId);
  }

  Future<void> deleteTokenByValue(String token) async {
    await _table.delete().eq(FcmTokenFields.token, token);
  }

  Future<List<Map<String, dynamic>>> getMyDevices(String userId) async {
    final response =
        await _table.select().eq(FcmTokenFields.userId, userId).order(FcmTokenFields.lastUsedAt, ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> updateLastUsedAt({
    required String userId,
    required String deviceId,
  }) async {
    await _table
        .update({FcmTokenFields.lastUsedAt: DateTime.now().toIso8601String()})
        .eq(FcmTokenFields.userId, userId)
        .eq(FcmTokenFields.deviceId, deviceId);
  }
}
