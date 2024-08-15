// [package_info_plus]

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import 'dart:io';

final class DeviceInfoUtils {
  static final DeviceInfoUtils _instance = DeviceInfoUtils._();

  factory DeviceInfoUtils() {
    return _instance;
  }

  DeviceInfoUtils._();

  late final DeviceInfoPlugin _deviceInfo;

  Future<void> init() async {
    _deviceInfo = DeviceInfoPlugin();
  }

  Future<String?> getDeviceId() async {
    if (Platform.isIOS) {
      final iosDeviceInfo = await _deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor;
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await _deviceInfo.androidInfo;
      return androidDeviceInfo.id;
    } else if (kIsWeb) {
      return const Uuid().v4();
    } else {
      return null;
    }
  }

  Future<String?> getDeviceInfo() async {
    if (Platform.isIOS) {
      final iosDeviceInfo = await _deviceInfo.iosInfo;
      return iosDeviceInfo.utsname.machine;
    } else if (Platform.isAndroid) {
      final androidDeviceInfo = await _deviceInfo.androidInfo;
      return androidDeviceInfo.model;
    } else if (kIsWeb) {
      final webBrowserInfo = await _deviceInfo.webBrowserInfo;
      return webBrowserInfo.platform;
    } else {
      return null;
    }
  }

  /// "ANDROID", "IOS", "WEB", "UNKNOWN"
  String getPlatformName() {
    if (Platform.isIOS) {
      return 'IOS';
    } else if (Platform.isAndroid) {
      return 'ANDROID';
    } else if (kIsWeb) {
      return 'WEB';
    } else {
      return 'UNKNOWN';
    }
  }
}
