import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_mana_kits/flutter_mana_kits.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();

  late final Dio _dio;

  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  DioClient._internal() {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));

    _dio.interceptors.add(ManaDioCollector());
  }

  factory DioClient() => _instance;

  Future<Response> _getRequest() async {
    return await _dio.get('/posts/1');
  }

  Future<Response> _postRequest() async {
    return await _dio.post('/posts', data: {'title': 'foo', 'body': 'bar', 'userId': 1});
  }

  Future<Response> _putRequest() async {
    return await _dio.put('/posts/1', data: {'id': 1, 'title': 'updated title', 'body': 'updated body', 'userId': 1});
  }

  Future<Response> _deleteRequest() async {
    return await _dio.delete('/posts/1');
  }

  Future<Response> randomRequest() async {
    final random = Random();
    final method = random.nextInt(4);

    switch (method) {
      case 1:
        print('执行POST请求');
        return await _postRequest();
      case 2:
        print('执行PUT请求');
        return await _putRequest();
      case 3:
        print('执行DELETE请求');
        return await _deleteRequest();
      default:
        return await _getRequest();
    }
  }
}
