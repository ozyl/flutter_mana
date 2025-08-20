import 'dart:convert';

import 'package:flutter_mana_kits/flutter_mana_kits.dart' show StorageProvider;
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider implements StorageProvider {
  final String _name;

  SharedPreferencesProvider({String? name}) : _name = name ?? 'SharedPreferences';

  @override
  String get name => _name;

  SharedPreferences? _prefs;

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<List<String>> getAllKeys() async {
    await _ensureInitialized();
    return _prefs!.getKeys().toList();
  }

  @override
  Future<dynamic> getValue(String key) async {
    await _ensureInitialized();
    return _prefs!.get(key);
  }

  @override
  Future<void> setValue(String key, dynamic value) async {
    await _ensureInitialized();
    if (value is String) {
      await _prefs!.setString(key, value);
    } else if (value is int) {
      await _prefs!.setInt(key, value);
    } else if (value is double) {
      await _prefs!.setDouble(key, value);
    } else if (value is bool) {
      await _prefs!.setBool(key, value);
    } else if (value is List<String>) {
      await _prefs!.setStringList(key, value);
    } else {
      // 对于其他类型，转换为 JSON 字符串存储
      await _prefs!.setString(key, jsonEncode(value));
    }
  }

  @override
  Future<void> removeKey(String key) async {
    await _ensureInitialized();
    await _prefs!.remove(key);
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();
    await _prefs!.clear();
  }
}
