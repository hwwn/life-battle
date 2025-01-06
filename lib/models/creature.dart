class Creature {
  final String name; // 应用名称
  final String bundleId; // bundle ID
  final String type; // 生物类型
  final bool isBeneficial;
  final Duration usage;
  final int level;

  Creature({
    required this.name,
    required this.bundleId,
    required this.type,
    required this.isBeneficial,
    required this.usage,
    required this.level,
  });

  // 根据使用时间计算等级
  static int calculateLevel(Duration usage) {
    final hours = usage.inHours;
    if (hours < 1) return 1;
    if (hours < 2) return 2;
    if (hours < 4) return 3;
    if (hours < 8) return 4;
    return 5;
  }

  // 从应用使用数据创建生物
  factory Creature.fromAppUsage(
    String name,
    String bundleId,
    String creatureType,
    bool isBeneficial,
    Duration usage,
  ) {
    return Creature(
      name: name,
      bundleId: bundleId,
      type: creatureType,
      isBeneficial: isBeneficial,
      usage: usage,
      level: calculateLevel(usage),
    );
  }
}
