import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'floating_button/index.dart';
import 'mana_panel.dart';
import 'mana_setting_panel.dart';
import 'nil.dart';

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

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        // Access the ManaState from the context.
        // 从上下文中获取 ManaState。
        final manaState = ManaScope.of(context);

        return Stack(
          alignment: Alignment.center,
          children: [
            ValueListenableBuilder(
              valueListenable: manaState.activePluginName,
              builder: (context, value, _) {
                final currentActivatedPluginWidget = ManaPluginManager
                    .instance.pluginsMap[manaState.activePluginName.value]
                    ?.buildWidget(context);
                return currentActivatedPluginWidget ?? nilPosition;
              },
            ),
            ValueListenableBuilder(
              valueListenable: manaState.pluginManagementPanelVisible,
              builder: (context, value, _) {
                return value
                    ? ManaFloatingWindow(
                        name: ManaPluginManager.name,
                        content: ManaPanel(),
                        setting: ManaSettingPanel(),
                      )
                    : nilPosition;
              },
            ),
            ValueListenableBuilder(
              valueListenable: manaState.floatingButtonVisible,
              builder: (context, value, _) {
                return value ? const FloatingButton() : nilPosition;
              },
            ),
          ],
        );
      },
    );
  }
}
