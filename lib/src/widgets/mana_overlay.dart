import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'float_button.dart';
import 'mana_panel.dart';

/// [ManaOverlay] is a top-level overlay widget responsible for displaying
/// the floating action button, the plugin manager panel, and the currently
/// activated plugin's specific widget.
///
/// [ManaOverlay] 是一个顶层 Overlay 部件，负责显示浮动操作按钮、插件管理器面板
/// 以及当前激活插件的特定部件。
class ManaOverlay extends StatefulWidget {
  /// Constructs a [ManaOverlay].
  ///
  /// 构造一个 [ManaOverlay]。
  const ManaOverlay({super.key});

  @override
  State<ManaOverlay> createState() => _ManaOverlayState();
}

class _ManaOverlayState extends State<ManaOverlay> {
  @override
  void initState() {
    super.initState();
    // Registers a listener with the [ManaPluginManager] to react to plugin events,
    // which may trigger UI updates.
    // 向 [ManaPluginManager] 注册一个监听器，以响应插件事件，这可能会触发 UI 更新。
    ManaPluginManager.instance.addListener(_handlePluginEvent);
  }

  @override
  void dispose() {
    // Removes the listener when the widget is disposed to prevent memory leaks.
    // 在部件被销毁时移除监听器，以防止内存泄漏。
    ManaPluginManager.instance.removeListener(_handlePluginEvent);
    super.dispose();
  }

  /// Handles events from the [ManaPluginManager].
  /// It calls `setState` to rebuild the UI if the widget is currently mounted,
  /// ensuring that changes in plugin state are reflected in the overlay.
  ///
  /// 处理来自 [ManaPluginManager] 的事件。
  /// 如果部件当前已挂载，它会调用 `setState` 来重建 UI，
  /// 确保插件状态的变化反映在叠加层中。
  void _handlePluginEvent(ManaPluginEvent event, ManaPluggable? plugin) {
    // Update the UI.
    // 更新 UI。
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final mm = ManaPluginManager.instance;
    // Retrieves the widget provided by the currently activated plugin, if any.
    // 获取当前激活插件提供的部件（如果有）。
    final currentActivatedPluginWidget = mm.activatedManaPluggable?.buildWidget(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        // Displays the widget of the currently activated plugin.
        // This allows plugins to render their custom UI directly in the overlay.
        // 显示当前激活插件的部件。
        // 这允许插件直接在叠加层中渲染其自定义 UI。
        if (currentActivatedPluginWidget != null) currentActivatedPluginWidget,

        // Displays the main plugin manager panel if its visibility is set to true.
        // This panel typically lists available plugins and their controls.
        // 如果插件管理器面板的可见性设置为 true，则显示主插件管理器面板。
        // 此面板通常列出可用插件及其控件。
        if (mm.manaPluginManagerWindowVisibility)
          // The current plugin panel.
          // 当前插件面板。
          const ManaFloatingWindow(
            name: ManaPluginManager.name,
            body: ManaPanel(),
          ),
        // The floating action button that toggles the visibility of the plugin manager panel.
        // 浮动操作按钮，用于切换插件管理器面板的可见性。
        const FloatButton(),
      ],
    );
  }
}
