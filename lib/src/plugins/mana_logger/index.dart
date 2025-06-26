import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'filter_input.dart';
import 'icon.dart';
import 'log_list_view.dart';
import 'top_bar.dart';

class ManaLogger extends StatefulWidget implements ManaPluggable {
  ManaLogger({super.key}) {
    ManaLoggerCollector.redirectDebugPrint();
  }

  @override
  State<ManaLogger> createState() => _ManaLoggerState();

  @override
  Widget? buildWidget(BuildContext? context) => this;

  @override
  String getLocalizedDisplayName(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return '日志查看器';
      default:
        return 'Logger Viewer';
    }
  }

  @override
  ImageProvider<Object> get iconImageProvider => iconImage;

  @override
  String get name => 'mana_logger';

  @override
  void onTrigger() {}
}

class _ManaLoggerState extends State<ManaLogger> {
  final ScrollController _scrollController = ScrollController();
  String _selectedLevel = 'All';
  bool _filter = false;
  String _filterKeywords = '';

  final List<String> _levels = ['All', 'Debug', 'Info', 'Warning', 'Error'];

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

  void _onLevelSelected(String level) {
    setState(() {
      _selectedLevel = level;
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
      header: Column(
        children: [
          Divider(height: 1, color: Colors.grey[200]),
          TopBar(
            levels: _levels,
            selectedLevel: _selectedLevel,
            onLevelSelected: _onLevelSelected,
            filterEnabled: _filter,
            onToggleFilter: _toggleFilterVisibility,
          ),
          if (_filter) ...[
            Divider(height: 1, color: Colors.grey[200]),
            FilterInput(
              onFilterKeywordsChanged: _onFilterKeywordsChanged,
            ),
          ],
          Divider(height: 1, color: Colors.grey[200]),
        ],
      ),
      body: Column(
        children: [
          LogListView(
            scrollController: _scrollController,
            selectedLevel: _selectedLevel,
            filterKeywords: _filterKeywords,
            filterEnabled: _filter,
            onLogsUpdated: _scrollToBottom,
          ),
        ],
      ),
    );
  }
}
