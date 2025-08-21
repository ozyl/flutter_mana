import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

class WidgetInfoInspectorBarrier extends StatelessWidget {
  final InspectorSelection selection;

  final GestureTapDownCallback? onTapDown;

  const WidgetInfoInspectorBarrier({super.key, required this.selection, this.onTapDown});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    GestureDetector gesture = GestureDetector(
      onTapDown: onTapDown,
      behavior: HitTestBehavior.opaque,
    );
    children.add(Positioned.fill(child: gesture));

    children.add(RepaintBoundary(child: InspectorOverlay(selection: selection)));

    return Stack(textDirection: TextDirection.ltr, children: children);
  }
}
