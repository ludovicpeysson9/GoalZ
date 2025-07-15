class NotificationSettings {
  bool enabled;
  int hour;
  int minute;

  NotificationSettings({
    required this.enabled,
    required this.hour,
    required this.minute,
  });

    NotificationSettings copyWith({
    bool? enabled,
    int? hour,
    int? minute,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
    );
  }


  factory NotificationSettings.fromJson(Map<String, dynamic> json) => NotificationSettings(
        enabled: json['enabled'] ?? true,
        hour: json['hour'] ?? 8,
        minute: json['minute'] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'enabled': enabled,
        'hour': hour,
        'minute': minute,
      };
}
