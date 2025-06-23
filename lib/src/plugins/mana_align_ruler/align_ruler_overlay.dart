import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于触觉反馈

import '../../utils/hit_test_utils.dart';
// 导入依赖的绘制器和工具类
import 'align_ruler_painter.dart';

/// `AlignRulerOverlay` 是对齐标尺插件的核心覆盖层 UI 组件。
/// 它负责绘制十字准线、水平/垂直标尺线、坐标文本，并处理十字准线的拖动和吸附逻辑。
class AlignRulerOverlay extends StatefulWidget {
  /// 屏幕的当前尺寸，用于标尺线的全屏绘制和坐标计算。
  final Size windowSize;

  /// 十字准线可拖动点的尺寸。
  final Size dotSize;

  /// 十字准线可拖动点从左上角到其中心的偏移量。
  final Offset dotCenterOffset;

  /// 坐标文本的样式。
  final TextStyle coordinateTextStyle;

  /// 坐标文本的预估尺寸，用于精确布局。
  final Size coordinateTextSize;

  /// 是否启用吸附到最近部件边缘的功能。
  final bool snapToWidgetEnabled;

  /// 构造一个 `AlignRulerOverlay`。
  const AlignRulerOverlay({
    super.key,
    required this.windowSize,
    required this.dotSize,
    required this.dotCenterOffset,
    required this.coordinateTextStyle,
    required this.coordinateTextSize,
    required this.snapToWidgetEnabled,
  });

  @override
  State<AlignRulerOverlay> createState() => _AlignRulerOverlayState();
}

/// `_AlignRulerOverlayState` 是 `AlignRulerOverlay` 的状态类。
/// 它管理十字准线的动态位置和吸附状态。
class _AlignRulerOverlayState extends State<AlignRulerOverlay> {
  // 十字准线可拖动点的当前屏幕位置（中心点）。
  late Offset _dotPosition;

  // 一个 ValueNotifier，用于通知 CustomPainter 绘制当前选中的 RenderObject 的边界。
  // 当吸附模式下选中新的部件时，它会触发 CustomPaint 的重绘。
  final ValueNotifier<RenderObject?> _selectedRenderObjectNotifier = ValueNotifier<RenderObject?>(null);

  @override
  void initState() {
    super.initState();
    // 初始化十字准线位置为屏幕中心。
    _dotPosition = widget.windowSize.center(Offset.zero);
  }

  @override
  void dispose() {
    // 释放 ValueNotifier 资源，防止内存泄漏。
    _selectedRenderObjectNotifier.dispose();
    super.dispose();
  }

  /// 处理十字准线拖动更新事件。
  ///
  /// 在拖动过程中，实时更新十字准线的位置，并清除任何当前的部件选中状态。
  void _onPanUpdate(DragUpdateDetails dragDetails) {
    setState(() {
      _dotPosition = dragDetails.globalPosition; // 更新点的位置为全局拖动位置
      _selectedRenderObjectNotifier.value = null; // 自由拖动时清除选中状态
    });
  }

  /// 处理十字准线拖动结束事件。
  ///
  /// 如果“吸附到部件”功能开启，则尝试将十字准线吸附到其下方最近部件的边缘。
  void _onPanEnd(DragEndDetails dragDetails) {
    // 如果吸附功能未开启，则直接返回并清除选中状态。
    if (!widget.snapToWidgetEnabled) {
      _selectedRenderObjectNotifier.value = null;
      return;
    }

    // 调用 `HitTestUtils` 执行命中测试，获取当前点下方的所有 RenderObject。
    final List<RenderObject> objects = HitTestUtils.hitTest(_dotPosition);

    Offset? snappedOffset;
    RenderObject? snappedObject;

    // 遍历命中的 RenderObject 列表，尝试吸附到最具体的（面积最小的）部件边缘。
    for (final RenderObject obj in objects) {
      // 获取当前 RenderObject 相对于屏幕的全局变换矩阵。
      final Matrix4 transform = obj.getTransformTo(null);
      // 计算 RenderObject 在全局屏幕坐标系中的实际绘制矩形。
      final Rect rect = obj.paintBounds.shift(Offset(transform.getTranslation().x, transform.getTranslation().y));

      // 检查当前十字准线是否实际包含在这个 RenderObject 的矩形内。
      if (rect.contains(_dotPosition)) {
        double dx, dy;
        final double halfWidth = rect.width / 2;
        final double halfHeight = rect.height / 2;

        // 根据点的位置判断是吸附到左边缘还是右边缘。
        if (_dotPosition.dx <= rect.left + halfWidth) {
          dx = rect.left; // 吸附到左边缘
        } else {
          dx = rect.right; // 吸附到右边缘
        }

        // 根据点的位置判断是吸附到上边缘还是下边缘。
        if (_dotPosition.dy <= rect.top + halfHeight) {
          dy = rect.top; // 吸附到上边缘
        } else {
          dy = rect.bottom; // 吸附到下边缘
        }
        snappedOffset = Offset(dx, dy); // 计算吸附后的新位置
        snappedObject = obj; // 记录被吸附的 RenderObject
        break; // 找到最深层的部件后即可停止遍历。
      }
    }

    // 更新 UI 状态。
    setState(() {
      if (snappedOffset != null) {
        _dotPosition = snappedOffset; // 更新十字准线位置为吸附后的位置
        _selectedRenderObjectNotifier.value = snappedObject; // 设置选中的 RenderObject
        HapticFeedback.mediumImpact(); // 提供触觉反馈，增强用户体验
      } else {
        _selectedRenderObjectNotifier.value = null; // 未吸附成功则清除选中状态
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 计算坐标标签的精确放置位置。
    final double verticalLeftOffset = _dotPosition.dx - widget.coordinateTextSize.width;
    final double horizontalTopOffset = _dotPosition.dy - widget.coordinateTextSize.height;

    return Stack(
      alignment: Alignment.topLeft, // 使用左上角对齐以便精确控制 Positioned 小部件
      children: [
        // 绘制被选中部件的蓝色边框和填充。
        Positioned.fill(
          child: ValueListenableBuilder<RenderObject?>(
            valueListenable: _selectedRenderObjectNotifier,
            builder: (context, selectedObject, child) {
              return CustomPaint(
                painter: SelectedRectPainter(selectedObject),
              );
            },
          ),
        ),
        // 水平标尺线 (红色细线)。
        Positioned(
          left: 0,
          top: _dotPosition.dy,
          child: Container(
            width: widget.windowSize.width,
            height: 1,
            color: const Color(0xffff0000), // 红色
          ),
        ),
        // 垂直标尺线 (红色细线)。
        Positioned(
          left: _dotPosition.dx,
          top: 0,
          child: Container(
            width: 1,
            height: widget.windowSize.height,
            color: const Color(0xffff0000), // 红色
          ),
        ),
        // 坐标标签：屏幕左侧距离。
        Positioned(
            top: horizontalTopOffset,
            left: _dotPosition.dx / 2 - widget.coordinateTextSize.width / 2,
            child: Text(_dotPosition.dx.toStringAsFixed(1), style: widget.coordinateTextStyle)),
        // 坐标标签：屏幕顶部距离。
        Positioned(
            left: verticalLeftOffset,
            top: _dotPosition.dy / 2 - widget.coordinateTextSize.height / 2,
            child: Text(_dotPosition.dy.toStringAsFixed(1), style: widget.coordinateTextStyle)),
        // 坐标标签：屏幕右侧距离。
        Positioned(
            left:
                _dotPosition.dx + (widget.windowSize.width - _dotPosition.dx) / 2 - widget.coordinateTextSize.width / 2,
            top: horizontalTopOffset,
            child: Text((widget.windowSize.width - _dotPosition.dx).toStringAsFixed(1),
                style: widget.coordinateTextStyle)),
        // 坐标标签：屏幕底部距离。
        Positioned(
            top: _dotPosition.dy +
                (widget.windowSize.height - _dotPosition.dy) / 2 -
                widget.coordinateTextSize.height / 2,
            left: verticalLeftOffset,
            child: Text((widget.windowSize.height - _dotPosition.dy).toStringAsFixed(1),
                style: widget.coordinateTextStyle)),
        // 可拖动的十字准线点。
        Positioned(
          left: _dotPosition.dx - widget.dotCenterOffset.dx,
          top: _dotPosition.dy - widget.dotCenterOffset.dy,
          child: GestureDetector(
            onPanUpdate: _onPanUpdate, // 拖动更新回调
            onPanEnd: _onPanEnd, // 拖动结束回调（用于吸附）
            child: Container(
              height: widget.dotSize.height,
              width: widget.dotSize.width,
              decoration: BoxDecoration(
                shape: BoxShape.circle, // 圆形外观
                border: Border.all(color: Colors.black, width: 2), // 黑色边框
                color: Colors.white.withAlpha(150), // 半透明白色填充
              ),
              child: Center(
                // 十字准线中心的小红点
                child: Container(
                  height: widget.dotSize.width / 2.5,
                  width: widget.dotSize.height / 2.5,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withAlpha(130)), // 半透明红色
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
