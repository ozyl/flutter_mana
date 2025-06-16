import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'align_ruler_overlay.dart';
import 'align_ruler_toolbar.dart';
import 'icon.dart';

const _name = 'mana_align_ruler';

/// `ManaAlignRuler` 是一个 Flutter 插件，提供交互式对齐标尺工具。
///
/// 该工具允许开发者：
/// 1. 拖动十字准线来测量距屏幕边缘的距离。
/// 2. 切换“吸附到部件”模式，在该模式下，十字准线在拖动结束时自动吸附到
///    最近检测到的部件边缘。
/// 3. 查看相对于十字准线的精确坐标值（左、右、上、下）。
class ManaAlignRuler extends StatefulWidget implements ManaPluggable {
  /// 构造一个 `ManaAlignRuler` 插件实例。
  const ManaAlignRuler({super.key});

  @override
  State<ManaAlignRuler> createState() => _ManaAlignRulerState();

  @override
  Widget? buildWidget(BuildContext? context) => this;

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => _name;

  @override
  String getLocalizedDisplayName(Locale locale) {
    if (locale.languageCode == 'zh') {
      return '对齐标尺';
    }
    return 'Align Ruler';
  }

  @override
  void onTrigger() {}
}

/// `_ManaAlignRulerState` 是 `ManaAlignRuler` 的状态类。
/// 它管理对齐标尺的逻辑和 UI 状态，包括十字准线的位置、吸附模式以及工具栏的显示。
class _ManaAlignRulerState extends State<ManaAlignRuler> {
  // 屏幕的当前尺寸。在组件首次渲染时获取。
  Size _windowSize = Size.zero;

  // 十字准线可拖动点的尺寸。
  final Size _dotSize = const Size(80, 80);
  // 从可拖动点左上角到其中心的偏移量，用于精确放置。
  late Offset _dotCenterOffset;

  // 坐标文本的样式。
  static const TextStyle _coordinateTextStyle = TextStyle(color: Colors.red, fontSize: 15, fontWeight: FontWeight.bold);
  // 坐标文本的尺寸，用于布局计算。
  Size _coordinateTextSize = Size.zero;

  // 工具栏的当前垂直屏幕位置。
  double _toolBarY = 60.0;
  // 控制是否启用“吸附到最近部件边缘”功能的开关状态。
  bool _snapToWidgetEnabled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _windowSize = MediaQuery.of(context).size;
        _dotCenterOffset = _dotSize.center(Offset.zero);
        _coordinateTextSize = _getTextSize(_coordinateTextStyle);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// 处理工具栏垂直拖动更新事件。
  ///
  /// 实时更新工具栏的垂直位置，并将其限制在屏幕可见范围内。
  void _toolBarPanUpdate(DragUpdateDetails dragDetails) {
    setState(() {
      _toolBarY = dragDetails.globalPosition.dy - 40;
      _toolBarY = _toolBarY.clamp(0.0, _windowSize.height - AlignRulerToolbar.estimatedToolbarHeight - 16);
    });
  }

  /// 根据给定的文本样式，估算一个通用文本的尺寸。
  /// 用于预先计算坐标标签的宽度和高度，以便精确布局。
  Size _getTextSize(TextStyle style) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: TextSpan(
        text: '9999.9',
        style: style,
      ),
    );
    textPainter.layout();
    return Size(textPainter.width, textPainter.height);
  }

  /// 处理“吸附到部件”功能开关状态的改变。
  ///
  /// 更新内部状态。
  void _switchSnapToWidget(bool enabled) {
    setState(() {
      _snapToWidgetEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 如果窗口尺寸尚未初始化（例如，首次构建或屏幕方向改变），则进行初始化。
    if (_windowSize.isEmpty) {
      _windowSize = MediaQuery.of(context).size;
      _dotCenterOffset = _dotSize.center(Offset.zero);
      _coordinateTextSize = _getTextSize(_coordinateTextStyle);
    }

    return ManaFloatingWindow(
      name: _name,
      initialHeight: 180,
      // ManaFloatingWindow 负责浮动窗口的显示和交互。
      // 这里的 `body` 参数现在承载了独立的工具栏组件。
      body: GestureDetector(
        onVerticalDragUpdate: _toolBarPanUpdate,
        child: AlignRulerToolbar(
          // 注意：dotPosition 不再直接传递给 toolbar，toolbar 只需知道吸附状态
          // dotPosition 现在由 _AlignRulerOverlay 内部管理和显示
          dotPosition: Offset.zero, // 占位符，实际坐标在 AlignRulerOverlay 中处理
          windowSize: _windowSize,
          snapToWidgetEnabled: _snapToWidgetEnabled,
          onSnapToWidgetChanged: _switchSnapToWidget,
          coordinateTextStyle: _coordinateTextStyle,
        ),
      ),
      // `modal` 参数现在承载了新创建的 `AlignRulerOverlay` 组件。
      modal: AlignRulerOverlay(
        windowSize: _windowSize,
        dotSize: _dotSize,
        dotCenterOffset: _dotCenterOffset,
        coordinateTextStyle: _coordinateTextStyle,
        coordinateTextSize: _coordinateTextSize,
        snapToWidgetEnabled: _snapToWidgetEnabled,
      ),
    );
  }
}
