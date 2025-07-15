import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

class ManaSettingPanel extends StatelessWidget {
  const ManaSettingPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 8,
        children: [
          _buildFabSizeSlider(context),
          _buildFabOpacitySlider(context),
        ],
      ),
    );
  }

  Widget _buildFabSizeSlider(BuildContext context) {
    final manaState = ManaManager.of(context);

    final size = manaState.floatActionButtonSize;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '浮动按钮大小',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${size.toStringAsFixed(0)}px',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: size,
          min: 40.0,
          max: 100.0,
          divisions: 6,
          padding: EdgeInsets.zero,
          label: size.toStringAsFixed(0),
          onChanged: (value) async {
            manaState.setFloatActionButtonSize(value);
            await ManaStore.instance.setManaState(manaState);
          },
        ),
      ],
    );
  }

  Widget _buildFabOpacitySlider(BuildContext context) {
    final manaState = ManaManager.of(context);

    final opacity = manaState.floatActionButtonOpacity;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '浮动按钮透明度',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${(opacity * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        Slider(
          value: opacity,
          min: 0.1,
          max: 1.0,
          divisions: 9,
          padding: EdgeInsets.zero,
          label: (opacity * 100).toStringAsFixed(0),
          onChanged: (value) async {
            manaState.setFloatActionButtonOpacity(value);
            await ManaStore.instance.setManaState(manaState);
          },
        ),
      ],
    );
  }
}
