import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class WidgetInfoInspectorContent extends StatelessWidget {
  final ValueChanged<bool>? onChanged;

  const WidgetInfoInspectorContent({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final platformDispatcher = View.of(context).platformDispatcher;
    final locale = platformDispatcher.locales.first;

    final tip = locale.languageCode == 'zh' ? '切换绘制模式' : 'Switch drawing mode';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        spacing: 8,
        children: [
          Switch(
            value: debugPaintSizeEnabled,
            onChanged: onChanged,
            activeColor: Colors.red,
          ),
          Expanded(
            child: Text(
              tip,
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
