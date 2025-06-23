import 'package:flutter/material.dart';

/// `AlignRulerToolbar` 是对齐标尺插件的控制面板 UI。
/// 它显示当前十字准线的坐标信息，并提供一个开关来控制吸附到部件边缘的功能。
class AlignRulerToolbar extends StatelessWidget {
  /// 当前十字准线的屏幕坐标。
  final Offset dotPosition;

  /// 屏幕的整体尺寸。
  final Size windowSize;

  /// 吸附到部件功能是否开启。
  final bool snapToWidgetEnabled;

  /// 吸附开关状态改变时的回调函数。
  final ValueChanged<bool> onSnapToWidgetChanged;

  /// 坐标文本的样式。
  final TextStyle coordinateTextStyle;

  /// 构造一个 `AlignRulerToolbar`。
  const AlignRulerToolbar({
    super.key,
    required this.dotPosition,
    required this.windowSize,
    required this.snapToWidgetEnabled,
    required this.onSnapToWidgetChanged,
    required this.coordinateTextStyle,
  });

  /// 工具栏的估算高度。用于工具栏的定位计算。
  /// 这是一个近似值，实际高度可能因内容变化而略有不同。
  static const double estimatedToolbarHeight = 60.0 + 40.0 + 16.0 + 12.0;

  @override
  Widget build(BuildContext context) {
    // 获取屏幕宽度，用于设置工具栏的响应式宽度。
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth * 0.8, // 工具栏宽度为屏幕宽度的 80%
      color: Colors.white,
      padding: const EdgeInsets.all(16), // 内部填充
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // 使 Column 占用最小的垂直空间
        children: [
          Row(
            spacing: 8,
            children: [
              // 吸附功能开关
              Switch(
                value: snapToWidgetEnabled,
                onChanged: onSnapToWidgetChanged,
                activeColor: Colors.red,
              ),
              // 吸附功能提示文本
              Expanded(
                child: Text(
                  // 根据当前语言环境显示不同的提示文本
                  Localizations.localeOf(context).languageCode == 'zh'
                      ? '开启后松手将会自动吸附至最近部件边缘'
                      : 'Snap to nearest widget edge on release',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
