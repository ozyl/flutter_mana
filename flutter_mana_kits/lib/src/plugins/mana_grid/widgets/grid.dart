import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'grid_barrier.dart';
import 'grid_content.dart';

class Grid extends StatefulWidget {
  final String name;

  const Grid({super.key, required this.name});

  @override
  State<Grid> createState() => _GridState();
}

class _GridState extends State<Grid> {
  double step = 50;
  bool showNumbers = true;

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: widget.name,
      initialHeight: 180,
      position: PositionType.top,
      content: GridContent(
        onStepChanged: (value) {
          setState(() {
            step = value;
          });
        },
        onShowNumbers: (value) {
          setState(() {
            showNumbers = value;
          });
        },
      ),
      barrier: GridBarrier(
        step: step,
        showNumbers: showNumbers,
      ),
    );
  }
}
