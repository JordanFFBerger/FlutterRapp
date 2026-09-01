import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morning_message/src/models.dart';
import 'package:morning_message/src/settings_store.dart';

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

  test('invalid saved settings fall back to defaults', () async {
    SharedPreferences.setMockInitialValues({
      'morning_settings': '{"hour":"not a number"}',
    });

    final settings = await SettingsStore().load();

    expect(settings.message, const MorningSettings().message);
    expect(settings.hour, 8);
    expect(settings.minute, 0);
    expect(settings.enabled, isFalse);
    expect(settings.contacts, isEmpty);
  });
}
