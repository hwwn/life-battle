import 'package:flutter/services.dart';

class ScreenTimeService {
  static const platform = MethodChannel('app/screen_time');

  Future<Map<String, Duration>> getAppUsage() async {
    try {
      final Map result = await platform.invokeMethod('getScreenTime');
      return Map<String, Duration>.from(result);
    } on PlatformException catch (e) {
      print('Failed to get screen time: ${e.message}');
      return {};
    }
  }
}
