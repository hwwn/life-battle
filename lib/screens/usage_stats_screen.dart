import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/usage_service.dart';

class UsageStatsScreen extends StatefulWidget {
  const UsageStatsScreen({super.key});

  @override
  State<UsageStatsScreen> createState() => _UsageStatsScreenState();
}

class _UsageStatsScreenState extends State<UsageStatsScreen> {
  final UsageService _usageService = UsageService();
  Map<String, Duration> _appUsage = {};
  List<AppCategory> _categoryUsage = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _usageService.getAppUsage();
      print('UI 收到数据: $data');
      setState(() {
        _appUsage = data['appUsage'] as Map<String, Duration>;
        _categoryUsage = data['categoryUsage'] as List<AppCategory>;
        _isLoading = false;
      });
      print('UI 更新后的数据:');
      print('应用使用时间: $_appUsage');
      print('类别使用时间: $_categoryUsage');
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('使用统计'),
          bottom: const TabBar(
            tabs: [
              Tab(text: '应用使用时间'),
              Tab(text: '类别统计'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildAppUsageTab(),
                  _buildCategoryUsageTab(),
                ],
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: _loadData,
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }

  Widget _buildAppUsageTab() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildAppPieChart(),
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildAppList(),
        ),
      ],
    );
  }

  Widget _buildCategoryUsageTab() {
    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildCategoryBarChart(),
          ),
        ),
        Expanded(
          flex: 3,
          child: _buildCategoryList(),
        ),
      ],
    );
  }

  Widget _buildAppPieChart() {
    final List<PieChartSectionData> sections = _appUsage.entries
        .map((entry) => PieChartSectionData(
              value: entry.value.inMinutes.toDouble(),
              title: '${entry.key}\n${entry.value.inMinutes}分钟',
              radius: 100,
              titleStyle: const TextStyle(fontSize: 12),
            ))
        .toList();

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 0,
        sectionsSpace: 2,
      ),
    );
  }

  Widget _buildCategoryBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _categoryUsage.isEmpty
            ? 100
            : _categoryUsage
                .map((c) => c.usage.inMinutes.toDouble())
                .reduce((a, b) => a > b ? a : b),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: true),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40, // 增加底部空间
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= _categoryUsage.length)
                  return const Text('');
                return RotatedBox(
                  quarterTurns: 1, // 旋转文本
                  child: Text(
                    _categoryUsage[value.toInt()].name,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        gridData: FlGridData(show: true),
        barGroups: _categoryUsage
            .asMap()
            .entries
            .map(
              (entry) => BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.usage.inMinutes.toDouble(),
                    width: 20,
                  ),
                ],
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildAppList() {
    final sortedEntries = _appUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView.builder(
      itemCount: sortedEntries.length,
      itemBuilder: (context, index) {
        final entry = sortedEntries[index];
        // 防止除以零
        final maxMinutes = sortedEntries.isEmpty
            ? 1
            : (sortedEntries.first.value.inMinutes == 0
                ? 1
                : sortedEntries.first.value.inMinutes);

        return ListTile(
          title: Text(entry.key),
          trailing: Text('${entry.value.inMinutes}分钟'),
          subtitle: LinearProgressIndicator(
            value: entry.value.inMinutes / maxMinutes,
          ),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    final sortedCategories = List<AppCategory>.from(_categoryUsage)
      ..sort((a, b) => b.usage.compareTo(a.usage));

    return ListView.builder(
      itemCount: sortedCategories.length,
      itemBuilder: (context, index) {
        final category = sortedCategories[index];
        // 防止除以零
        final maxMinutes = sortedCategories.isEmpty
            ? 1
            : (sortedCategories.first.usage.inMinutes == 0
                ? 1
                : sortedCategories.first.usage.inMinutes);

        return ListTile(
          title: Text(category.name),
          trailing: Text('${category.usage.inMinutes}分钟'),
          subtitle: LinearProgressIndicator(
            value: category.usage.inMinutes / maxMinutes,
          ),
        );
      },
    );
  }
}
