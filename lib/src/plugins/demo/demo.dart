import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'icon.dart';

class Demo extends ManaPluggable {
  final String customName;

  Demo({this.customName = 'mana_demo'});

  @override
  Widget? buildWidget(BuildContext? context) {
    return Container(
      color: Colors.white,
      width: double.infinity,
      height: double.infinity,
      child: Center(child: Text('当前的插件是: $customName')),
    );
  }

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '例子_$customName';
      default:
        return 'Demo_$customName';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => customName;

  @override
  void onTrigger() {}
}
