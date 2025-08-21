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
  double _gap = 50;
  bool _showNumbers = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _gap = await ManaStore.instance.storageProvider.getValue('mana_grid_gap') as double? ?? 50;
    _showNumbers = await ManaPluginManager.instance.storageProvider.getValue('mana_grid_show_numbers') as bool? ?? true;
    setState(() {});
  }

  void _onGapChanged(double value) async {
    _gap = value;
    await ManaStore.instance.storageProvider.setValue('mana_grid_gap', value);
    setState(() {});
  }

  void _onShowNumbersChanged(bool value) async {
    _showNumbers = value;
    await ManaPluginManager.instance.storageProvider.setValue('mana_grid_show_numbers', value);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: widget.name,
      initialHeight: 180,
      content: GridContent(
        gap: _gap,
        showNumbers: _showNumbers,
        onGapChanged: _onGapChanged,
        onShowNumbersChanged: _onShowNumbersChanged,
      ),
      barrier: GridBarrier(
        gap: _gap,
        showNumbers: _showNumbers,
      ),
    );
  }
}
