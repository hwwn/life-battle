import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class AppCategory {
  final String name;
  final Duration usage;

  AppCategory({required this.name, required this.usage});

  // 将 AppCategory 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'usage': usage.inMinutes,
    };
  }

  // 从 JSON 创建 AppCategory
  factory AppCategory.fromJson(Map<String, dynamic> json) {
    return AppCategory(
      name: json['name'] as String,
      usage: Duration(minutes: json['usage'] as int),
    );
  }
}

class UsageService {
  static const platform = MethodChannel('app/screen_time');
  static const String _storageKey = 'app_usage_data';

  Future<Map<String, dynamic>> getAppUsage() async {
    try {
      final Map result = await platform.invokeMethod('getScreenTime');
      print('从原生端收到数据: $result');

      // 处理应用使用时间
      final Map<String, Duration> appUsage = (result['apps'] as Map).map(
        (key, value) => MapEntry(
          key.toString(),
          Duration(minutes: (value as int)),
        ),
      );

      // 处理类别使用时间
      final List<AppCategory> categoryUsage =
          ((result['categories'] as List).map((item) {
        final map = item as Map;
        return AppCategory(
          name: map['category'].toString(),
          usage: Duration(minutes: (map['minutes'] as int)),
        );
      })).toList();

      print('处理后的数据:');
      print('应用使用时间: $appUsage');
      print('类别使用时间: $categoryUsage');

      return {
        'appUsage': appUsage,
        'categoryUsage': categoryUsage,
      };
    } catch (e, stackTrace) {
      print('Error loading data: $e');
      print('Stack trace: $stackTrace');
      return {
        'appUsage': <String, Duration>{},
        'categoryUsage': <AppCategory>[],
      };
    }
  }

  // 保存数据到本地存储
  Future<void> _saveUsageData(
    Map<String, Duration> appUsage,
    List<AppCategory> categoryUsage,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'appUsage': appUsage.map(
        (key, value) => MapEntry(key, value.inMinutes),
      ),
      'categoryUsage': categoryUsage.map((c) => c.toJson()).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    };
    await prefs.setString(_storageKey, jsonEncode(data));
  }

  // 从本地存储加载最后保存的数据
  Future<Map<String, dynamic>> _loadLastSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonData = prefs.getString(_storageKey);

      if (jsonData == null) {
        return {
          'appUsage': <String, Duration>{},
          'categoryUsage': <AppCategory>[],
        };
      }

      final data = jsonDecode(jsonData) as Map<String, dynamic>;

      // 转换应用使用时间
      final Map<String, Duration> appUsage =
          (data['appUsage'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, Duration(minutes: value as int)),
      );

      // 转换类别使用时间
      final List<AppCategory> categoryUsage = (data['categoryUsage'] as List)
          .map(
            (item) => AppCategory.fromJson(item as Map<String, dynamic>),
          )
          .toList();

      return {
        'appUsage': appUsage,
        'categoryUsage': categoryUsage,
      };
    } catch (e) {
      print('Error loading saved data: $e');
      return {
        'appUsage': <String, Duration>{},
        'categoryUsage': <AppCategory>[],
      };
    }
  }
}
