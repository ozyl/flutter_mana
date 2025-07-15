import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mana/flutter_mana.dart';

class ColorSuckerContent extends StatefulWidget {
  final Color color;
  final ValueChanged<double>? onMagnificationChanged;

  const ColorSuckerContent({
    super.key,
    required this.color,
    this.onMagnificationChanged,
  });

  @override
  State<ColorSuckerContent> createState() => _ColorSuckerContentState();
}

class _ColorSuckerContentState extends State<ColorSuckerContent> {
  late Color _color;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
  }

  @override
  void didUpdateWidget(covariant ColorSuckerContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      setState(() {
        _color = widget.color;
      });
    }
  }

  String get colorHex {
    if (_color == Colors.transparent) {
      return '#000000';
    }
    return '#${_color.toARGB32().toRadixString(16).substring(2)}';
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: colorHex));
  }

  double _zoomLevel = 10.0;
  final List<double> _zoomOptions = [10.0, 15.0, 20.0, 25.0, 30.0];

  @override
  Widget build(BuildContext context) {
    final platformDispatcher = View.of(context).platformDispatcher;
    final locale = platformDispatcher.locales.first;

    final magnificationText = locale.languageCode == 'zh' ? '放大率' : 'Magnification';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        spacing: 8,
        children: [
          Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _color == Colors.transparent ? Colors.black : _color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey,
                    width: 1,
                    style: BorderStyle.solid,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  colorHex,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              CheckIconButton(
                initialIcon: Icons.copy,
                onPressed: _copyToClipboard,
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text('$magnificationText: ${_zoomLevel}x', style: TextStyle(fontSize: 16)),
              Slider(
                padding: EdgeInsets.zero,
                value: _zoomLevel,
                min: _zoomOptions.first,
                max: _zoomOptions.last,
                divisions: _zoomOptions.length - 1, // 离散分段
                label: '${_zoomLevel}x',
                onChanged: (value) {
                  // 吸附到最近的预设值（可选）
                  _zoomLevel = _zoomOptions.reduce((a, b) => (value - a).abs() < (value - b).abs() ? a : b);
                  widget.onMagnificationChanged?.call(_zoomLevel);
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
