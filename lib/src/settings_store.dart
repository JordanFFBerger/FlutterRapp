import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class SettingsStore {
  static const _key = 'morning_settings';

  Future<MorningSettings> load() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_key);
    if (value == null) return const MorningSettings();
    try {
      return MorningSettings.fromJson(
        jsonDecode(value) as Map<String, dynamic>,
      );
    } on FormatException {
      return const MorningSettings();
    } on TypeError {
      return const MorningSettings();
    }
  }

  Future<void> save(MorningSettings settings) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode(settings.toJson()));
  }
}
