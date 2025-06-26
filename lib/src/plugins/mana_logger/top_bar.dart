import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'mana_logger_collector.dart';

class TopBar extends StatelessWidget {
  final List<String> levels;
  final String selectedLevel;
  final ValueChanged<String> onLevelSelected;
  final bool filterEnabled;
  final VoidCallback onToggleFilter;

  const TopBar({
    super.key,
    required this.levels,
    required this.selectedLevel,
    required this.onLevelSelected,
    required this.filterEnabled,
    required this.onToggleFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                ManaLoggerCollector().clear(); // Clear logs using the collector
              },
              icon: const Icon(Icons.block_flipped, size: 16),
            ),
            for (final level in levels)
              FilterChip(
                showCheckmark: false,
                side: BorderSide.none,
                backgroundColor: Colors.white,
                selectedColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 8),
                labelPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                selected: selectedLevel == level,
                label: Text(
                  level,
                  style: const TextStyle(fontSize: 12),
                ),
                onSelected: (_) => onLevelSelected(level),
              ),
          ],
        ),
        IconButton(
          onPressed: onToggleFilter,
          icon: Icon(
            filterEnabled ? Icons.filter_alt_outlined : Icons.filter_alt_off_outlined,
            size: 16,
          ),
        ),
      ],
    );
  }
}
