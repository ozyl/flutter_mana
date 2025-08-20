import 'package:flutter/material.dart';
import 'package:flutter_mana_kits/flutter_mana_kits.dart';

class StorageScope extends InheritedWidget {
  final List<StorageProvider> storageProviders;

  static StorageScope? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<StorageScope>();
  }

  const StorageScope({super.key, required this.storageProviders, required super.child});

  @override
  bool updateShouldNotify(StorageScope oldWidget) => storageProviders != oldWidget.storageProviders;
}