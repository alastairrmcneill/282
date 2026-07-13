import 'package:flutter/services.dart';

class AgeGateRepository {
  static const MethodChannel _channel = MethodChannel('com.alastairrmcneill.TwoEightTwo/age_range');

  Future<int?> requestDeclaredAgeRange() async {
    try {
      final result = await _channel.invokeMethod<int>('requestAgeRange');
      return result;
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }
}
