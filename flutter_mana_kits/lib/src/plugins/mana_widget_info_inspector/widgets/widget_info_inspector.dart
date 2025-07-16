import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mana/flutter_mana.dart';

import '../../../utils/hit_test_utils.dart';
import 'widget_info_inspector_barrier.dart';
import 'widget_info_inspector_content.dart';

class WidgetInfoInspector extends StatefulWidget {
  final String name;

  const WidgetInfoInspector({super.key, required this.name});

  @override
  State<WidgetInfoInspector> createState() => _WidgetInfoInspectorState();
}

class _WidgetInfoInspectorState extends State<WidgetInfoInspector> with WidgetsBindingObserver {
  _WidgetInfoInspectorState() : selection = WidgetInspectorService.instance.selection;

  final InspectorSelection selection;

  Offset? _lastPointerLocation;

  /// 强制整个渲染树所有节点调用 markNeedsPaint()
  void markWholeRenderTreeNeedsPaint() {
    late RenderObjectVisitor visitor;

    visitor = (RenderObject child) {
      child.markNeedsPaint();
      child.visitChildren(visitor);
    };

    for (final renderView in RendererBinding.instance.renderViews) {
      renderView.visitChildren(visitor);
    }
  }

  void _inspectAt(Offset? position) {
    if (position == null) return;
    final List<RenderObject> selected = HitTestUtils.hitTest(position);

    setState(() {
      selection.candidates = selected;

      markWholeRenderTreeNeedsPaint();
    });
  }

  void _handleTap() {
    if (_lastPointerLocation != null) {
      _inspectAt(_lastPointerLocation);
    }
  }

  void _handlePanDown(DragDownDetails event) {
    _lastPointerLocation = event.globalPosition;
    _inspectAt(event.globalPosition);
  }

  void _handlePanEnd(DragEndDetails details) {
    // 计算屏幕的物理尺寸并转换为逻辑像素，然后缩小 1.0 像素
    final Rect bounds =
        (Offset.zero & (View.of(context).physicalSize / View.of(context).devicePixelRatio)).deflate(1.0);
    // 如果最后指针位置不在屏幕边界内，则清除选择
    if (_lastPointerLocation != null && !bounds.contains(_lastPointerLocation!)) {
      setState(() {
        selection.clear();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    selection.clear();
  }

  @override
  void dispose() {
    debugPaintSizeEnabled = false;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      markWholeRenderTreeNeedsPaint();
    });
    super.dispose();
  }

  void _showAllSize() async {
    debugPaintSizeEnabled = !debugPaintSizeEnabled;
    markWholeRenderTreeNeedsPaint();
  }

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: widget.name,
      position: PositionType.top,
      initialWidth: 300,
      initialHeight: 100,
      barrier: WidgetInfoInspectorBarrier(
        selection: selection,
        onTap: _handleTap,
        onPanDown: _handlePanDown,
        onPanEnd: _handlePanEnd,
      ),
      content: WidgetInfoInspectorContent(
        onChanged: (value) {
          selection.clear();
          _showAllSize();
        },
      ),
    );
  }
}
