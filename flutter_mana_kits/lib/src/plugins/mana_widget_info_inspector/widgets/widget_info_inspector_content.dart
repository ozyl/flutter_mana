import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mana_kits/src/i18n/i18n_mixin.dart';

class WidgetInfoInspectorContent extends StatelessWidget with I18nMixin {
  final ValueChanged<bool>? onChanged;

  const WidgetInfoInspectorContent({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
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
              t('widget_info_inspector.tip'),
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
