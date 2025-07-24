import 'package:flutter/material.dart';
import 'package:flutter_mana_kits/src/i18n/i18n_mixin.dart';
import 'package:flutter_mana_kits/src/icons/kit_icons.dart';

import 'widget_info_inspector_detail.dart';

class WidgetInfoInspectorContent extends StatefulWidget {
  final Element? element;

  final ValueChanged<bool>? onChanged;

  const WidgetInfoInspectorContent({super.key, this.element, this.onChanged});

  @override
  State<WidgetInfoInspectorContent> createState() => _WidgetInfoInspectorContentState();
}

class _WidgetInfoInspectorContentState extends State<WidgetInfoInspectorContent> with I18nMixin {
  bool _debugPaintSizeEnabled = false;

  void _onChange(bool value) {
    _debugPaintSizeEnabled = value;
    widget.onChanged?.call(value);
    setState(() {});
  }

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
                value: _debugPaintSizeEnabled,
                onChanged: _onChange,
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
                onPressed: widget.element == null
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) {
                              return InfoPage(elements: widget.element!.debugGetDiagnosticChain());
                            },
                          ),
                        );
                      },
                constraints: const BoxConstraints(),
                style: IconButton.styleFrom(
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: Icon(KitIcons.eye),
              )
            ],
          ),
        ],
      ),
    );
  }
}
