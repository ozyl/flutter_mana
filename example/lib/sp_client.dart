import 'dart:convert';
import 'dart:math';

import 'package:example/json_demo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpClient {
  static final Random _random = Random();

  /// 随机插入任意类型的 key-value 到 SharedPreferences
  static Future<void> insertRandom() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 随机生成 key
    String key = _randomKey();

    // 随机选择类型
    int typeIndex = _random.nextInt(5); // 5 种类型
    dynamic value;
    switch (typeIndex) {
      case 0: // int
        value = _random.nextInt(10000);
        await prefs.setInt(key, value);
        break;
      case 1: // double
        value = _random.nextDouble() * 10000;
        await prefs.setDouble(key, value);
        break;
      case 2: // bool
        value = _random.nextBool();
        await prefs.setBool(key, value);
        break;
      case 3: // String
        value = _random.nextBool() ? _randomString(_random.nextInt(8) + 3) : jsonEncode(jsonDemo);
        await prefs.setString(key, value);
        break;
      case 4: // List<String>
        int len = _random.nextInt(5) + 1;
        value = List<String>.generate(len, (_) => _randomString(_random.nextInt(6) + 2));
        await prefs.setStringList(key, value);
        break;
    }
  }

  static String _randomKey() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    return 'key_${List.generate(8, (index) => chars[_random.nextInt(chars.length)]).join()}';
  }

  static String _randomString(int length) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(length, (index) => chars[_random.nextInt(chars.length)]).join();
  }
}
