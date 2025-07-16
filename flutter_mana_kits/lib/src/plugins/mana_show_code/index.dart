import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

import 'icon.dart';
import 'widgets/show_code.dart';

late HighlighterTheme theme;

class ManaShowCode implements ManaPluggable {
  const ManaShowCode();

  @override
  Widget? buildWidget(BuildContext? context) => ShowCode(name: name, theme: theme);

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '显示代码';
      default:
        return 'Show Code';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_show_code';

  @override
  void onTrigger() {}

  @override
  Future<void> initialize() async {
    await Highlighter.initialize(['dart']);
    theme = await HighlighterTheme.loadLightTheme();
  }
}
