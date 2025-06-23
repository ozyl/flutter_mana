import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ManaDioCollector implements Interceptor {
  static final ManaDioCollector _instance = ManaDioCollector._internal();

  factory ManaDioCollector() => _instance;

  ManaDioCollector._internal();

  static const int _maxResponses = 1000;

  final ValueNotifier<List<Response>> responses = ValueNotifier(<Response>[]);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['manaDioRequestStartTime'] = DateTime.now();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    addResponse(response);
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      addResponse(err.response!);
    }
    handler.next(err);
  }

  void addResponse(Response response) {
    response.extra['manaDioRequestEndTime'] = DateTime.now();
    final updated = List<Response>.from(responses.value)..add(response);
    if (updated.length > _maxResponses) {
      updated.removeAt(0);
    }
    responses.value = updated;
  }

  void clear() {
    responses.value = <Response>[];
  }
}
