import 'package:flutter_mana/flutter_mana.dart';

abstract class StorageProvider implements ManaStorageProvider{
  /// 获取名称
  String get name;
}
