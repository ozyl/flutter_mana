# Widget详情 - WidgetInfoInspector

## 使用 - Use

```dart
import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

void main() {
  /// add plugin
  ManaPluginManager.instance.register(ManaWidgetInfoInspector());
  
  runApp(App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'WidgetInfoInspector',
      home: ManaWidget(child: Text('Widget Info Inspector')),
    );
  }
}
```