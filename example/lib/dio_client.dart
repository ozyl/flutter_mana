import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_mana/flutter_mana.dart';

class DioClient {
  // 单例实例
  static final DioClient _instance = DioClient._internal();

  // Dio 实例
  late final Dio _dio;

  // 基础URL
  final String _baseUrl = 'https://jsonplaceholder.typicode.com';

  // 私有构造函数
  DioClient._internal() {
    _dio = Dio(BaseOptions(baseUrl: _baseUrl));

    // 可以在这里添加拦截器
    _dio.interceptors.add(ManaDioCollector());
  }

  // 获取单例
  factory DioClient() => _instance;

  // 私有GET请求方法
  Future<Response> _getRequest() async {
    return await _dio.get('/posts/1');
  }

  // 私有POST请求方法
  Future<Response> _postRequest() async {
    return await _dio.post('/posts', data: {'title': 'foo', 'body': 'bar', 'userId': 1});
  }

  // 私有PUT请求方法
  Future<Response> _putRequest() async {
    return await _dio.put('/posts/1', data: {'id': 1, 'title': 'updated title', 'body': 'updated body', 'userId': 1});
  }

  // 私有DELETE请求方法
  Future<Response> _deleteRequest() async {
    return await _dio.delete('/posts/1');
  }

  // 对外公开的随机请求方法
  Future<Response> randomRequest() async {
    final random = Random();
    final method = random.nextInt(4); // 生成0-3的随机数

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
        return await _getRequest(); // 默认GET
    }
  }
}
