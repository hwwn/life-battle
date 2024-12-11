import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';
import 'package:collection/collection.dart';
import '../services/usage_service.dart';
import '../models/app_usage.dart';

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  final UsageService _usageService = UsageService();
  List<AppUsageInfo> _usageData = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _usageService.getAppUsage();
      print('Loaded usage data: $data'); // 添加调试输出
      setState(() {
        _usageData = data;
      });
      await _usageService.saveUsageData(data);
    } catch (e) {
      print('Error loading data: $e'); // 添加错误输出
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('应用使用统计'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 300,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _getMaxUsage(),
                  barGroups: _createBarGroups(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            _getDateString(value.toInt()),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}分钟',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _usageData.length,
              itemBuilder: (context, index) {
                final usage = _usageData[index];
                return ListTile(
                  title: Text(usage.appName),
                  subtitle: Text(
                    '使用时长: ${usage.usageTime.inMinutes}分钟',
                  ),
                  trailing: Text(
                    _formatDate(usage.date),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups() {
    // 按日期分组数据
    final Map<String, double> dailyUsage = {};
    for (var usage in _usageData) {
      final date = _formatDate(usage.date);
      dailyUsage[date] = (dailyUsage[date] ?? 0) + usage.usageTime.inMinutes;
    }

    return dailyUsage.entries.mapIndexed((index, entry) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: entry.value,
            color: Colors.blue,
          ),
        ],
      );
    }).toList();
  }

  double _getMaxUsage() {
    if (_usageData.isEmpty) return 100;
    return _usageData.map((e) => e.usageTime.inMinutes.toDouble()).reduce(max) *
        1.2;
  }

  String _getDateString(int index) {
    if (_usageData.isEmpty) return '';
    final dates = _usageData.map((e) => _formatDate(e.date)).toSet().toList();
    if (index >= 0 && index < dates.length) {
      return dates[index];
    }
    return '';
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}';
  }
}
