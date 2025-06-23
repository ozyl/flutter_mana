import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ResponseItemWidget extends StatefulWidget {
  final Response response;

  const ResponseItemWidget({super.key, required this.response});

  @override
  State<ResponseItemWidget> createState() => _ResponseItemWidgetState();
}

class _ResponseItemWidgetState extends State<ResponseItemWidget> {
  @override
  Widget build(BuildContext context) {
    final Response response = widget.response;
    final RequestOptions requestOptions = response.requestOptions;

    // Get time info
    final DateTime? requestStartTime = requestOptions.extra['manaDioRequestStartTime'];
    final DateTime? requestEndTime = response.extra['manaDioRequestEndTime'];

    // Calc request duration
    Duration? duration;
    if (requestStartTime != null && requestEndTime != null) {
      duration = requestEndTime.difference(requestStartTime);
    }

    // Format request time
    String formattedRequestTime = requestStartTime != null
        ? '${requestStartTime.hour.toString().padLeft(2, '0')}:${requestStartTime.minute.toString().padLeft(2, '0')}:${requestStartTime.second.toString().padLeft(2, '0')}.${requestStartTime.millisecond.toString().padLeft(3, '0')}'
        : 'N/A';

    // Format response data (attempt to prettify JSON)
    String formattedResponseData = 'N/A';
    if (response.data != null) {
      try {
        formattedResponseData = JsonEncoder.withIndent('  ').convert(response.data);
      } catch (e) {
        formattedResponseData = response.data.toString();
      }
    }

    // Format request body
    String formattedRequestBody = 'N/A';
    if (requestOptions.data != null) {
      try {
        formattedRequestBody = JsonEncoder.withIndent('  ').convert(requestOptions.data);
      } catch (e) {
        formattedRequestBody = requestOptions.data.toString();
      }
    }

    return ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: _buildTitle(
        requestOptions.method,
        response.statusCode,
        requestOptions.uri.path,
        formattedRequestTime,
        duration,
      ),
      subtitle: _buildCollapsedSubtitle(formattedRequestTime, duration),
      enableFeedback: false,
      shape: const Border(),
      collapsedShape: const Border(),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Request Details'),
              _buildInfoRow('URL:', requestOptions.uri.toString()),
              _buildInfoRow('Time:', formattedRequestTime),
              _buildInfoRow('Method:', requestOptions.method),
              if (duration != null) _buildInfoRow('Duration:', '${duration.inMilliseconds} ms'),
              _buildSectionTitle('Request Headers'),
              _buildJsonDisplay(requestOptions.headers),
              if (requestOptions.data != null) ...[
                _buildSectionTitle('Request Body'),
                _buildCodeBlock(formattedRequestBody),
              ],
              _buildSectionTitle('Response Details'),
              _buildInfoRow('Code:', response.statusCode?.toString() ?? 'N/A'),
              _buildInfoRow('Message:', response.statusMessage ?? 'N/A'),
              _buildSectionTitle('Response Headers'),
              _buildJsonDisplay(response.headers.map),
              _buildSectionTitle('Response Data'),
              _buildCodeBlock(formattedResponseData),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(String method, int? statusCode, String path, String requestTime, Duration? duration) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Chip(
          label: Text(
            method,
            style: TextStyle(color: _getMethodColor(method), fontSize: 12, fontWeight: FontWeight.bold),
          ),
          backgroundColor: _getMethodColor(method).withAlpha(50),
          labelPadding: EdgeInsets.zero,
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          visualDensity: const VisualDensity(
            horizontal: VisualDensity.minimumDensity,
            vertical: VisualDensity.minimumDensity,
          ),
        ),
        const SizedBox(width: 8),
        if (statusCode != null)
          Chip(
            label: Text(
              statusCode.toString(),
              style: TextStyle(color: _getStatusCodeColor(statusCode), fontSize: 12, fontWeight: FontWeight.bold),
            ),
            backgroundColor: _getStatusCodeColor(statusCode).withAlpha(50),
            labelPadding: EdgeInsets.zero,
            side: BorderSide.none,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            visualDensity: const VisualDensity(
              horizontal: VisualDensity.minimumDensity,
              vertical: VisualDensity.minimumDensity,
            ),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            path,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCollapsedSubtitle(String requestTime, Duration? duration) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        'Time: $requestTime ${duration != null ? ' | Duration: ${duration.inMilliseconds} ms' : ''}',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonDisplay(Map<String, dynamic> data) {
    try {
      return Container(
        padding: const EdgeInsets.all(8.0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: SelectableText(
          JsonEncoder.withIndent('  ').convert(data),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      );
    } catch (e) {
      return SelectableText(
        data.toString(),
        style: const TextStyle(fontSize: 13, color: Colors.black87),
      );
    }
  }

  Widget _buildCodeBlock(String code) {
    if (code == 'N/A' || code.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Text('N/A', style: TextStyle(color: Colors.black87)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SelectableText(
          code,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusCodeColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return Colors.green;
    } else if (statusCode >= 300 && statusCode < 400) {
      return Colors.orange;
    } else if (statusCode >= 400 && statusCode < 500) {
      return Colors.red;
    } else if (statusCode >= 500) {
      return Colors.purple;
    }
    return Colors.grey;
  }
}
