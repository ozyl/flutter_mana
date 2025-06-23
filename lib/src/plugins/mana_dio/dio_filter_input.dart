import 'dart:async';

import 'package:flutter/material.dart';

class DioFilterInput extends StatefulWidget {
  final ValueChanged<String> onFilterKeywordsChanged;

  const DioFilterInput({super.key, required this.onFilterKeywordsChanged});

  @override
  State<DioFilterInput> createState() => _DioFilterInputState();
}

class _DioFilterInputState extends State<DioFilterInput> {
  final TextEditingController _textController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      widget.onFilterKeywordsChanged(_textController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(
        hintText: 'Filter path',
        hintStyle: TextStyle(color: Colors.grey),
        border: InputBorder.none,
        focusedBorder: InputBorder.none,
        enabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        hoverColor: Colors.white,
        focusColor: Colors.white,
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 12),
      ),
    );
  }
}
