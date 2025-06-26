import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 可展开的 SelectableText，当文本过长时省略并显示“展开”
class ExpandableSelectableText extends StatefulWidget {
  final String text;
  final int trimLength;

  const ExpandableSelectableText({
    super.key,
    required this.text,
    this.trimLength = 30,
  });

  @override
  State<ExpandableSelectableText> createState() => _ExpandableSelectableTextState();
}

class _ExpandableSelectableTextState extends State<ExpandableSelectableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final shouldTrim = widget.text.length > widget.trimLength;

    // 已展开 或 文本不需要折叠，直接显示全文
    if (_expanded || !shouldTrim) {
      return ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 300,
        ),
        child: SelectableText(widget.text),
      );
    }

    final displayText = widget.text.substring(0, widget.trimLength);

    // 使用 RichText + TapGestureRecognizer 实现“展开”点击
    return SelectableText.rich(
      TextSpan(
        text: displayText,
        style: const TextStyle(color: Colors.black),
        children: [
          const TextSpan(text: '...'),
          TextSpan(
            text: ' 更多',
            style: const TextStyle(color: Colors.blue),
            recognizer: TapGestureRecognizer()..onTap = () => setState(() => _expanded = true),
          ),
        ],
      ),
    );
  }
}
