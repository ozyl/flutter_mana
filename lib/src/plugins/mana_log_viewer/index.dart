import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'icon.dart';
import 'widgets/log_viewer.dart';

class ManaLogViewer implements ManaPluggable {
  ManaLogViewer() {
    ManaLogCollector.redirectDebugPrint();
  }

  @override
  Widget? buildWidget(BuildContext? context) => LogViewer(name: name);

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '日志查看器';
      default:
        return 'Log Viewer';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_log_viewer';

  @override
  void onTrigger() {}
}
