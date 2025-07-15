class Goal {
  String title;
  String? info;
  int timesPerDay;
  List<bool> checks;
  bool autoRepeat;

  Goal({
    required this.title,
    this.info,
    required this.timesPerDay,
    required this.checks,
    this.autoRepeat = false,
  });

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
    title: json['title'],
    info: json['info'],
    timesPerDay: json['timesPerDay'],
    checks: List<bool>.from(json['checks']),
    autoRepeat: json['autoRepeat'] ?? false, // ←
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'info': info,
    'timesPerDay': timesPerDay,
    'checks': checks,
    'autoRepeat': autoRepeat, // ←
  };
}
