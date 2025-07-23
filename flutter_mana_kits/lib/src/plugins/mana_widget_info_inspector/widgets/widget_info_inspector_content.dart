import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mana_kits/src/i18n/i18n_mixin.dart';

import 'widget_info_inspector_detail.dart';

class WidgetInfoInspectorContent extends StatelessWidget with I18nMixin {
  final Element? element;

  final ValueChanged<bool>? onChanged;

  const WidgetInfoInspectorContent({super.key, this.element, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            spacing: 8,
            children: [
              Switch(
                value: debugPaintSizeEnabled,
                onChanged: onChanged,
                activeColor: Colors.red,
              ),
              Text(
                t('widget_info_inspector.tip'),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: element == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) {
                              return InfoPage(elements: element!.debugGetDiagnosticChain());
                            },
                          ),
                        );
                      },
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(Icons.remove_red_eye_outlined),
              )
            ],
          ),
        ],
      ),
    );
  }
}
