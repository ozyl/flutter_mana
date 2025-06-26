import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  final bool filterEnabled;
  final VoidCallback? onClear;
  final VoidCallback? onToggleFilter;
  final VoidCallback? onRefresh;

  const TopBar({
    super.key,
    this.filterEnabled = false,
    this.onClear,
    this.onToggleFilter,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: onClear,
              icon: const Icon(Icons.block_flipped, size: 16),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: onRefresh,
              icon: Icon(
                Icons.refresh_outlined,
                size: 16,
              ),
            ),
            IconButton(
              onPressed: onToggleFilter,
              icon: Icon(
                filterEnabled ? Icons.filter_alt_outlined : Icons.filter_alt_off_outlined,
                size: 16,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
