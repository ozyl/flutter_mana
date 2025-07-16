import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'log_viewer_content.dart';

class LogViewer extends StatelessWidget {
  final String name;

  const LogViewer({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: name,
      showBarrier: false,
      initialWidth: double.infinity,
      position: PositionType.bottom,
      drag: false,
      content: LogViewerContent(),
    );
  }
}
