import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana/src/plugins/mana_shared_preferences_viewer/widgets/shared_preferences_viewer_content.dart';

class SharedPreferencesViewer extends StatelessWidget {
  final String name;

  const SharedPreferencesViewer({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: name,
      initialWidth: double.infinity,
      position: PositionType.bottom,
      drag: false,
      showBarrier: false,
      content: SharedPreferencesViewerContent(),
    );
  }
}
