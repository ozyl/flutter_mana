import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'log_item_widget.dart';
import 'mana_logger_collector.dart';

class LoggerListView extends StatelessWidget {
  final ScrollController scrollController;
  final String selectedLevel;
  final String filterKeywords;
  final bool filterEnabled;
  final VoidCallback onLogsUpdated;

  const LoggerListView({
    super.key,
    required this.scrollController,
    required this.selectedLevel,
    required this.filterKeywords,
    required this.filterEnabled,
    required this.onLogsUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<OutputEvent>>(
        valueListenable: ManaLoggerCollector().logs,
        builder: (context, logs, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLogsUpdated();
          });

          Iterable<OutputEvent> filteredByLevel = selectedLevel == 'All'
              ? logs
              : logs.where((log) => log.level.name.toLowerCase() == selectedLevel.toLowerCase());

          final filteredLogs = (filterKeywords.isEmpty || !filterEnabled)
              ? filteredByLevel.toList()
              : filteredByLevel.where((log) => log.origin.message.toString().contains(filterKeywords)).toList();

          return ListView.separated(
            controller: scrollController,
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
        },
      ),
    );
  }
}
