import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana_kits/src/plugins/mana_widget_info_inspector/widgets/widget_info_inspector.dart';

import 'icon.dart';

class ManaWidgetInfoInspector implements ManaPluggable {
  const ManaWidgetInfoInspector();

  @override
  Widget? buildWidget(BuildContext? context) => WidgetInfoInspector(name: name);

  @override
  String getLocalizedDisplayName(Locale locale) {
    return 'Widget Inspector';
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_widget_info_inspector';

  @override
  void onTrigger() {}

  @override
  Future<void> initialize() async {}
}
