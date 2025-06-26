# 帧率监控 - FpsMonitor

## 使用 - Use

```dart
import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

void main() {
  /// add plugin
  ManaPluginManager.instance.register(ManaFpsMonitor());
  runApp(ManaWidget(child: App(), enable: true));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Text('Add Log'),
    );
  }
}
```