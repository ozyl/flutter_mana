import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mana/flutter_mana.dart';

/// A Navigator wrapper that automatically wraps all pushed pages with ManaHitTestManager.
///
/// This ensures that all pages pushed through this navigator have event passthrough capability.
///
/// 自动为所有 push 的页面包裹 ManaHitTestManager 的 Navigator 包装器。
/// 这确保了通过这个 navigator 推送的所有页面都具备事件穿透能力。
class ManaNavigator extends StatefulWidget {
  final GlobalKey<NavigatorState>? navigatorKey;
  final String? initialRoute;
  final RouteFactory? onGenerateRoute;
  final RouteFactory? onUnknownRoute;
  final List<NavigatorObserver>? observers;
  final String? restorationScopeId;

  const ManaNavigator({
    super.key,
    this.navigatorKey,
    this.initialRoute,
    this.onGenerateRoute,
    this.onUnknownRoute,
    this.observers,
    this.restorationScopeId,
  });

  @override
  State<ManaNavigator> createState() => _ManaNavigatorState();

  /// Push a route with automatic ManaHitTestManager wrapping
  static Future<T?> pushMaterial<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    return Navigator.of(context).push<T>(
      MaterialPageRoute<T>(
        settings: settings,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
        builder: (context) => ManaHitTestManager(child: page),
      ),
    );
  }

  /// Push a named route with automatic ManaHitTestManager wrapping
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.of(context).pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Push a CupertinoPageRoute with automatic ManaHitTestManager wrapping
  static Future<T?> pushCupertino<T extends Object?>(
    BuildContext context,
    Widget page, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
    bool maintainState = true,
  }) {
    return Navigator.of(context).push<T>(
      _ManaCupertinoPageRoute<T>(
        settings: settings,
        fullscreenDialog: fullscreenDialog,
        maintainState: maintainState,
        builder: (context) => ManaHitTestManager(child: page),
      ),
    );
  }
}

class _ManaNavigatorState extends State<ManaNavigator>
    with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<bool> didPopRoute() async {
    final navigatorKey = widget.navigatorKey ?? _navigatorKey;
    if ((await navigatorKey.currentState?.maybePop()) ?? false) {
      return true;
    }
    if (!mounted) return false;
    final manaState = ManaScope.of(context);
    if (manaState.pluginManagementPanelVisible.value) {
      manaState.pluginManagementPanelVisible.value = false;
      return true;
    }
    if (manaState.floatWindowMainVisible.value && manaState.activePluginName.value.isNotEmpty) {
      manaState.floatWindowMainVisible.value = false;
      manaState.floatingButtonVisible.value = true;
      return true;
    }
    return false;
  }

  @override
  void initState() {
    ManaPluginManager.instance.addInnerObserver(this);
    super.initState();
  }

  @override
  void dispose() {
    ManaPluginManager.instance.removeInnerObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: widget.navigatorKey ?? _navigatorKey,
      initialRoute: widget.initialRoute,
      onGenerateRoute: (settings) {
        // 如果提供了自定义的 onGenerateRoute，先调用它
        final route = widget.onGenerateRoute?.call(settings);
        if (route != null) {
          // 包装路由的 builder，自动添加 ManaHitTestManager
          if (route is MaterialPageRoute) {
            return MaterialPageRoute(
              settings: route.settings,
              fullscreenDialog: route.fullscreenDialog,
              maintainState: route.maintainState,
              builder: (context) => ManaHitTestManager(
                child: route.builder(context),
              ),
            );
          } else if (route is CupertinoPageRoute) {
            return _ManaCupertinoPageRoute(
              settings: route.settings,
              fullscreenDialog: route.fullscreenDialog,
              maintainState: route.maintainState,
              builder: (context) => ManaHitTestManager(
                child: route.builder(context),
              ),
            );
          } else if (route is PageRouteBuilder) {
            return PageRouteBuilder(
              settings: route.settings,
              opaque: route.opaque,
              barrierDismissible: route.barrierDismissible,
              barrierColor: route.barrierColor,
              barrierLabel: route.barrierLabel,
              maintainState: route.maintainState,
              fullscreenDialog: route.fullscreenDialog,
              pageBuilder: (context, animation, secondaryAnimation) {
                return ManaHitTestManager(
                  child:
                      route.pageBuilder(context, animation, secondaryAnimation),
                );
              },
              transitionsBuilder: route.transitionsBuilder,
              transitionDuration: route.transitionDuration,
              reverseTransitionDuration: route.reverseTransitionDuration,
            );
          }
        }
        return route;
      },
      onUnknownRoute: widget.onUnknownRoute,
      observers: widget.observers ?? [],
      restorationScopeId: widget.restorationScopeId,
    );
  }
}

class _ManaCupertinoPageRoute<T> extends CupertinoPageRoute<T> {
  /// Creates a page route for use in an iOS designed app.
  ///
  /// The [builder], [maintainState], and [fullscreenDialog] arguments must not
  /// be null.
  _ManaCupertinoPageRoute({
    required super.builder,
    super.title,
    super.settings,
    super.requestFocus,
    super.maintainState = true,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
  }) {
    assert(opaque);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return ManaHitTestManager(
        child: super
            .buildTransitions(context, animation, secondaryAnimation, child));
  }
}

class ManaHitTestManager extends StatefulWidget {
  // 使用 Set 来避免重复的 key，并添加同步保护
  static final Set<GlobalKey> _keys = <GlobalKey>{};

  // 提供只读访问
  static Set<GlobalKey> get keys => Set.unmodifiable(_keys);

  // 线程安全的 key 管理方法
  static void _addKey(GlobalKey key) {
    _keys.add(key);
  }

  static void _removeKey(GlobalKey key) {
    _keys.remove(key);
  }

  final Widget child;
  const ManaHitTestManager({super.key, required this.child});

  @override
  State<ManaHitTestManager> createState() => _ManaHitTestManagerState();
}

class _ManaHitTestManagerState extends State<ManaHitTestManager> {
  GlobalKey? _key;

  @override
  void initState() {
    // 查找最外层的 ManaHitTestManager 的 key
    _key =
        context.findRootAncestorStateOfType<_ManaHitTestManagerState>()?._key;

    // 如果没有找到父级的 key，说明这是最外层，创建新的 key
    if (_key == null) {
      _key = GlobalKey();
      ManaHitTestManager._addKey(_key!);
    } else {
      _key = null;
    }
    super.initState();
  }

  @override
  void dispose() {
    // 只有当这个实例拥有 key 时才移除（即最外层实例）
    if (_key != null && ManaHitTestManager.keys.contains(_key!)) {
      ManaHitTestManager._removeKey(_key!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_key != null) {
      return SizedBox(
        key: _key,
        child: widget.child,
      );
    }
    return widget.child;
  }
}

class ManaHitTestForwarder extends SingleChildRenderObjectWidget {
  const ManaHitTestForwarder({
    super.key,
    super.child,
  });

  static final List<bool Function(Offset pos)> _hitTests = [];

  static void addHitTest(bool Function(Offset pos) hitTest) {
    _hitTests.add(hitTest);
  }

  static void removeHitTest(bool Function(Offset pos) hitTest) {
    _hitTests.remove(hitTest);
  }

  static bool _disable = false;

  static void disable() {
    _disable = true;
  }

  static void enable() {
    _disable = false;
  }

  @override
  RenderManaHitTestForwarder createRenderObject(BuildContext context) {
    return RenderManaHitTestForwarder(context);
  }
}

class RenderManaHitTestForwarder extends RenderProxyBox {
  final BuildContext context;

  RenderManaHitTestForwarder(this.context);

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if(ManaHitTestForwarder._disable) return super.hitTest(result, position: position);
    for (final hitTest in ManaHitTestForwarder._hitTests) {
      if (hitTest(position)) {
        return super.hitTest(result, position: position);
      }
    }
    // 转换为 List 以使用 reversed 方法
    for (final key in ManaHitTestManager.keys.toList().reversed) {
      if (key.currentContext?.findRenderObject()
          case RenderBox renderManaHitTestForwarder) {
        final hit =
            renderManaHitTestForwarder.hitTest(result, position: position);
        if (hit) {
          return true;
        }
      }
    }
    return false;
  }
}
