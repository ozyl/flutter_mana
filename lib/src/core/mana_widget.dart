import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../../flutter_mana.dart';
import '../widgets/mana_overlay.dart';

/// A global key used to access the root node of the ManaWidget.
///
/// 全局 Key，用于获取 ManaWidget 的根节点。
final GlobalKey manaRootKey = GlobalKey();

Locale manaLocale = Locale('en');

/// Provides the entry point and basic structure for the Mana plugin system.
///
/// 提供了 Mana 插件体系的入口和基础结构。
class ManaWidget extends StatefulWidget {
  /// The child widget of ManaWidget.
  ///
  /// ManaWidget 的子组件。
  final Widget child;

  /// Controls whether ManaWidget is enabled.
  /// If `false`, Mana-related components will not be displayed.
  ///
  /// 控制 ManaWidget 是否启用。
  /// 如果为 `false`，则不显示 Mana 相关的组件。
  final bool enable;

  /// Constructor for creating a ManaWidget instance.
  ///
  /// 构造函数，用于创建 ManaWidget 实例。
  const ManaWidget({super.key, required this.child, this.enable = true});

  @override
  State<ManaWidget> createState() => _ManaWidgetState();
}

class _ManaWidgetState extends State<ManaWidget> with WidgetsBindingObserver {
  /// 初始化 Future，用于 FutureBuilder
  late final Future<ManaState> _initializationFuture;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializationFuture = _initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    for (final observer in ManaPluginManager.instance.innerObservers) {
      if (await observer.didPopRoute()) {
        return true;
      }
    }
    return false;
  }

  /// Initializes the Mana store.
  ///
  /// 初始化 Mana 存储 。
  Future<ManaState> _initialize() async {
    await ManaPluginManager.instance.initialize();
    return await ManaStore.instance.getManaState();
  }

  @override
  Widget build(BuildContext context) {
    /// If `enable` is `false`, return the child widget directly without loading Mana-related features.
    ///
    /// 如果 `enable` 为 `false`，则直接返回子组件，不加载 Mana 相关功能。
    if (!widget.enable) {
      return widget.child;
    }

    // Get the platform dispatcher to access locale information for internationalization.
    // 获取平台调度器以访问国际化所需的区域设置信息。
    final platformDispatcher = View.of(context).platformDispatcher;
    // Get the first preferred locale for displaying localized plugin names.
    // 获取第一个首选区域设置，用于显示本地化的插件名称。
    manaLocale = platformDispatcher.locales.first;

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        /// Wraps the child widget with RepaintBoundary and assigns `manaRootKey` to it.
        ///
        /// 使用 RepaintBoundary 包裹子组件，并为其分配 `manaRootKey`。
        RepaintBoundary(key: manaRootKey, child: widget.child),

        // 使用 FutureBuilder 实现异步初始化，更简洁
        FutureBuilder<ManaState>(
          future: _initializationFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }
            final mana = ManaScope(
              state: snapshot.data!,
              child: ManaHitTestForwarder(
                child: ManaNavigator(
                  onGenerateRoute: (settings) => PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ManaOverlay(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                ),
              ),
            );
            return Material(
                type: MaterialType.transparency,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Localizations(
                    delegates: [
                      GlobalCupertinoLocalizations.delegate,
                      GlobalMaterialLocalizations.delegate,
                      GlobalWidgetsLocalizations.delegate,
                    ],
                    locale: manaLocale,
                    child: ScaffoldMessenger(
                      child: DefaultTextEditingShortcuts(
                        child: mana,
                      ),
                    ),
                  ),
                ));
          },
        ),
      ],
    );
  }
}
