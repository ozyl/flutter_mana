import 'dart:convert';
import 'dart:math';

import 'package:example/json_demo.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:logger/logger.dart';

/// 如果在发布模式下也想看到日志，需要使用自定义的filter，否则默认看不到
class ReleaseFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.value >= level!.value;
  }
}

/// 日志随机生成
class LogGenerator {
  static final Logger _logger = Logger(level: Level.all, filter: ReleaseFilter(), output: ManaLoggerCollector());
  static final Random _random = Random();

  // 随机日志级别和消息
  static void generateRandomLog() {
    // 随机日志级别
    final levels = [Level.debug, Level.info, Level.warning, Level.error];
    final level = levels[_random.nextInt(levels.length)];

    // 随机消息内容
    final messages = [
      "用户登录成功",
      "网络请求超时",
      "数据缓存失败",
      "权限请求被拒绝",
      "收到推送通知: ${_random.nextInt(1000)}",
      "页面跳转至 /settings",
      "数据库查询耗时 ${_random.nextInt(500)}ms",
      "内存使用量: ${_random.nextInt(80) + 20}%",
      "服务器响应错误: 404",
      "位置更新: (${_random.nextDouble() * 180 - 90}, ${_random.nextDouble() * 360 - 180})",
      jsonEncode(jsonDemo),
    ];
    final message = messages[_random.nextInt(messages.length)];

    // 添加随机错误堆栈
    final error = _random.nextBool() ? null : Exception("随机异常 ${_random.nextInt(100)}");
    final stackTrace = _random.nextDouble() > 0.8 ? StackTrace.current : null;

    // 打印日志
    _logger.log(level, message, error: error, stackTrace: stackTrace);
  }
}
