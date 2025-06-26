import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

class TopBar extends StatelessWidget {
  final List<String> methods;
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;
  final bool filterEnabled;
  final VoidCallback onToggleFilter;

  const TopBar({
    super.key,
    required this.methods,
    required this.selectedMethod,
    required this.onMethodSelected,
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
                ManaDioCollector().clear();
              },
              icon: const Icon(Icons.block_flipped, size: 16),
            ),
            for (final method in methods)
              FilterChip(
                showCheckmark: false,
                side: BorderSide.none,
                backgroundColor: Colors.white,
                selectedColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(horizontal: 8),
                labelPadding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                selected: selectedMethod == method,
                label: Text(
                  method,
                  style: const TextStyle(fontSize: 12),
                ),
                onSelected: (_) => onMethodSelected(method),
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
