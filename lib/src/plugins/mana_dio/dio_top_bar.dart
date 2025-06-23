import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

class DioTopBar extends StatelessWidget {
  final List<String> methods;
  final String selectedMethod;
  final ValueChanged<String> onMethodSelected;
  final bool filterEnabled;
  final VoidCallback onToggleFilter;

  const DioTopBar({
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
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 8),
              child: IconButton(
                onPressed: () {
                  ManaDioCollector().clear();
                },
                style: IconButton.styleFrom(
                  minimumSize: Size.zero,
                  padding: EdgeInsets.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                icon: const Icon(Icons.block_flipped, size: 16),
              ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: IconButton(
            onPressed: onToggleFilter,
            style: IconButton.styleFrom(
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              filterEnabled ? Icons.filter_alt_outlined : Icons.filter_alt_off_outlined,
              size: 16,
            ),
          ),
        ),
      ],
    );
  }
}
