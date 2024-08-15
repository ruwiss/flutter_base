// [package_info_plus]

import 'package:package_info_plus/package_info_plus.dart';

final class PackageInfoUtils {
  static final PackageInfoUtils _instance = PackageInfoUtils._();

  factory PackageInfoUtils() {
    return _instance;
  }

  PackageInfoUtils._();

  late final PackageInfo _packageInfo;

  Future<void> init() async {
    _packageInfo = await PackageInfo.fromPlatform();
  }

  String getAppVersion() {
    return _packageInfo.version;
  }

  String getAppName() {
    return _packageInfo.appName;
  }
}
