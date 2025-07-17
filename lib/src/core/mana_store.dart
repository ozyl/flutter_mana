import 'dart:async';

import 'package:flutter_mana/src/core/mana_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManaStore {
  static ManaStore? _instance;

  static ManaStore get instance {
    _instance ??= ManaStore._();
    return _instance!;
  }

  ManaStore._();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  SharedPreferences get prefs {
    if (!_isInitialized) {
      throw Exception('ManaStore must be initialized first. Call init() before using prefs.');
    }
    return _prefs!;
  }

  ManaState getManaState() {
    final floatActionButtonSize = prefs.getDouble('mana_float_action_button_size');
    final floatActionButtonOpacity = prefs.getDouble('mana_float_action_button_opacity');

    return ManaState(
      initialFloatActionButtonSize: floatActionButtonSize,
      initialFloatActionButtonOpacity: floatActionButtonOpacity,
    );
  }

  Future<void> setManaState(ManaState manaState) async {
    await prefs.setDouble('mana_float_action_button_size', manaState.floatActionButtonSize.value);
    await prefs.setDouble('mana_float_action_button_opacity', manaState.floatActionButtonOpacity.value);
  }

  (double, double) getFloatActionButtonPosition() {
    final x = prefs.getDouble('mana_float_action_button_x') ?? 0;
    final y = prefs.getDouble('mana_float_action_button_y') ?? 0;
    return (x, y);
  }

  Future<void> setFloatActionButtonPosition(double x, double y) async {
    await prefs.setDouble('mana_float_action_button_x', x);
    await prefs.setDouble('mana_float_action_button_y', y);
  }
}
