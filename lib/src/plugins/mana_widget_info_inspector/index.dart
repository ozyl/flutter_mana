import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mana/flutter_mana.dart';

import '../../service/inspector_overlay.dart';
import 'icon.dart';
import 'widget_info_inspector_tool_panel.dart';

class ManaWidgetInfoInspector extends StatefulWidget implements ManaPluggable {
  const ManaWidgetInfoInspector({super.key});

  @override
  State<ManaWidgetInfoInspector> createState() => _ManaWidgetInfoInspectorState();

  @override
  Widget? buildWidget(BuildContext? context) => this;

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return 'Widget 信息';
      default:
        return 'Widget Info';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_widget_info_inspector';

  @override
  void onTrigger() {}
}

class _ManaWidgetInfoInspectorState extends State<ManaWidgetInfoInspector> with WidgetsBindingObserver {
  _ManaWidgetInfoInspectorState()
      // 初始化时获取 WidgetInspectorService 的选择器实例。
      : selection = WidgetInspectorService.instance.selection;

  // 检查器选择器实例，用于管理被选中的渲染对象。
  final InspectorSelection selection;

  // 记录上次指针的位置。
  Offset? _lastPointerLocation;

  /// 根据给定的位置检查并选择 Widget。
  /// [position] 是全局坐标系中的触摸位置。
  void _inspectAt(Offset? position) {
    if (position == null) return; // 确保位置不为空
    final List<RenderObject> selected = HitTestUtils.hitTest(position);
    setState(() {
      selection.candidates = selected; // 更新选中的候选渲染对象。
    });
  }

  /// 处理手势结束事件。
  /// [details] 包含手势的详细信息。
  void _handlePanEnd(DragEndDetails details) {
    // 计算屏幕的物理尺寸并转换为逻辑像素，然后缩小 1.0 像素。
    final Rect bounds =
        (Offset.zero & (View.of(context).physicalSize / View.of(context).devicePixelRatio)).deflate(1.0);
    // 如果最后指针位置不在屏幕边界内，则清除选择。
    // 在 Dart 3 中，_lastPointerLocation 仍然可能为 null，需要显式检查。
    if (_lastPointerLocation != null && !bounds.contains(_lastPointerLocation!)) {
      setState(() {
        selection.clear(); // 清除所有选择。
      });
    }
  }

  /// 处理点击事件。
  void _handleTap() {
    if (_lastPointerLocation != null) {
      _inspectAt(_lastPointerLocation); // 如果有记录的指针位置，则检查该位置的 Widget。
    }
  }

  /// 处理手势按下事件。
  /// [event] 包含手势的详细信息。
  void _handlePanDown(DragDownDetails event) {
    _lastPointerLocation = event.globalPosition; // 记录当前指针位置。
    _inspectAt(event.globalPosition); // 立即检查该位置的 Widget。
  }

  @override
  void initState() {
    super.initState();
    selection.clear(); // 初始化时清除所有选择。
  }

  @override
  void dispose() {
    debugPaintSizeEnabled = false; // 组件销毁时关闭调试绘制模式。
    // 在 WidgetsBinding.instance 就绪后，添加一个后帧回调。
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      late RenderObjectVisitor visitor;
      // 遍历所有渲染对象并标记它们需要重新绘制。
      visitor = (RenderObject child) {
        child.markNeedsPaint(); // 标记需要重新绘制。
        child.visitChildren(visitor); // 递归访问子渲染对象。
      };
      // 访问渲染树的根视图，触发重绘。
      for (final renderView in RendererBinding.instance.renderViews) {
        renderView.visitChildren(visitor);
      }
    });
    super.dispose();
  }

  /// 切换调试绘制模式 (debugPaintSizeEnabled) 并强制刷新所有渲染对象。
  void _showAllSize() async {
    debugPaintSizeEnabled = !debugPaintSizeEnabled; // 切换调试绘制模式。
    setState(() {
      late RenderObjectVisitor visitor;
      // 遍历所有渲染对象并标记它们需要重新绘制。
      visitor = (RenderObject child) {
        child.markNeedsPaint(); // 标记需要重新绘制。
        child.visitChildren(visitor); // 递归访问子渲染对象。
      };
      // 访问渲染树的根视图，触发重绘。
      for (final renderView in RendererBinding.instance.renderViews) {
        renderView.visitChildren(visitor);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> children = [];
    // 创建手势检测器，用于捕获用户的触摸事件。
    GestureDetector gesture = GestureDetector(
      onTap: _handleTap, // 监听点击事件。
      onPanDown: _handlePanDown, // 监听手势按下事件。
      onPanEnd: _handlePanEnd, // 监听手势结束事件。
      behavior: HitTestBehavior.opaque, // 使整个区域都能响应点击。
      child: IgnorePointer(
        // 忽略子 Widget 的指针事件，确保手势检测器能捕获所有事件。
        child: SizedBox(
          width: double.infinity, // 宽度设置为屏幕宽度。
          height: double.infinity,
        ),
      ), // 高度设置为屏幕高度。
    );
    children.add(gesture);
    // 添加 InspectorOverlay，用于在选中的 Widget 上绘制调试信息。
    children.add(InspectorOverlay(selection: selection));

    return ManaFloatingWindow(
      name: widget.name,
      position: PositionType.top,
      initialWidth: 300,
      initialHeight: 100,
      modal: Stack(textDirection: TextDirection.ltr, children: children),
      body: WidgetInfoInspectorToolPanel(
        onChanged: (value) {
          selection.clear();
          _showAllSize();
        },
      ),
    );
  }
}
