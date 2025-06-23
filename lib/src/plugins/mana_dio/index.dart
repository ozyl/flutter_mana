import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana/src/plugins/mana_dio/dio_list_view.dart';
import 'package:flutter_mana/src/plugins/mana_dio/dio_top_bar.dart';

import 'dio_filter_input.dart';
import 'icon.dart';

class ManaDio extends StatefulWidget implements ManaPluggable {
  const ManaDio({super.key});

  @override
  State<ManaDio> createState() => _ManaDioState();

  @override
  Widget? buildWidget(BuildContext? context) => this;

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return 'Dio网络检查器';
      default:
        return 'Dio Inspector';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_dio';

  @override
  void onTrigger() {}
}

class _ManaDioState extends State<ManaDio> {
  final ScrollController _scrollController = ScrollController();
  String _selectedMethod = 'All';
  bool _filter = false;
  String _filterKeywords = '';

  final List<String> _methods = ['All', 'Get', 'Post', 'Put', 'Delete'];

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    final double currentPosition = _scrollController.position.pixels;
    final double maxScroll = _scrollController.position.maxScrollExtent;
    if (_scrollController.hasClients && (maxScroll - currentPosition <= 200)) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _onMethodSelected(String method) {
    setState(() {
      _selectedMethod = method;
    });
  }

  void _toggleFilterVisibility() {
    setState(() {
      _filter = !_filter;
    });
  }

  void _onFilterKeywordsChanged(String keywords) {
    setState(() {
      _filterKeywords = keywords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
      name: widget.name,
      showModal: false,
      initialWidth: double.infinity,
      position: PositionType.bottom,
      drag: false,
      body: Column(
        children: [
          Divider(height: 1, color: Colors.grey[200]),
          DioTopBar(
            methods: _methods,
            selectedMethod: _selectedMethod,
            onMethodSelected: _onMethodSelected,
            filterEnabled: _filter,
            onToggleFilter: _toggleFilterVisibility,
          ),
          if (_filter) ...[
            Divider(height: 1, color: Colors.grey[200]),
            DioFilterInput(
              onFilterKeywordsChanged: _onFilterKeywordsChanged,
            ),
          ],
          Divider(height: 1, color: Colors.grey[200]),
          DioListView(
            scrollController: _scrollController,
            selectedMethod: _selectedMethod,
            filterKeywords: _filterKeywords,
            filterEnabled: _filter,
            onResponsesUpdated: _scrollToBottom,
          )
        ],
      ),
    );
  }
}
