import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ColorToolPanel extends StatefulWidget {
  /// 初始颜色
  final Color color;

  const ColorToolPanel({
    super.key,
    required this.color,
  });

  @override
  State<ColorToolPanel> createState() => _ColorToolPanelState();
}

class _ColorToolPanelState extends State<ColorToolPanel> {
  late Color _color;

  bool _copied = false;

  @override
  void initState() {
    super.initState();
    _color = widget.color;
  }

  @override
  void didUpdateWidget(covariant ColorToolPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      setState(() {
        _color = widget.color;
      });
    }
  }

  String get colorHex => '#${_color.toARGB32().toRadixString(16).substring(2)}';

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: colorHex));
    _copied = true;
    setState(() {});
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && _copied) {
        setState(() => _copied = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),
          // Color hex text
          Expanded(
            child: Text(
              colorHex,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Copy button
          IconButton(
            icon: Icon(
              _copied ? Icons.check : Icons.copy,
            ),
            onPressed: _copyToClipboard,
          )
        ],
      ),
    );
  }
}
