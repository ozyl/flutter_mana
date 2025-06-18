import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:logger/logger.dart';

import 'icon.dart';
import 'log_item_widget.dart';

class ManaLogger extends StatefulWidget implements ManaPluggable {
  const ManaLogger({super.key});

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
  // 滚动控制器，用于滚动到最新日志
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // 滚动到底部的方法
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  String _selectedLevel = 'All';
  List<String> levels = ['All', 'Debug', 'Info', 'Warning', 'Error'];

  @override
  Widget build(BuildContext context) {
    return ManaFloatingWindow(
        name: 'mana_logger',
        showModal: false,
        initialWidth: double.infinity,
        position: PositionType.bottom,
        drag: false,
        body: Column(
          children: [
            Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: IconButton(
                    onPressed: () {
                      ManaLoggerCollector().clear();
                    },
                    style: IconButton.styleFrom(
                      minimumSize: Size.zero,
                      padding: EdgeInsets.only(left: 16, right: 8),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(Icons.block_flipped, size: 16),
                  ),
                ),
                for (final level in levels)
                  FilterChip(
                    showCheckmark: false,
                    side: BorderSide.none,
                    backgroundColor: Colors.white,
                    selectedColor: Colors.grey[200],
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    // 内容内边距
                    labelPadding: EdgeInsets.zero,
                    // 标签内边距
                    visualDensity: VisualDensity.compact,
                    selected: _selectedLevel == level,
                    label: Text(
                      level,
                      style: TextStyle(fontSize: 12),
                    ),
                    onSelected: (_) {
                      setState(() {
                        _selectedLevel = level;
                      });
                    },
                  ),
              ],
            ),
            Divider(
              height: 1,
              color: Colors.grey[200],
            ),
            Expanded(
              child: ValueListenableBuilder<List<OutputEvent>>(
                valueListenable: ManaLoggerCollector().logs,
                builder: (context, logs, _) {
                  // 在日志更新时尝试滚动到底部
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottom();
                  });

                  final filteredLogs = _selectedLevel == 'All'
                      ? logs
                      : logs.where((log) => log.level.name.toLowerCase() == _selectedLevel.toLowerCase()).toList();

                  return ListView.separated(
                    controller: _scrollController,
                    itemCount: filteredLogs.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      final logEvent = filteredLogs[index];
                      // 渲染日志内容
                      return LogItemWidget(index: index, log: logEvent);
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
            ),
          ],
        ));
  }
}
