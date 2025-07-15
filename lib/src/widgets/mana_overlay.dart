import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'float_button.dart';
import 'mana_panel.dart';
import 'mana_setting_panel.dart';

/// A widget that manages and displays various Mana components as an overlay.
/// This includes the active plugin's widget, the plugin management panel, and the float action button.
///
/// 一个管理和显示各种 Mana 组件作为浮层的小部件。
/// 这包括活动插件的部件、插件管理面板和浮动操作按钮。
class ManaOverlay extends StatefulWidget {
  /// Creates a [ManaOverlay].
  ///
  /// 创建一个 [ManaOverlay]。
  const ManaOverlay({super.key});

  @override
  State<ManaOverlay> createState() => _ManaOverlayState();
}

class _ManaOverlayState extends State<ManaOverlay> {
  /// The state object for Mana, which must be preserved using a StatefulWidget.
  ///
  /// Mana 的状态对象，必须使用 StatefulWidget 进行状态保存。
  final ManaState _manaState = ManaStore.instance.getManaState();

  /// Builds the stack of overlay widgets.
  ///
  /// 构建覆盖层小部件的堆栈。
  Widget _buildStack() {
    return Builder(
      builder: (BuildContext context) {
        // Access the ManaState from the context.
        // 从上下文中获取 ManaState。
        final manaState = ManaManager.of(context);

        // Get the widget of the currently active plugin, if any.
        // 获取当前活动插件的部件（如果有）。
        final currentActivatedPluginWidget =
            ManaPluginManager.instance.pluginsMap[manaState.activePluginName]?.buildWidget(context);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Display the active plugin's widget if it exists.
            // 如果存在，显示活动插件的部件。
            if (currentActivatedPluginWidget != null) currentActivatedPluginWidget,
            // Display the plugin management panel if it's visible.
            // 如果插件管理面板可见，则显示它。
            if (manaState.pluginManagementPanelVisible)
              const ManaFloatingWindow(
                name: ManaPluginManager.name,
                content: ManaPanel(),
                setting: ManaSettingPanel(),
              ),
            // Display the float action button if it's visible.
            // 如果浮动操作按钮可见，则显示它。
            if (manaState.floatActionButtonVisible) const FloatButton(),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ManaManager(
      notifier: _manaState,
      child: _buildStack(),
    );
  }
}
