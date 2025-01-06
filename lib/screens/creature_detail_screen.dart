import 'package:flutter/material.dart';
import '../models/creature.dart';

class CreatureDetailScreen extends StatelessWidget {
  final Creature creature;

  const CreatureDetailScreen({
    super.key,
    required this.creature,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(creature.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildStats(),
            _buildTips(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: creature.isBeneficial
              ? [Colors.green.shade100, Colors.blue.shade100]
              : [Colors.red.shade100, Colors.orange.shade100],
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'creature_${creature.name}',
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: creature.isBeneficial ? Colors.green : Colors.red,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Lv.${creature.level}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: creature.isBeneficial ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            creature.type,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: creature.isBeneficial
                  ? Colors.green.shade800
                  : Colors.red.shade800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            creature.bundleId, // 显示 bundle ID
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          Text(
            creature.isBeneficial ? '善良生物' : '邪恶生物',
            style: TextStyle(
              color: creature.isBeneficial
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '使用统计',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildStatRow('总使用时间',
                  '${creature.usage.inHours}小时${creature.usage.inMinutes % 60}分钟'),
              _buildStatRow('当前等级', 'Lv.${creature.level}'),
              _buildStatRow('生物类型', creature.type),
              _buildLevelProgress(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelProgress() {
    final nextLevel = creature.level + 1;
    final progress = (creature.usage.inHours % 2) / 2.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('距离 Lv.$nextLevel 还需：'),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation(
            creature.isBeneficial ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }

  Widget _buildTips() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '使用建议',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildTip(
                creature.isBeneficial ? '继续保持良好的使用习惯' : '建议减少使用时间',
                creature.isBeneficial ? Icons.thumb_up : Icons.warning,
              ),
              _buildTip(
                '当前使用时长: ${_getTimeDescription()}',
                Icons.access_time,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTimeDescription() {
    final hours = creature.usage.inHours;
    if (hours < 1) return '适中';
    if (hours < 2) return '正常';
    if (hours < 4) return creature.isBeneficial ? '优秀' : '稍多';
    return creature.isBeneficial ? '出色' : '过多';
  }

  Widget _buildTip(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
