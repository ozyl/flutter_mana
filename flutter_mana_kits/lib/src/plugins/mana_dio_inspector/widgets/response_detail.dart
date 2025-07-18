import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana_kits/src/i18n/i18n_mixin.dart';

class ResponseDetail extends StatelessWidget with I18nMixin {
  final Response response;

  final VoidCallback? onClose;

  const ResponseDetail({super.key, required this.response, this.onClose});

  @override
  Widget build(BuildContext context) {
    final RequestOptions requestOptions = response.requestOptions;

    final DateTime? requestStartTime = requestOptions.extra['manaDioRequestStartTime'];
    final DateTime? requestEndTime = response.extra['manaDioRequestEndTime'];

    Duration duration = Duration.zero;
    if (requestStartTime != null && requestEndTime != null) {
      duration = requestEndTime.difference(requestStartTime);
    }

    String formattedRequestTime = requestStartTime != null
        ? '${requestStartTime.hour.toString().padLeft(2, '0')}:${requestStartTime.minute.toString().padLeft(2, '0')}:${requestStartTime.second.toString().padLeft(2, '0')}.${requestStartTime.millisecond.toString().padLeft(3, '0')}'
        : 'N/A';

    // 请求详情
    final Map<String, String> details = {
      'URL': requestOptions.uri.toString(),
      'Method': requestOptions.method.toString(),
      'Time': formattedRequestTime,
      'Duration': '${duration.inMilliseconds}ms',
      'Status': response.statusCode?.toString() ?? 'N/A',
      'Message': response.statusMessage ?? 'N/A',
    };

    // 请求头
    final Map<String, String> requestHeaders =
        requestOptions.headers.map((key, value) => MapEntry(key, value.toString()));

    // 请求体
    var requestBody = 'N/A';
    if (requestOptions.data != null) {
      try {
        requestBody = JsonEncoder.withIndent('  ').convert(requestOptions.data);
      } catch (e) {
        requestBody = requestOptions.data.toString();
      }
    }

    // 响应头
    final Map<String, String> responseHeaders =
        response.headers.map.map((key, value) => MapEntry(key, value.join(';')));

    // 响应体
    var responseBody = 'N/A';
    if (response.data != null) {
      try {
        responseBody = JsonEncoder.withIndent('  ').convert(response.data);
      } catch (e) {
        responseBody = response.data.toString();
      }
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.grey,
                  size: 16,
                ),
                onPressed: onClose,
              ),
              Expanded(
                child: Text(
                  requestOptions.uri.toString(),
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              CheckIconButton(
                initialIcon: Icons.copy,
                size: 16,
                iconColor: Colors.grey,
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: requestOptions.uri.toString()));
                },
              )
            ],
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          TabBar(
            tabs: [
              Tab(
                text: t('dio_inspector.detail'),
                height: 36,
              ),
              Tab(text: t('dio_inspector.request'), height: 36),
              Tab(text: t('dio_inspector.response'), height: 36),
            ],
            unselectedLabelColor: Colors.black45,
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 1.0,
            dividerHeight: 0,
            indicatorColor: Colors.transparent,
            labelPadding: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            labelStyle: const TextStyle(fontSize: 12),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
          Expanded(
            child: TabBarView(
              children: [
                _buildDetails(details),
                _buildRequestDetails(requestHeaders, requestBody),
                _buildResponseDetails(responseHeaders, responseBody),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTable(Map<String, String> data) {
    final children = data.entries.map(
      (row) {
        return TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Text(row.key, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),
            TableCell(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: SelectableText(row.value, style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        );
      },
    ).toList();

    return Table(
      border: TableBorder(
        verticalInside: BorderSide(color: Colors.grey.shade200),
        horizontalInside: BorderSide(color: Colors.grey.shade200),
        top: BorderSide(color: Colors.grey.shade200),
        bottom: BorderSide(color: Colors.grey.shade200),
      ),
      columnWidths: {
        0: FixedColumnWidth(120),
        1: FlexColumnWidth(),
      },
      children: children,
    );
  }

  Widget _buildCodeBlock(String code) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SelectableText(
        code,
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      ),
    );
  }

  // 构建详情
  Widget _buildDetails(Map<String, String> details) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Text(t('dio_inspector.request_details'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildTable(details),
        ],
      ),
    );
  }

  // 构建请求详情
  Widget _buildRequestDetails(Map<String, String> requestHeaders, String requestBody) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t('dio_inspector.request_header'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildTable(requestHeaders),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t('dio_inspector.request_body'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildCodeBlock(requestBody),
        ],
      ),
    );
  }

  // 构建响应详情
  Widget _buildResponseDetails(Map<String, String> responseHeaders, String responseBody) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child:
                Text(t('dio_inspector.response_header'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildTable(responseHeaders),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t('dio_inspector.response_body'), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildCodeBlock(responseBody),
        ],
      ),
    );
  }
}
