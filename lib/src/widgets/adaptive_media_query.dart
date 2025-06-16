import 'dart:async';

import 'package:flutter/material.dart';

/// 自适应 MediaQuery 组件，
/// 仅在窗口尺寸发生变化时更新 MediaQuery 数据，并支持防抖处理。
///
/// 用法：
/// ```dart
/// AdaptiveMediaQuery(
///   child: YourWidget(),
/// )
/// ```
///
/// 推荐用于 Web/桌面/多窗口等需要监听并响应窗口动态变化的场景。
class AdaptiveMediaQuery extends StatefulWidget {
  /// 需要自适应 MediaQuery 的子组件
  final Widget child;

  /// 构造函数
  const AdaptiveMediaQuery({super.key, required this.child});

  @override
  State<AdaptiveMediaQuery> createState() => _AdaptiveMediaQueryState();
}

class _AdaptiveMediaQueryState extends State<AdaptiveMediaQuery> with WidgetsBindingObserver {
  // 当前的媒体查询数据
  late MediaQueryData _mediaQueryData;

  // 防抖定时器
  Timer? _debounceTimer;

  // 防抖等待时间
  static const Duration _debounceDuration = Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    // 注册窗口变化监听
    WidgetsBinding.instance.addObserver(this);
    // 注意：不能在这里初始化 _mediaQueryData，因为此时无法安全访问 context
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 在这里初始化 MediaQueryData，保证可以安全访问 context
    _mediaQueryData = MediaQuery.of(context);
  }

  @override
  void dispose() {
    // 注销监听，释放 timer
    WidgetsBinding.instance.removeObserver(this);
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    // 窗口变化时，重置定时器，等待一段时间后（防抖）再实际刷新
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      // 用于防止 context 失效，可以加 mounted 判断
      if (!mounted) return;
      final newData = MediaQuery.of(context);
      // 仅在尺寸等实际变化时才刷新
      if (_mediaQueryData.size != newData.size ||
          _mediaQueryData.devicePixelRatio != newData.devicePixelRatio ||
          _mediaQueryData.orientation != newData.orientation) {
        setState(() {
          _mediaQueryData = newData;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 首次 build 或父级变动时及时同步最新 MediaQuery 数据
    final latestData = MediaQuery.of(context);
    if (_mediaQueryData.size != latestData.size ||
        _mediaQueryData.devicePixelRatio != latestData.devicePixelRatio ||
        _mediaQueryData.orientation != latestData.orientation) {
      _mediaQueryData = latestData;
    }
    return MediaQuery(
      data: _mediaQueryData,
      child: widget.child,
    );
  }
}
