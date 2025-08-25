import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'widget_info_inspector_content.dart';

class WidgetInfoInspector extends StatefulWidget {
  final String name;

  const WidgetInfoInspector({super.key, required this.name});

  @override
  State<WidgetInfoInspector> createState() => _WidgetInfoInspectorState();
}

class _WidgetInfoInspectorState extends State<WidgetInfoInspector>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: widget.name,
      showBarrier: false,
      initialWidth: 300,
      initialHeight: 100,
      content: WidgetInfoInspectorContent(),
    );
  }
}
