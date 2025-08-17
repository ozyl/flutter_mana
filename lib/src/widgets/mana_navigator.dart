import 'package:flutter/material.dart';

/// Global navigator key for managing navigation state within Mana plugins.
///
/// 全局导航器键，用于管理 Mana 插件内部的导航状态。
final GlobalKey<NavigatorState> manaNavigatorKey = GlobalKey();

/// A custom navigator widget that provides navigation capabilities for Mana plugins.
///
/// 为 Mana 插件提供导航功能的自定义导航器组件。
class ManaNavigator extends StatefulWidget {
  /// Creates a [ManaNavigator] with the specified child widget.
  ///
  /// 创建一个 [ManaNavigator]，包含指定的子组件。
  const ManaNavigator({super.key, required this.child});

  /// The child widget to be displayed within the navigator.
  ///
  /// 在导航器中显示的子组件。
  final Widget child;

  @override
  State<ManaNavigator> createState() => _ManaNavigatorState();
}

/// The state class for [ManaNavigator].
///
/// [ManaNavigator] 的状态类。
class _ManaNavigatorState extends State<ManaNavigator> {
  /// Indicates whether the navigator can pop the current route.
  ///
  /// 指示导航器是否可以弹出当前路由。
  bool canPop = false;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: manaNavigatorKey,
      onDidRemovePage: (page) {},
      observers: [
        // Custom navigator observer to track navigation changes
        // 自定义导航器观察者，用于跟踪导航变化
        _ManaNavObserver(onChanged: () {
          // Use post frame callback to ensure the context is still valid
          // 使用后帧回调确保上下文仍然有效
          WidgetsBinding.instance.addPostFrameCallback((_) {
            setState(() {
              canPop = Navigator.maybeOf(context)?.canPop() == false;
            });
          });
        })
      ],
      onGenerateRoute: (settings) {
        // Always return the child widget as the route
        // 始终返回子组件作为路由
        return MaterialPageRoute(builder: (_) => widget.child);
      },
    );
  }
}

/// A custom navigator observer that notifies when navigation events occur.
///
/// 自定义导航器观察者，当导航事件发生时进行通知。
class _ManaNavObserver extends NavigatorObserver {
  /// Creates a [_ManaNavObserver] with the specified callback.
  ///
  /// 创建一个 [_ManaNavObserver]，包含指定的回调函数。
  _ManaNavObserver({required this.onChanged});

  /// Callback function to be executed when navigation events occur.
  ///
  /// 当导航事件发生时要执行的回调函数。
  final VoidCallback onChanged;

  @override
  void didPush(Route route, Route? previousRoute) => onChanged();
  @override
  void didPop(Route route, Route? previousRoute) => onChanged();
  @override
  void didRemove(Route route, Route? previousRoute) => onChanged();
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) => onChanged();
}
