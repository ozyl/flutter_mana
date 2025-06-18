import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';

class ManaLoggerCollector implements LogOutput {
  // 单例实现
  static final ManaLoggerCollector _instance = ManaLoggerCollector._internal();

  factory ManaLoggerCollector() => _instance;

  ManaLoggerCollector._internal();

  // 日志最大容量
  static const int _maxLogs = 2500;

  @override
  Future<void> init() => Future.value();

  @override
  Future<void> destroy() => Future.value();

  /// 用 ValueNotifier 实现观察者模式
  final ValueNotifier<List<OutputEvent>> logs = ValueNotifier(<OutputEvent>[]);

  @override
  void output(OutputEvent event) {
    final updated = List<OutputEvent>.from(logs.value)..add(event);
    if (updated.length > _maxLogs) {
      updated.removeAt(0);
    }
    logs.value = updated; // 触发通知
  }

  void clear() {
    logs.value = <OutputEvent>[];
  }
}
