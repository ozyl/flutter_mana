import 'package:flutter/material.dart';

class GridContent extends StatefulWidget {
  final ValueChanged<bool>? onShowNumbers;
  final ValueChanged<double>? onStepChanged;

  const GridContent({super.key, this.onShowNumbers, this.onStepChanged});

  @override
  State<GridContent> createState() => _GridContentState();
}

class _GridContentState extends State<GridContent> {
  bool _showNumbers = true;

  double _step = 50;
  final List<double> _stepOptions = List.generate(
    20,
    (index) => (index + 1) * 10,
  );

  void _onShowNumbersChanged(bool value) {
    widget.onShowNumbers?.call(value);
    setState(() {
      _showNumbers = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        spacing: 8,
        children: [
          Row(
            spacing: 8,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Switch(
                value: _showNumbers,
                onChanged: _onShowNumbersChanged,
                activeColor: Colors.red,
              ),
              Expanded(
                child: Text(
                  'Show Numbers',
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text('Step: ${_step.toInt()}px', style: TextStyle(fontSize: 16)),
              Slider(
                padding: EdgeInsets.zero,
                value: _step,
                min: _stepOptions.first,
                max: _stepOptions.last,
                divisions: _stepOptions.length - 1,
                label: '${_step.toInt()}px',
                onChanged: (value) {
                  // 吸附到最近的预设值（可选）
                  _step = _stepOptions.reduce((a, b) => (value - a).abs() < (value - b).abs() ? a : b);
                  widget.onStepChanged?.call(_step);
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
