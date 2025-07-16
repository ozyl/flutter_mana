import 'dart:async';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../mana_log_collector.dart';
import 'log_item_widget.dart';

class LogViewerContent extends StatefulWidget {
  const LogViewerContent({super.key});

  @override
  State<LogViewerContent> createState() => _LogViewerContentState();
}

class _LogViewerContentState extends State<LogViewerContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _filterController = TextEditingController();
  Timer? _debounceTimer;

  final ScrollController _scrollController = ScrollController();

  final List<String> _tabs = ['All', 'Debug', 'Info', 'Warning', 'Error'];

  String _currentTab = 'All';

  /// 是否启用过滤
  bool _filter = false;

  /// 过滤关键字词
  String _filterKeywords = '';

  // 统一的字体大小
  static const double _fontSize = 12.0;
  // 分割线颜色
  static final Color _dividerColor = Colors.grey.shade200;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _filterController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _filterController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      if (!mounted) {
        return;
      }
      setState(() {
        _currentTab = _tabs[_tabController.index];
      });
    }
  }

  void _onTextChanged() {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _filterKeywords = _filterController.text;
      });
    });
  }

  /// 清空
  void _clear() {
    ManaLogCollector().clear();
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 滚动到顶部
  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  /// 开关过滤
  void _toggleFilter() {
    setState(() {
      _filter = !_filter;
    });
  }

  /// 创建顶部区域
  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: false,
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black45,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorWeight: 1.0,
        indicatorColor: Colors.transparent,
        dividerHeight: 0,
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        labelStyle: const TextStyle(fontSize: _fontSize),
        tabs: _tabs
            .map(
              (tab) => Tab(text: tab, height: 36),
            )
            .toList(),
      ),
    );
  }

  /// 创建中间内容区域
  Widget _buildCenter() {
    return Expanded(
      child: ValueListenableBuilder(
          valueListenable: ManaLogCollector().logs,
          builder: (context, logs, child) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });

            Iterable<OutputEvent> filteredByTab = _currentTab == 'All'
                ? logs
                : logs.where((log) => log.level.name.toLowerCase() == _currentTab.toLowerCase());

            final filteredLogs = (_filterKeywords.isEmpty || !_filter)
                ? filteredByTab.toList()
                : filteredByTab.where((log) => log.origin.message.toString().contains(_filterKeywords)).toList();

            return ListView.separated(
              controller: _scrollController,
              itemCount: filteredLogs.length,
              padding: const EdgeInsets.only(bottom: 20),
              itemBuilder: (context, index) {
                final logEvent = filteredLogs[index];
                return LogItemWidget(index: index, log: logEvent);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: 1,
                  color: Colors.grey[200],
                );
              },
            );
          }),
    );
  }

  /// 创建底部操作栏
  Widget _buildBottom() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        children: [
          if (_filter) ...[
            TextField(
              controller: _filterController,
              style: const TextStyle(fontSize: _fontSize),
              decoration: InputDecoration(
                hintText: 'filter keywords...',
                hintStyle: TextStyle(fontSize: _fontSize, color: Colors.black54),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            Divider(height: 1, color: _dividerColor),
          ],
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double buttonWidth = constraints.maxWidth / 4;

              return ToggleButtons(
                isSelected: [false, false, false, false],
                renderBorder: false,
                constraints: BoxConstraints(minHeight: 36.0, minWidth: buttonWidth),
                textStyle: const TextStyle(fontSize: _fontSize),
                onPressed: (int index) {
                  switch (index) {
                    case 0:
                      _clear();
                      return;
                    case 1:
                      _scrollToTop();
                      return;
                    case 2:
                      _scrollToBottom();
                      return;
                    case 3:
                      _toggleFilter();
                      return;
                  }
                },
                children: [
                  Center(child: Text('Clear')),
                  Center(child: Text('Top')),
                  Center(child: Text('Bottom')),
                  Center(child: Text(_filter ? 'Filter(on)' : 'Filter(off)')),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: _dividerColor),
        _buildHeader(),
        Divider(height: 1, color: _dividerColor),
        _buildCenter(),
        Divider(height: 1, color: _dividerColor),
        _buildBottom(),
      ],
    );
  }
}
