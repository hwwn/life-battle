class AppUsageInfo {
  final String appName;
  final Duration usageTime;
  final DateTime date;

  AppUsageInfo({
    required this.appName,
    required this.usageTime,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'appName': appName,
        'usageTime': usageTime.inMinutes,
        'date': date.toIso8601String(),
      };

  factory AppUsageInfo.fromJson(Map<String, dynamic> json) {
    return AppUsageInfo(
      appName: json['appName'],
      usageTime: Duration(minutes: json['usageTime']),
      date: DateTime.parse(json['date']),
    );
  }
}
