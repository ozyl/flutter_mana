import 'package:flutter/material.dart';

/// `SelectedRectPainter` 是一个自定义的 [CustomPainter]，
/// 用于在画布上绘制指定 [RenderObject] 的全局边界框。
/// 这个绘制器主要用于可视化被对齐标尺吸附或选中的 UI 部件。
class SelectedRectPainter extends CustomPainter {
  /// 需要绘制边界框的 [RenderObject]。如果为 `null`，则不绘制任何内容。
  final RenderObject? selectedObject;

  /// 边界框的填充颜色。
  static const Color fillColor = Colors.blue;

  /// 边界框的描边颜色。
  static const Color borderColor = Colors.blue;

  /// 边界框的描边宽度。
  static const double borderWidth = 2.0;

  /// 构造一个 `SelectedRectPainter`。
  ///
  /// 参数:
  ///   [selectedObject]: 要绘制其边界框的 RenderObject。
  const SelectedRectPainter(this.selectedObject);

  @override
  void paint(Canvas canvas, Size size) {
    // 如果没有选中的对象，则无需绘制。
    if (selectedObject == null) {
      return;
    }

    // 获取选中对象相对于屏幕（null 变换空间）的变换矩阵。
    // 这允许我们将对象的局部坐标转换为全局屏幕坐标。
    final Matrix4 transform = selectedObject!.getTransformTo(null);
    // 计算选中对象在全局屏幕坐标系中的矩形边界。
    // paintBounds 是对象绘制内容的局部边界，通过变换矩阵平移到全局位置。
    final Rect globalRect =
        selectedObject!.paintBounds.shift(Offset(transform.getTranslation().x, transform.getTranslation().y));

    // 创建用于填充矩形的画笔。
    final Paint fillPaint = Paint()
      ..color = fillColor.withAlpha(50) // 半透明填充
      ..style = PaintingStyle.fill;
    canvas.drawRect(globalRect, fillPaint);

    // 创建用于绘制矩形边框的画笔。
    final Paint borderPaint = Paint()
      ..color = borderColor // 实心边框颜色
      ..style = PaintingStyle.stroke // 描边样式
      ..strokeWidth = borderWidth; // 描边宽度
    canvas.drawRect(globalRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SelectedRectPainter oldDelegate) {
    // 只有当选中的 RenderObject 发生变化时才需要重新绘制。
    // 这可以避免不必要的重绘，提高性能。
    return oldDelegate.selectedObject != selectedObject;
  }
}
