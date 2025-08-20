import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'storage_viewer_content.dart';
class StorageViewer extends StatelessWidget {
  final String name;

  const StorageViewer({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: name,
      initialWidth: double.infinity,
      position: PositionType.bottom,
      drag: false,
      showBarrier: false,
      content: StorageViewerContent(),
    );
  }
}
