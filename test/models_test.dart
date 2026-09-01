import 'package:flutter_test/flutter_test.dart';
import 'package:morning_message/src/models.dart';

void main() {
  test('settings survive JSON round trip', () {
    const settings = MorningSettings(
      message: 'Rise and shine',
      hour: 7,
      minute: 15,
      enabled: true,
      contacts: [MorningContact(name: 'Sam', phone: '+15551234567')],
    );

    final decoded = MorningSettings.fromJson(settings.toJson());
    expect(decoded.message, 'Rise and shine');
    expect(decoded.hour, 7);
    expect(decoded.minute, 15);
    expect(decoded.enabled, isTrue);
    expect(decoded.contacts.single.name, 'Sam');
  });
}
