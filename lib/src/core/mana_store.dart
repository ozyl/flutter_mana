import 'dart:async';

import 'package:flutter_mana/flutter_mana.dart';

class ManaStore {
  static ManaStore? _instance;

  static ManaStore get instance {
    _instance ??= ManaStore._();
    return _instance!;
  }

  ManaStore._();


  ManaStorageProvider get storageProvider => ManaPluginManager.instance.storageProvider;


  Future<ManaState> getManaState() async {
    final floatActionButtonSize = await storageProvider.getValue('mana_floating_button_size') as double?;
    final floatActionButtonOpacity = await storageProvider.getValue('mana_floating_button_opacity') as double?;

    return ManaState(
      initialFloatingButtonSize: floatActionButtonSize,
      initialFloatingButtonOpacity: floatActionButtonOpacity,
    );
  }

  Future<void> setManaState(ManaState manaState) async {
    await storageProvider.setValue('mana_floating_button_size', manaState.floatingButtonSize.value);
    await storageProvider.setValue('mana_floating_button_opacity', manaState.floatingButtonOpacity.value);
  }

  Future<(double, double)> getFloatActionButtonPosition() async {
    final x = await storageProvider.getValue('mana_floating_button_x') as double? ?? 0;
    final y = await storageProvider.getValue('mana_floating_button_y') as double? ?? 0;
    return (x, y);
  }

  Future<void> setFloatActionButtonPosition(double x, double y) async {
    await ManaPluginManager.instance.storageProvider.setValue('mana_floating_button_x', double.parse(x.toStringAsFixed(1)));
    await ManaPluginManager.instance.storageProvider.setValue('mana_floating_button_y', double.parse(y.toStringAsFixed(1)));
  }
}
