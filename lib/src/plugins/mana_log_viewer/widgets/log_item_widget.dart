import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:logger/logger.dart';

class LogItemWidget extends StatefulWidget {
  final int index;
  final OutputEvent log;

  const LogItemWidget({super.key, required this.index, required this.log});

  @override
  State<LogItemWidget> createState() => _LogItemWidgetState();
}

class _LogItemWidgetState extends State<LogItemWidget> {
  bool _expanded = false;

  static const maxLength = 160;

  @override
  Widget build(BuildContext context) {
    final timeStr = widget.log.origin.time.toIso8601String().split('T')[1];

    var message = widget.log.origin.message.toString();

    if (widget.log.origin.error != null) {
      message += '\n--------------- error ---------------\n${widget.log.origin.error.toString()}';
    }
    if (widget.log.origin.stackTrace != null) {
      message += '\n--------------- stackTrace ---------------\n${widget.log.origin.stackTrace.toString()}';
    }

    message = message.trim();

    final showContent = _expanded || message.length < maxLength;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    widget.log.origin.level.name.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _levelColor(widget.log.level),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(timeStr, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(width: 8),
                  Text('#${widget.index}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (message.length >= maxLength)
                    IconButton(
                      icon: Icon(
                        _expanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: EdgeInsets.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {
                        setState(() {
                          _expanded = !_expanded;
                        });
                      },
                    ),
                  const SizedBox(width: 12),
                  CheckIconButton(
                    initialIcon: Icons.copy,
                    size: 14,
                    style: IconButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: message),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            showContent ? message : "${message.substring(0, maxLength)}...",
            style: const TextStyle(fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Color _levelColor(Level level) {
    switch (level) {
      case Level.debug:
        return Colors.green;
      case Level.info:
        return Colors.blue;
      case Level.warning:
        return Colors.orange;
      case Level.error:
        return Colors.red;
      default:
        return Colors.black;
    }
  }
}
