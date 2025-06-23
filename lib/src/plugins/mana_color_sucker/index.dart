import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'color_sucker.dart';
import 'color_tool_panel.dart';
import 'icon.dart';

class ManaColorSucker extends StatefulWidget implements ManaPluggable {
  const ManaColorSucker({super.key});

  @override
  State<ManaColorSucker> createState() => _ManaColorSuckerState();

  @override
  Widget? buildWidget(BuildContext? context) => this;

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '颜色吸管';
      default:
        return 'Color Sucker';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_color_sucker';

  @override
  void onTrigger() {}
}

class _ManaColorSuckerState extends State<ManaColorSucker> {
  Color _color = Colors.black;

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: 'mana_color_sucker',
      modal: ColorSucker(
        onColorChanged: (color) {
          _color = color;
          setState(() {});
        },
      ),
      position: PositionType.top,
      initialWidth: 240,
      initialHeight: 100,
      body: ColorToolPanel(
        color: _color,
      ),
    );
  }
}
