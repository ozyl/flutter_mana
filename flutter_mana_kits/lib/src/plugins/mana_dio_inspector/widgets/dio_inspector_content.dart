import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../mana_dio_collector.dart';
import 'response_detail.dart';
import 'response_tile.dart';

class DioInspectorContent extends StatefulWidget {
  const DioInspectorContent({super.key});

  @override
  State<DioInspectorContent> createState() => _DioInspectorContentState();
}

class _DioInspectorContentState extends State<DioInspectorContent> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final TextEditingController _filterController = TextEditingController();
  Timer? _debounceTimer;

  final ScrollController _scrollController = ScrollController();

  final List<String> _tabs = ['All', 'Get', 'Post', 'Put', 'Delete'];

  String _currentTab = 'All';

  /// 是否启用过滤
  bool _filter = false;

  /// 过滤关键字词
  String _filterKeywords = '';

  /// 当前需要查看的response详情
  Response? _response;

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

  void _clear() {
    ManaDioCollector().clear();
  }

  /// 滚动到底部
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      final double threshold = 140;
      if (_scrollController.position.pixels + threshold < _scrollController.position.maxScrollExtent) {
        // 滚动条未在底部，则不进行滚动
        return;
      }

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
        indicatorColor: Colors.transparent,
        indicatorWeight: 1.0,
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

  /// 创建中部区域
  Widget _buildCenter() {
    return Expanded(
      child: Stack(
        children: [
          ValueListenableBuilder(
            valueListenable: ManaDioCollector().responses,
            builder: (context, responses, child) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              Iterable<Response> filteredByTab = _currentTab == 'All'
                  ? responses
                  : responses
                      .where((response) => response.requestOptions.method.toLowerCase() == _currentTab.toLowerCase());

              final filteredResponses = (_filterKeywords.isEmpty || !_filter)
                  ? filteredByTab.toList()
                  : filteredByTab
                      .where((response) => response.requestOptions.uri.toString().contains(_filterKeywords))
                      .toList();

              return ListView.separated(
                controller: _scrollController,
                itemCount: filteredResponses.length,
                padding: const EdgeInsets.only(bottom: 20),
                itemBuilder: (context, index) {
                  final response = filteredResponses[index];
                  return ResponseTile(
                    response: response,
                    onTap: () {
                      setState(() {
                        _response = response;
                      });
                    },
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Divider(
                    height: 1,
                    color: Colors.grey[200],
                  );
                },
              );
            },
          ),
          if (_response != null)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.white,
              child: ResponseDetail(
                response: _response!,
                onClose: () {
                  setState(() {
                    _response = null;
                  });
                },
              ),
            )
        ],
      ),
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
        if (_response == null) ...[
          Divider(height: 1, color: _dividerColor),
          _buildHeader(),
        ],
        Divider(height: 1, color: _dividerColor),
        _buildCenter(),
        if (_response == null) ...[
          Divider(height: 1, color: _dividerColor),
          _buildBottom(),
        ],
      ],
    );
  }
}
