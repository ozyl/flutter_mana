# 日志查看器 - Logger

> 收集并展示日志。Collect and display logs.

## 使用 - Use

```dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_mana/flutter_mana.dart';

void main() {
  /// add plugin
  ManaPluginManager.instance.register(ManaLogger());
  runApp(ManaWidget(child: App(), enable: true));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ElevatedButton(
        onPressed: () {
          /// use logger to set output
          final logger = Logger(output: ManaLoggerCollector());
          logger.e('error');

          /// use debugPrint
          debugPrint('hello');
        },
        child: const Text('Add Log'),
      ),
    );
  }
}
```