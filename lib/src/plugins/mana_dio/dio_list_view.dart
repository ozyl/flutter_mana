import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'response_item_widget.dart';

class DioListView extends StatelessWidget {
  final ScrollController scrollController;
  final String selectedMethod;
  final String filterKeywords;
  final bool filterEnabled;
  final VoidCallback onResponsesUpdated;

  const DioListView({
    super.key,
    required this.scrollController,
    required this.selectedMethod,
    required this.filterKeywords,
    required this.filterEnabled,
    required this.onResponsesUpdated,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ValueListenableBuilder<List<Response>>(
        valueListenable: ManaDioCollector().responses,
        builder: (context, responses, _) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onResponsesUpdated();
          });

          Iterable<Response> filteredByMethods = selectedMethod == 'All'
              ? responses
              : responses
                  .where((response) => response.requestOptions.method.toLowerCase() == selectedMethod.toLowerCase());

          final filteredResponses = (filterKeywords.isEmpty || !filterEnabled)
              ? filteredByMethods.toList()
              : filteredByMethods
                  .where((response) => response.requestOptions.uri.toString().contains(filterKeywords))
                  .toList();

          return ListView.separated(
            controller: scrollController,
            itemCount: filteredResponses.length,
            padding: const EdgeInsets.only(bottom: 20),
            itemBuilder: (context, index) {
              final response = filteredResponses[index];
              return ResponseItemWidget(response: response);
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
