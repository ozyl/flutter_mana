import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana_kits/flutter_mana_kits.dart';
import 'package:flutter_mana_kits/src/plugins/mana_storage_viewer/storage/storage_scope.dart';

import 'icon.dart';
import 'widgets/storage_viewer.dart';

export 'storage/storage_provider_interface.dart';

class ManaStorageViewer implements ManaPluggable {
  final List<StorageProvider> providers;

  const ManaStorageViewer({this.providers = const []});

  @override
  Widget? buildWidget(BuildContext? context) => StorageScope(
      storageProviders: providers, child: StorageViewer(name: name));

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return 'Storage Manager';
      default:
        return 'Storage Manager';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_storage_viewer';

  @override
  void onTrigger() {}

  @override
  Future<void> initialize() async {}
}
