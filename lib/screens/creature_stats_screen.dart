import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'creature_detail_screen.dart';
import '../models/creature.dart';
import '../widgets/animated_creature_card.dart';

class CreatureStatsScreen extends StatefulWidget {
  const CreatureStatsScreen({super.key});

  @override
  State<CreatureStatsScreen> createState() => _CreatureStatsScreenState();
}

class _CreatureStatsScreenState extends State<CreatureStatsScreen> {
  static const platform = MethodChannel('app/screen_time');
  List<Creature> _creatures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final Map result = await platform.invokeMethod('getScreenTime');
      final Map appsData = result['apps'] as Map;

      // 将应用使用数据转换为生物列表
      final creatures = appsData.entries.map((entry) {
        final appInfo = entry.value as Map;
        return Creature.fromAppUsage(
          entry.key,
          appInfo['bundleId'] as String,
          appInfo['creatureType'] as String? ?? "未知生物",
          appInfo['isBeneficial'] as bool? ?? true,
          Duration(minutes: appInfo['minutes'] as int),
        );
      }).toList();

      setState(() {
        _creatures = creatures;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的生物图鉴'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildSummary(),
                Expanded(child: _buildCreatureList()),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildSummary() {
    final beneficialCount = _creatures.where((c) => c.isBeneficial).length;
    final harmfulCount = _creatures.length - beneficialCount;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryCard(
            '善良生物',
            beneficialCount,
            Colors.green.shade100,
            Icons.pets,
          ),
          _buildSummaryCard(
            '邪恶生物',
            harmfulCount,
            Colors.red.shade100,
            Icons.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
      String title, int count, Color color, IconData icon) {
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87, // 标题文字颜色
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87, // 数字文字颜色
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreatureList() {
    return ListView.builder(
      itemCount: _creatures.length,
      itemBuilder: (context, index) {
        final creature = _creatures[index];
        return AnimatedCreatureCard(
          creature: creature,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreatureDetailScreen(creature: creature),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCreatureCard(Creature creature) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: creature.isBeneficial ? Colors.green.shade50 : Colors.red.shade50,
      child: ListTile(
        leading: _buildLevelIndicator(creature.level),
        title: Text(creature.name),
        subtitle: Text(creature.type),
        trailing: Text(
          '${creature.usage.inHours}小时${creature.usage.inMinutes % 60}分钟',
        ),
      ),
    );
  }

  Widget _buildLevelIndicator(int level) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: level > 3 ? Colors.red : Colors.green,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          'Lv.$level',
          style: TextStyle(
            color: level > 3 ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
