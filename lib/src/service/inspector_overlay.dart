import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// 将所有常量整合到当前文件中

/// 提示框文本的最大行数。
const int kMaxTooltipLines = 10;

/// 屏幕边缘边距。
const double kScreenEdgeMargin = 10.0;

/// 提示框内边距。
const double kTooltipPadding = 5.0;

/// 提示框背景颜色。
const Color kTooltipBackgroundColor = Color.fromARGB(230, 60, 60, 60);

/// 选中渲染对象的填充颜色。
const Color kHighlightedRenderObjectFillColor = Color.fromARGB(128, 128, 128, 255);

/// 选中渲染对象的边框颜色。
const Color kHighlightedRenderObjectBorderColor = Color.fromARGB(128, 64, 64, 128);

/// 提示文本颜色。
const Color kTipTextColor = Color(0xFFFFFFFF);

/// [InspectorOverlay] 是一个 [LeafRenderObjectWidget]，用于在屏幕上绘制
/// Flutter Widget 的边界和信息，作为调试工具的一部分。
class InspectorOverlay extends LeafRenderObjectWidget {
  /// 构造函数。
  /// [selection] 是当前选中的 Widget 集合。
  /// [needEdges] 控制是否绘制非选中候选 Widget 的边界。
  /// [needDescription] 控制是否显示选中 Widget 的详细信息文本。
  const InspectorOverlay({
    super.key,
    required this.selection,
    this.needEdges = true,
    this.needDescription = true,
  });

  /// 选中的渲染对象集合。
  final InspectorSelection selection;

  /// 是否需要显示描述信息。
  final bool needDescription;

  /// 是否需要显示边界边缘。
  final bool needEdges;

  @override
  RenderInspectorOverlay createRenderObject(BuildContext context) {
    // 创建对应的 RenderObject 实例。
    return RenderInspectorOverlay(
      selection: selection,
      needDescription: needDescription,
      needEdges: needEdges,
    );
  }

  @override
  void updateRenderObject(BuildContext context, RenderInspectorOverlay renderObject) {
    // 更新 RenderObject 的属性。
    renderObject.selection = selection;
    renderObject.needDescription = needDescription;
    renderObject.needEdges = needEdges;
  }
}

/// [RenderInspectorOverlay] 是 [InspectorOverlay] 对应的 [RenderBox]。
/// 它负责绘制选中的 Widget 边界、其他候选 Widget 边界以及选中 Widget 的描述信息。
class RenderInspectorOverlay extends RenderBox {
  RenderInspectorOverlay({
    required InspectorSelection selection,
    required bool needDescription,
    required bool needEdges,
  })  : _selection = selection,
        _needDescription = needDescription,
        _needEdges = needEdges;

  bool get needDescription => _needDescription;
  bool _needDescription;

  set needDescription(bool value) {
    if (value != _needDescription) {
      _needDescription = value;
    }
    markNeedsPaint(); // 属性改变时标记需要重绘。
  }

  bool get needEdges => _needEdges;
  bool _needEdges;

  set needEdges(bool value) {
    if (value != _needEdges) {
      _needEdges = value;
    }
    markNeedsPaint(); // 属性改变时标记需要重绘。
  }

  InspectorSelection get selection => _selection;
  InspectorSelection _selection;

  set selection(InspectorSelection value) {
    if (value != _selection) {
      _selection = value;
    }
    markNeedsPaint(); // 属性改变时标记需要重绘。
  }

  @override
  bool get sizedByParent => true; // 大小由父级决定。

  @override
  bool get alwaysNeedsCompositing => true; // 总是需要进行合成。

  @override
  void performResize() {
    // 根据父级的约束来确定自身大小。
    size = constraints.constrain(const Size(double.infinity, double.infinity));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    assert(needsCompositing);
    // 将绘制工作委托给 [_InspectorOverlayLayer] 层。
    context.addLayer(_InspectorOverlayLayer(
      needEdges: needEdges,
      needDescription: needDescription,
      overlayRect: Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      selection: selection,
    ));
  }
}

/// [_InspectorOverlayLayer] 是一个自定义的 [Layer]，用于高效地绘制
/// 调试覆盖层的内容，避免不必要的重绘。
class _InspectorOverlayLayer extends Layer {
  _InspectorOverlayLayer({
    required this.overlayRect,
    required this.selection,
    required this.needDescription,
    required this.needEdges,
  });

  InspectorSelection selection;

  final bool needDescription;

  final bool needEdges;

  final Rect overlayRect;

  // 用于缓存上次的渲染状态，避免重复绘制。
  _InspectorOverlayRenderState? _lastState;

  // 用于缓存绘制好的图片。
  late ui.Picture _picture;

  // 用于绘制文本的 TextPainter。
  TextPainter? _textPainter;

  // TextPainter 的最大宽度缓存。
  double? _textPainterMaxWidth;

  @override
  void addToScene(ui.SceneBuilder builder, [Offset layerOffset = Offset.zero]) {
    // 如果没有活动的选中项，则不进行绘制。
    if (!selection.active) return;

    final _SelectionInfo info = _SelectionInfo(selection);
    final RenderObject? selected = info.renderObject;

    // 如果没有选中的渲染对象，则直接返回。
    if (selected == null) return;

    final List<_TransformedRect> candidates = <_TransformedRect>[];
    // 遍历所有候选渲染对象，并将其转换为带变换的矩形。
    for (RenderObject candidate in selection.candidates) {
      // 排除当前选中的对象以及未附加到渲染树的对象。
      if (candidate == selected || !candidate.attached) continue;
      candidates.add(_TransformedRect(candidate));
    }

    // 构建当前的渲染状态。
    final _InspectorOverlayRenderState state = _InspectorOverlayRenderState(
      selectionInfo: info,
      overlayRect: overlayRect,
      selected: _TransformedRect(selected),
      // selected 已在前面检查过 null。
      textDirection: TextDirection.ltr,
      // 强制文本方向为从左到右。
      candidates: candidates,
    );

    // 如果当前状态与上次缓存的状态不同，则重新绘制图片并更新缓存。
    if (state != _lastState) {
      _lastState = state;
      _picture = _buildPicture(state);
    }
    // 将绘制好的图片添加到场景中。
    builder.addPicture(layerOffset, _picture);
  }

  /// 构建绘制覆盖层内容的 [ui.Picture]。
  ui.Picture _buildPicture(_InspectorOverlayRenderState state) {
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder, state.overlayRect);
    final Size size = state.overlayRect.size;

    // 选中 Widget 的填充画笔。
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = kHighlightedRenderObjectFillColor;

    // 选中 Widget 的边框画笔。
    final Paint borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = kHighlightedRenderObjectBorderColor;

    // 绘制选中 Widget 的填充和边框。
    final Rect selectedPaintRect = state.selected.rect.deflate(0.5);
    canvas
      ..save() // 保存画布状态。
      ..transform(state.selected.transform.storage) // 应用变换矩阵。
      ..drawRect(selectedPaintRect, fillPaint) // 绘制填充矩形。
      ..drawRect(selectedPaintRect, borderPaint) // 绘制边框矩形。
      ..restore(); // 恢复画布状态。

    // 如果需要绘制其他候选 Widget 的边界。
    if (needEdges) {
      for (_TransformedRect transformedRect in state.candidates) {
        canvas
          ..save()
          ..transform(transformedRect.transform.storage)
          ..drawRect(transformedRect.rect.deflate(0.5), borderPaint) // 绘制边框矩形。
          ..restore();
      }
    }

    // 计算选中 Widget 的全局矩形，用于定位描述信息。
    final Rect targetRect = MatrixUtils.transformRect(state.selected.transform, state.selected.rect);
    final Offset target = Offset(targetRect.left, targetRect.center.dy);
    const double offsetFromWidget = 9.0;
    final double verticalOffset = (targetRect.height) / 2 + offsetFromWidget;

    // 如果需要显示描述信息。
    if (needDescription) {
      _paintDescription(
          canvas, state.selectionInfo.message, state.textDirection, target, verticalOffset, size, targetRect);
    }
    // 结束图片录制并返回。
    return recorder.endRecording();
  }

  /// 绘制 Widget 的描述信息。
  void _paintDescription(
    Canvas canvas,
    String message,
    TextDirection textDirection,
    Offset target,
    double verticalOffset,
    Size size,
    Rect targetRect,
  ) {
    canvas.save(); // 保存画布状态。
    // 计算描述信息文本的最大宽度。
    final double maxWidth = size.width - 2 * (kScreenEdgeMargin + kTooltipPadding);

    // 如果 TextPainter 不存在，或者文本内容、最大宽度发生变化，则重新布局 TextPainter。
    final TextSpan? textSpan = _textPainter?.text as TextSpan?;
    if (_textPainter == null || textSpan?.text != message || _textPainterMaxWidth != maxWidth) {
      _textPainterMaxWidth = maxWidth;
      _textPainter = TextPainter()
        ..maxLines = kMaxTooltipLines // 最大行数。
        ..ellipsis = '...' // 超出部分显示省略号。
        ..text = TextSpan(
            style: const TextStyle(color: kTipTextColor, fontSize: 12.0, height: 1.2), // 文本样式。
            text: message)
        ..textDirection = textDirection // 文本方向。
        ..layout(maxWidth: maxWidth); // 布局文本。
    }

    // 计算提示框的大小，包括内边距。
    final Size tooltipSize = _textPainter!.size + const Offset(kTooltipPadding * 2, kTooltipPadding * 2);

    // 根据目标位置和提示框大小计算提示框的实际位置。
    final Offset tipOffset = positionDependentBox(
      size: size,
      childSize: tooltipSize,
      target: target,
      verticalOffset: verticalOffset,
      preferBelow: false, // 优先显示在上方。
    );

    // 绘制提示框的背景。
    final Paint tooltipBackground = Paint()
      ..style = PaintingStyle.fill
      ..color = kTooltipBackgroundColor;
    canvas.drawRect(
      Rect.fromPoints(
        tipOffset,
        tipOffset.translate(tooltipSize.width, tooltipSize.height),
      ),
      tooltipBackground,
    );

    // 绘制提示框的连接箭头（小三角）。
    double wedgeY = tipOffset.dy;
    final bool tooltipBelow = tipOffset.dy > target.dy; // 判断提示框是否在目标下方。
    if (!tooltipBelow) wedgeY += tooltipSize.height; // 如果在上方，箭头在提示框底部。

    const double wedgeSize = kTooltipPadding * 2;
    double wedgeX = math.max(tipOffset.dx, target.dx) + wedgeSize * 2;
    wedgeX = math.min(wedgeX, tipOffset.dx + tooltipSize.width - wedgeSize * 2);
    final List<Offset> wedge = <Offset>[
      Offset(wedgeX - wedgeSize, wedgeY),
      Offset(wedgeX + wedgeSize, wedgeY),
      Offset(wedgeX, wedgeY + (tooltipBelow ? -wedgeSize : wedgeSize)),
    ];
    canvas.drawPath(Path()..addPolygon(wedge, true), tooltipBackground);

    // 绘制文本内容。
    _textPainter!.paint(canvas, tipOffset + const Offset(kTooltipPadding, kTooltipPadding));
    canvas.restore(); // 恢复画布状态。
  }

  @override
  @protected
  bool findAnnotations<S extends Object>(AnnotationResult<S> result, Offset localPosition, {required bool onlyFirst}) {
    // 此层不包含可点击的注解。
    return false;
  }
}

/// [_SelectionInfo] 辅助类，用于封装选中 Widget 的相关信息。
class _SelectionInfo {
  const _SelectionInfo(this.selection);

  final InspectorSelection selection;

  /// 获取当前选中的 [RenderObject]。
  RenderObject? get renderObject => selection.current;

  /// 获取当前选中的 [Element]。
  Element? get element => selection.currentElement;

  /// 获取选中 Widget 的 JSON 信息。
  Map<String, dynamic>? get jsonInfo {
    if (renderObject == null) return null;
    // 使用 WidgetInspectorService 获取 Widget 的 ID。
    final widgetId = WidgetInspectorService.instance
        // ignore: invalid_use_of_protected_member
        .toId(renderObject!.toDiagnosticsNode(), '');
    if (widgetId == null) return null;
    // 获取选中 Widget 的摘要信息字符串，并进行 JSON 解码。
    String infoStr = WidgetInspectorService.instance.getSelectedSummaryWidget(widgetId, '');
    return json.decode(infoStr) as Map<String, dynamic>; // 明确类型转换。
  }

  /// 获取选中 Widget 的源文件路径。
  String? get filePath {
    final Map? creationLocation = (jsonInfo != null && jsonInfo!.containsKey('creationLocation'))
        ? jsonInfo!['creationLocation'] as Map<String, dynamic>? // 明确类型转换
        : null;
    return creationLocation != null && creationLocation.containsKey('file')
        ? creationLocation['file'] as String? // 明确类型转换
        : null;
  }

  /// 获取选中 Widget 在源文件中的行号。
  int? get line {
    final Map? creationLocation = (jsonInfo != null && jsonInfo!.containsKey('creationLocation'))
        ? jsonInfo!['creationLocation'] as Map<String, dynamic>? // 明确类型转换
        : null;
    return creationLocation != null && creationLocation.containsKey('line')
        ? creationLocation['line'] as int? // 明确类型转换
        : null;
  }

  /// 获取用于显示在提示框中的消息字符串。
  String get message {
    // 确保 element 和 renderObject 不为空，如果为空则返回一个默认或错误消息。
    if (element == null || renderObject == null) {
      return 'No widget selected or information unavailable.';
    }
    return '''${element!.toStringShort()}\nsize: ${renderObject!.paintBounds.size}\nfilePath: ${filePath ?? 'N/A'}\nline: ${line ?? 'N/A'}''';
  }
}

/// [_InspectorOverlayRenderState] 封装了渲染覆盖层所需的所有状态信息。
class _InspectorOverlayRenderState {
  _InspectorOverlayRenderState({
    required this.overlayRect,
    required this.selected,
    required this.candidates,
    required this.textDirection,
    required this.selectionInfo,
  });

  final Rect overlayRect;
  final _TransformedRect selected;
  final List<_TransformedRect> candidates;
  final TextDirection textDirection;
  final _SelectionInfo selectionInfo;

  @override
  bool operator ==(Object other) {
    // 比较两个渲染状态是否相等，用于决定是否需要重新绘制。
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

    final _InspectorOverlayRenderState typedOther = other as _InspectorOverlayRenderState;
    return overlayRect == typedOther.overlayRect &&
        selected == typedOther.selected &&
        listEquals<_TransformedRect>(candidates, typedOther.candidates) &&
        textDirection == typedOther.textDirection &&
        selectionInfo.message == typedOther.selectionInfo.message; // 比较 message 以反映 info 变化
  }

  @override
  int get hashCode =>
      Object.hash(overlayRect, selected, Object.hashAll(candidates), textDirection, selectionInfo.message);
}

/// [_TransformedRect] 辅助类，用于存储一个渲染对象的边界矩形及其变换矩阵。
class _TransformedRect {
  _TransformedRect(RenderObject object)
      : rect = object.semanticBounds,
        transform = object.getTransformTo(null); // 获取对象到根的变换矩阵。

  final Rect rect;
  final Matrix4 transform;

  @override
  bool operator ==(Object other) {
    // 比较两个 TransformedRect 是否相等。
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final _TransformedRect typedOther = other as _TransformedRect;
    return rect == typedOther.rect && transform == typedOther.transform;
  }

  @override
  int get hashCode => Object.hash(rect, transform);
}
