class MorningContact {
  const MorningContact({required this.name, required this.phone});

  final String name;
  final String phone;

  Map<String, String> toJson() => {'name': name, 'phone': phone};

  factory MorningContact.fromJson(Map<String, dynamic> json) => MorningContact(
        name: json['name'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
      );
}

class MorningSettings {
  const MorningSettings({
    this.message = 'Good morning! Hope your day starts with a smile ☀️',
    this.hour = 8,
    this.minute = 0,
    this.enabled = false,
    this.contacts = const [],
  });

  final String message;
  final int hour;
  final int minute;
  final bool enabled;
  final List<MorningContact> contacts;

  MorningSettings copyWith({
    String? message,
    int? hour,
    int? minute,
    bool? enabled,
    List<MorningContact>? contacts,
  }) =>
      MorningSettings(
        message: message ?? this.message,
        hour: hour ?? this.hour,
        minute: minute ?? this.minute,
        enabled: enabled ?? this.enabled,
        contacts: contacts ?? this.contacts,
      );

  Map<String, dynamic> toJson() => {
        'message': message,
        'hour': hour,
        'minute': minute,
        'enabled': enabled,
        'contacts': contacts.map((contact) => contact.toJson()).toList(),
      };

  factory MorningSettings.fromJson(Map<String, dynamic> json) => MorningSettings(
        message: json['message'] as String? ?? '',
        hour: json['hour'] as int? ?? 8,
        minute: json['minute'] as int? ?? 0,
        enabled: json['enabled'] as bool? ?? false,
        contacts: (json['contacts'] as List<dynamic>? ?? [])
            .map((item) => MorningContact.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
