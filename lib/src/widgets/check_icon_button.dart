import 'package:flutter/material.dart';

class CheckIconButton extends StatefulWidget {
  final IconData initialIcon;
  final IconData changedIcon;

  final double? size;
  final ButtonStyle? style;
  final VoidCallback? onPressed;

  const CheckIconButton(
      {super.key, required this.initialIcon, this.size, this.style, this.changedIcon = Icons.check, this.onPressed});

  @override
  State<CheckIconButton> createState() => _CheckIconButtonState();
}

class _CheckIconButtonState extends State<CheckIconButton> {
  bool _check = false;

  void _onPressed() {
    if (_check) {
      return;
    }
    setState(() {
      _check = true;
      widget.onPressed?.call();
    });
    Future.delayed(Duration(seconds: 2), () {
      if (mounted && _check) {
        setState(() => _check = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _check ? widget.changedIcon : widget.initialIcon,
        size: widget.size,
      ),
      style: widget.style,
      onPressed: _onPressed,
    );
  }
}
