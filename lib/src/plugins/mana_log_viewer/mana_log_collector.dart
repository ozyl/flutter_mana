import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class ManaLogCollector implements LogOutput {
  static final ManaLogCollector _instance = ManaLogCollector._internal();

  factory ManaLogCollector() => _instance;

  ManaLogCollector._internal();

  static const int _maxLogs = 2500;

  @override
  Future<void> init() => Future.value();

  @override
  Future<void> destroy() => Future.value();

  final ValueNotifier<List<OutputEvent>> logs = ValueNotifier(<OutputEvent>[]);

  static DebugPrintCallback? _originalDebugPrint;

  static redirectDebugPrint() {
    if (_originalDebugPrint != null) return;
    _originalDebugPrint = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      ManaLogCollector._instance.output(OutputEvent(
          LogEvent(
            Level.debug,
            message,
          ),
          []));

      if (_originalDebugPrint != null) {
        _originalDebugPrint!(message, wrapWidth: wrapWidth);
      }
    };
  }

  @override
  void output(OutputEvent event) {
    final updated = List<OutputEvent>.from(logs.value)..add(event);
    if (updated.length > _maxLogs) {
      updated.removeAt(0);
    }
    logs.value = updated;
  }

  void clear() {
    logs.value = <OutputEvent>[];
  }
}
