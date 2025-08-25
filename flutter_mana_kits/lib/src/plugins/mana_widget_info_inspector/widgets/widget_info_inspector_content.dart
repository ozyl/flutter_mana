import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana_kits/src/i18n/i18n_mixin.dart';
import 'package:flutter_mana_kits/src/icons/kit_icons.dart';

import 'widget_info_inspector_detail.dart';

class WidgetInfoInspectorContent extends StatefulWidget {
  const WidgetInfoInspectorContent({super.key});

  @override
  State<WidgetInfoInspectorContent> createState() =>
      _WidgetInfoInspectorContentState();
}

class _WidgetInfoInspectorContentState extends State<WidgetInfoInspectorContent>
    with I18nMixin {
  _onSelectionChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetInspectorService.instance.selection.addListener(_onSelectionChanged);
    WidgetsBinding.instance.debugShowWidgetInspectorOverrideNotifier
        .addListener(_onSelectionChanged);
    WidgetsBinding.instance.debugWidgetInspectorSelectionOnTapEnabled
        .addListener(_onSelectionChanged);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance.debugWidgetInspectorSelectionOnTapEnabled.value =
          true;
      WidgetsBinding.instance.debugShowWidgetInspectorOverride = true;
    });
  }

  @override
  void dispose() {
    WidgetInspectorService.instance.selection
        .removeListener(_onSelectionChanged);
    WidgetsBinding.instance.debugShowWidgetInspectorOverrideNotifier
        .removeListener(_onSelectionChanged);
    WidgetsBinding.instance.debugWidgetInspectorSelectionOnTapEnabled
        .removeListener(_onSelectionChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onSwitchChanged(false);
    });
    super.dispose();
  }

  _onSwitchChanged(bool value) {
    WidgetsBinding.instance.debugWidgetInspectorSelectionOnTapEnabled.value =
        value;
    WidgetsBinding.instance.debugShowWidgetInspectorOverride = value;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Switch(
            value: WidgetsBinding.instance.debugShowWidgetInspectorOverride,
            onChanged: _onSwitchChanged,
          ),
          Text(
            t('widget_info_inspector.tip'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          IconButton(
            onPressed:
                WidgetInspectorService.instance.selection.currentElement == null
                    ? null
                    : () {
                        ManaNavigator.pushMaterial(
                          context,
                          InfoPage(
                              elements: WidgetInspectorService
                                  .instance.selection.currentElement!
                                  .debugGetDiagnosticChain()),
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
    );
  }
}
