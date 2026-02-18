import 'package:package_info_plus/package_info_plus.dart';

class AppInfoRepository {
  final PackageInfo _packageInfo;
  AppInfoRepository(this._packageInfo);

  String get version => _packageInfo.version;
  int get buildNumber => int.parse(_packageInfo.buildNumber);
}
