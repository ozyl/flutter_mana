import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_mana/src/widgets/adaptive_media_query.dart';
import 'package:flutter_mana/src/widgets/mana_overlay.dart';

/// Default localization delegates for Material, Widgets, and Cupertino.
/// These are typically required for proper internationalization in Flutter apps.
///
/// Material、Widgets 和 Cupertino 的默认本地化代理。
/// 这些通常是 Flutter 应用程序中正确国际化所需的。
const defaultLocalizationsDelegates = [
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];

/// GlobalKey for the root widget of the application wrapped by [ManaWidget].
/// This can be used to perform actions on the application's main content.
///
/// [ManaWidget] 包裹的应用根部件的全局 Key。
/// 可用于对应用主体内容执行操作。
final GlobalKey manaRootKey = GlobalKey();

/// GlobalKey for the [OverlayState] used to insert [OverlayEntry] widgets.
/// This allows for dynamically adding widgets on top of the application's content.
///
/// 用于插入 [OverlayEntry] 部件的 [OverlayState] 全局 Key。
/// 这允许在应用程序内容之上动态添加部件。
final GlobalKey<OverlayState> manaOverlayKey = GlobalKey<OverlayState>();

/// A wrapper widget that provides a floating button functionality
/// and handles overlay injection for the application.
///
/// 一个包装部件，提供浮动按钮功能并处理应用程序的 Overlay 注入。
class ManaWidget extends StatefulWidget {
  /// The main application content wrapped by this widget.
  ///
  /// 被包裹的应用主体内容。
  final Widget child;

  /// Whether to enable the floating button feature.
  /// Defaults to true.
  ///
  /// 是否启用浮动按钮。
  /// 默认为 true。
  final bool enable;

  /// The list of locales that this app has been localized for.
  /// If not provided, the default locale from the platform will be used.
  ///
  /// 此应用程序已本地化的语言环境列表。
  /// 如果不提供，将使用平台的默认语言环境。
  final Iterable<Locale>? supportedLocales;

  /// The list of [LocalizationsDelegate]s for this app.
  /// Defaults to [defaultLocalizationsDelegates].
  ///
  /// 此应用程序的 [LocalizationsDelegate] 列表。
  /// 默认为 [defaultLocalizationsDelegates]。
  final Iterable<LocalizationsDelegate> localizationsDelegates;

  /// Constructs a [ManaWidget].
  ///
  /// 构造函数。
  const ManaWidget({
    super.key,
    required this.child,
    this.enable = true,
    this.supportedLocales,
    this.localizationsDelegates = defaultLocalizationsDelegates,
  });

  @override
  State<ManaWidget> createState() => _ManaWidgetState();
}

class _ManaWidgetState extends State<ManaWidget> {
  /// The [OverlayEntry] that will hold the [ManaOverlay].
  ///
  /// 将包含 [ManaOverlay] 的 [OverlayEntry]。
  OverlayEntry? _overlayEntry;

  /// A flag indicating whether the [_overlayEntry] has been inserted into the [Overlay].
  ///
  /// 指示 [_overlayEntry] 是否已插入到 [Overlay] 中的标志。
  bool _overlayEntryInserted = false;

  @override
  void initState() {
    super.initState();
    // If enabled, inject the overlay when the widget initializes.
    // 如果启用，在部件初始化时注入 Overlay。
    if (widget.enable) {
      _injectOverlay();
    }
  }

  @override
  void didUpdateWidget(ManaWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // React to changes in the 'enable' property.
    // 对 'enable' 属性的变化做出反应。
    if (widget.enable != oldWidget.enable) {
      if (widget.enable) {
        _injectOverlay();
      } else {
        _removeOverlay();
      }
    }
  }

  @override
  void dispose() {
    // Ensure the overlay is removed when the widget is disposed.
    // 确保在部件被销毁时移除 Overlay。
    _removeOverlay();
    super.dispose();
  }

  /// Removes the [OverlayEntry] from the [Overlay].
  ///
  /// 移除 [OverlayEntry] 从 [Overlay] 中。
  void _removeOverlay() {
    if (_overlayEntryInserted) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _overlayEntryInserted = false;
    }
  }

  /// Inserts the [OverlayEntry] into the global [Overlay].
  ///
  /// 插入 [OverlayEntry] 到全局 [Overlay] 中。
  void _injectOverlay() {
    // Schedule the injection after the current frame callback to ensure the OverlayState is ready.
    // 在当前帧回调后安排注入，以确保 OverlayState 已准备好。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Prevent multiple insertions.
      // 防止多次插入。
      if (_overlayEntryInserted) {
        return;
      }
      if (widget.enable) {
        _overlayEntry = OverlayEntry(
          builder: (_) => ManaOverlay(),
        );
        // Insert the overlay entry using the global key.
        // 使用全局 key 插入 OverlayEntry。
        manaOverlayKey.currentState?.insert(_overlayEntry!);
        _overlayEntryInserted = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the platform's preferred locale.
    // 获取平台的首选语言环境。
    final platformDispatcher = View.of(context).platformDispatcher;
    final locale = platformDispatcher.locales.first;

    return Directionality(
      textDirection: TextDirection.ltr, // Ensure left-to-right text direction for the whole app.
      // 确保整个应用程序的文本方向为从左到右。
      child: Stack(
        children: [
          // The main application content, wrapped in a RepaintBoundary for performance.
          // 主要应用程序内容，包裹在 RepaintBoundary 中以提高性能。
          RepaintBoundary(key: manaRootKey, child: widget.child),

          // 必须包裹在一个应用程序骨架组件内，否则TextField输入文字无法删除
          WidgetsApp(
            color: Colors.white,
            builder: (context, child) {
              return Directionality(
                textDirection: TextDirection.ltr,
                // AdaptiveMediaQuery helps adapt to different screen sizes and orientations.
                // AdaptiveMediaQuery 有助于适应不同的屏幕尺寸和方向。
                child: AdaptiveMediaQuery(
                  child: Localizations(
                    // Use the first supported locale if provided, otherwise use the platform's locale.
                    // 如果提供了支持的语言环境，则使用第一个，否则使用平台的语言环境。
                    locale: widget.supportedLocales?.first ?? locale,
                    delegates: widget.localizationsDelegates.toList(),
                    child: Material(
                      type: MaterialType.transparency,
                      // The Overlay widget where dynamic content will be injected.
                      // Overlay 部件，动态内容将在此处注入。
                      child: Overlay(key: manaOverlayKey),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
