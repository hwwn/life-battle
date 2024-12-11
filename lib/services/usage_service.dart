import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:life_battle/models/app_usage.dart';
import 'package:flutter/services.dart';

class AppCategory {
  final String name;
  final Duration usage;

  AppCategory({required this.name, required this.usage});
}

class UsageService {
  static const String _storageKey = 'app_usage_data';
  static const platform = MethodChannel('app/screen_time');

  Future<Map<String, dynamic>> getAppUsage() async {
    try {
      final Map result = await platform.invokeMethod('getScreenTime');

      // 处理应用使用时间
      final Map<String, Duration> appUsage = (result['apps']
              as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, Duration(minutes: value as int)));

      // 处理类别使用时间
      final List<AppCategory> categoryUsage = (result['categories'] as List)
          .map((item) => AppCategory(
                name: item['category'] as String,
                usage: Duration(minutes: item['minutes'] as int),
              ))
          .toList();

      return {
        'appUsage': appUsage,
        'categoryUsage': categoryUsage,
      };
    } catch (e) {
      print('Error loading data: $e');
      return {};
    }
  }

  Future<void> saveUsageData(List<AppUsageInfo> usageData) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonData = jsonEncode(
      usageData.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_storageKey, jsonData);
  }

  Future<List<AppUsageInfo>> loadUsageData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonData = prefs.getString(_storageKey);
    if (jsonData == null) return [];

    final List<dynamic> decoded = jsonDecode(jsonData);
    return decoded.map((e) => AppUsageInfo.fromJson(e)).toList();
  }
}
