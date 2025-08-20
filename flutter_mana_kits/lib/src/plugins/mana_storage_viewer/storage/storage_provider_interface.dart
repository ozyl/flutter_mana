abstract class StorageProvider {
  /// 获取名称
  String get name;

  /// 获取所有键
  Future<List<String>> getAllKeys();
  
  /// 获取值
  Future<dynamic> getValue(String key);
  
  /// 设置值
  Future<void> setValue(String key, dynamic value);
  
  /// 删除键
  Future<void> removeKey(String key);
  
  /// 清空所有数据
  Future<void> clear();
}
