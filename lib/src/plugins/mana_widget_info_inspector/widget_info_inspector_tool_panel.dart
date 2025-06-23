import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetInfoInspectorToolPanel extends StatefulWidget {
  final ValueChanged<bool>? onChanged;

  const WidgetInfoInspectorToolPanel({super.key, this.onChanged});

  @override
  State<WidgetInfoInspectorToolPanel> createState() => _WidgetInfoInspectorToolPanelState();
}

class _WidgetInfoInspectorToolPanelState extends State<WidgetInfoInspectorToolPanel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 8,
        children: [
          Switch(
            value: debugPaintSizeEnabled,
            onChanged: widget.onChanged,
            activeColor: Colors.red,
          ),
          Expanded(
            child: Text(
              // 根据当前语言环境显示不同的提示文本
              Localizations.localeOf(context).languageCode == 'zh' ? '切换绘制模式' : 'Switch drawing mode',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }
}
