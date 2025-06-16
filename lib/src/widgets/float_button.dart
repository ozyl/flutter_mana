import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'icon.dart';

/// Defines the size of the floating dot button.
/// 定义浮动点按钮的大小。
const Size dotSize = Size(50, 50);

/// Defines the margin from the screen edges for the floating button.
/// 定义浮动按钮与屏幕边缘的边距。
const double margin = 10;

/// Defines the distance from the bottom of the screen for the floating button's initial position.
/// 定义浮动按钮初始位置距离屏幕底部的距离。
const double bottomDistance = 140;

/// A draggable floating action button.
/// This button allows users to tap it to open the plugin manager,
/// and drag it around the screen. It automatically snaps to the nearest horizontal edge.
///
/// 一个可拖拽的浮动按钮。
/// 该按钮允许用户点击打开插件管理器，并可在屏幕上拖动。它会自动吸附到最近的水平边缘。
class FloatButton extends StatefulWidget {
  /// Constructs a [FloatButton].
  ///
  /// 构造一个 [FloatButton]。
  const FloatButton({
    super.key,
  });

  @override
  State<FloatButton> createState() => _FloatButtonState();
}

class _FloatButtonState extends State<FloatButton> {
  /// Stores the current size of the window (screen).
  ///
  /// 存储当前窗口（屏幕）的大小。
  Size _windowSize = Size.zero;

  /// The current horizontal offset (x-coordinate) of the floating button.
  ///
  /// 浮动按钮当前的水平偏移量（x 坐标）。
  double _dx = 0;

  /// The current vertical offset (y-coordinate) of the floating button.
  ///
  /// 浮动按钮当前的垂直偏移量（y 坐标）。
  double _dy = 0;

  @override
  void initState() {
    super.initState();
    // Adds a listener to the ManaPluginManager to react to plugin events.
    // 添加一个监听器到 ManaPluginManager，以响应插件事件。
    ManaPluginManager.instance.addListener(_handlePluginEvent);
  }

  @override
  void dispose() {
    // Removes the listener when the widget is disposed to prevent memory leaks.
    // 在部件被销毁时移除监听器，以防止内存泄漏。
    ManaPluginManager.instance.removeListener(_handlePluginEvent);
    super.dispose();
  }

  /// Handles events triggered by the [ManaPluginManager].
  /// It forces a UI update if the widget is mounted.
  ///
  /// 处理 [ManaPluginManager] 触发的事件。
  /// 如果部件已挂载，则强制更新 UI。
  void _handlePluginEvent(ManaPluginEvent event, ManaPluggable? plugin) {
    // Update the UI.
    // 更新UI。
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recalculates and sets the initial position of the button when dependencies change.
    // 当依赖项更改时，重新计算并设置按钮的初始位置。
    _resetPosition();
  }

  /// Resets the floating button's position to its initial calculated position.
  ///
  /// 将浮动按钮的位置重置为其初始计算位置。
  void _resetPosition() {
    if (!mounted) return;
    // Get the current screen size.
    // 获取当前屏幕大小。
    _windowSize = MediaQuery.sizeOf(context);
    // Calculate initial horizontal position (right edge with margin).
    // 计算初始水平位置（右边缘带边距）。
    _dx = _windowSize.width - dotSize.width - margin;
    // Calculate initial vertical position (bottom with specific distance).
    // 计算初始垂直位置（底部带有特定距离）。
    _dy = _windowSize.height - dotSize.height - bottomDistance;
    setState(() {});
  }

  /// Updates the button's position during a drag gesture.
  /// [details] Contains the global position of the pointer during the drag.
  ///
  /// 在拖动手势期间更新按钮的位置。
  /// [details] 包含拖动期间指针的全局位置。
  void dragEvent(DragUpdateDetails details) {
    setState(() {
      _dx = details.globalPosition.dx - dotSize.width / 2;
      _dy = details.globalPosition.dy - dotSize.height / 2;
    });
  }

  /// Handles the end of a drag gesture, snapping the button to the nearest horizontal edge.
  /// [details] Contains information about the drag end event.
  ///
  /// 处理拖动手势结束，将按钮吸附到最近的水平边缘。
  /// [details] 包含拖动结束事件的信息。
  void dragEnd(DragEndDetails details) {
    setState(() {
      // If the center of the button is on the left half of the screen, snap to left.
      // 如果按钮中心在屏幕左半部分，则吸附到左侧。
      if (_dx + dotSize.width / 2 < _windowSize.width / 2) {
        _dx = margin;
      } else {
        // Otherwise, snap to right.
        // 否则，吸附到右侧。
        _dx = _windowSize.width - dotSize.width - margin;
      }

      // Clamp vertical position to stay within screen bounds.
      // 将垂直位置限制在屏幕范围内。
      if (_dy + dotSize.height > _windowSize.height) {
        _dy = _windowSize.height - dotSize.height - margin;
      } else if (_dy < 0) {
        _dy = margin;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the icon of the currently activated plugin. If no plugin is activated, use a default icon.
    // 获取当前激活插件的图标。如果没有插件被激活，则使用默认图标。
    final icon = ManaPluginManager.instance.activatedManaPluggable?.iconImageProvider;

    return Positioned(
      left: _dx,
      top: _dy,
      child: GestureDetector(
        onTap: () {
          if (ManaPluginManager.instance.activatedManaPluggable != null &&
              !ManaPluginManager.instance.manaPluginManagerWindowMainVisibility) {
            ManaPluginManager.instance.setManaPluginManagerMainVisibility(true);
            return;
          }
          // When tapped, set the visibility of the plugin manager panel to true.
          // 当点击时，将插件管理器面板的可见性设置为 true。
          ManaPluginManager.instance
              .setManaPluginManagerVisibility(!ManaPluginManager.instance.manaPluginManagerWindowVisibility);
        },
        // Handle drag end events for both vertical and horizontal drags.
        // 处理垂直和水平拖动的拖动结束事件。
        onVerticalDragEnd: dragEnd,
        onHorizontalDragEnd: dragEnd,
        // Handle drag update events for both vertical and horizontal drags.
        // 处理垂直和水平拖动的拖动更新事件。
        onHorizontalDragUpdate: dragEvent,
        onVerticalDragUpdate: dragEvent,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                offset: Offset(0.0, 0.0),
                blurRadius: 2.0,
                spreadRadius: 1.0,
              ),
            ],
          ),
          width: dotSize.width,
          height: dotSize.height,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8),
              // Display the plugin icon or a default icon if none is available.
              // 显示插件图标，如果没有可用图标则显示默认图标。
              child: Image(image: icon ?? iconImage),
            ),
          ),
        ),
      ),
    );
  }
}
