import 'package:flutter_mana_kits/flutter_mana_kits.dart' show StorageProvider;
import 'package:get_storage/get_storage.dart';

class GetStorageProvider implements StorageProvider {
  final String _name;
  @override
  String get name => _name;

  final String _containerName;
  late GetStorage _storage;

  GetStorageProvider({String? containerName, sup, String? name})
    : _containerName = containerName ?? 'GetStorage',
      _name = name ?? 'GetStorage';

  Future<void> _ensureInitialized() async {
    _storage = GetStorage(_containerName);
    await _storage.initStorage;
  }

  @override
  Future<List<String>> getAllKeys() async {
    await _ensureInitialized();
    return _storage.getKeys().toList();
  }

  @override
  Future<dynamic> getValue(String key) async {
    await _ensureInitialized();
    return _storage.read(key);
  }

  @override
  Future<void> setValue(String key, dynamic value) async {
    await _ensureInitialized();
    await _storage.write(key, value);
  }

  @override
  Future<void> removeKey(String key) async {
    await _ensureInitialized();
    await _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    await _ensureInitialized();
    await _storage.erase();
  }
}
