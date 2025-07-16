import 'package:flutter/material.dart';

import '../../../services/inspector_overlay.dart';

class WidgetInfoInspectorBarrier extends StatelessWidget {
  final InspectorSelection selection;

  final GestureTapCallback? onTap;
  final GestureDragDownCallback? onPanDown;
  final GestureDragEndCallback? onPanEnd;

  const WidgetInfoInspectorBarrier({super.key, required this.selection, this.onTap, this.onPanDown, this.onPanEnd});

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];

    GestureDetector gesture = GestureDetector(
      onTap: onTap,
      onPanDown: onPanDown,
      onPanEnd: onPanEnd,
      behavior: HitTestBehavior.opaque,
      child: IgnorePointer(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
    children.add(gesture);

    children.add(InspectorOverlay(selection: selection));

    return Stack(textDirection: TextDirection.ltr, children: children);
  }
}
