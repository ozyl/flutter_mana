import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

/// A widget that displays a grid of available Mana plugins, allowing users to select and trigger them.
///
/// 一个显示可用 Mana 插件网格的小部件，允许用户选择并触发它们。
class ManaPanel extends StatelessWidget {
  /// Creates a [ManaPanel].
  ///
  /// 创建一个 [ManaPanel]。
  const ManaPanel({super.key});

  /// The standard size for plugin icons within the panel.
  ///
  /// 面板中插件图标的标准尺寸。
  static const double iconSize = 40;

  @override
  Widget build(BuildContext context) {
    // Get the platform dispatcher to access locale information for internationalization.
    // 获取平台调度器以访问国际化所需的区域设置信息。
    final platformDispatcher = View.of(context).platformDispatcher;
    // Get the first preferred locale for displaying localized plugin names.
    // 获取第一个首选区域设置，用于显示本地化的插件名称。
    final locale = platformDispatcher.locales.first;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Access the ManaState from the context to manage plugin activation.
        // 从上下文中获取 ManaState 以管理插件激活。
        final manaState = ManaManager.of(context);

        // Get the ManaPluginManager instance to access registered plugins.
        // 获取 ManaPluginManager 实例以访问已注册的插件。
        final mm = ManaPluginManager.instance;

        // Calculate the number of columns for the grid based on available width.
        // 根据可用宽度计算网格的列数。
        final crossAxisCount = (constraints.maxWidth * 0.56 / iconSize).floor();

        return GridView.count(
          crossAxisCount: crossAxisCount,
          padding: const EdgeInsets.all(8),
          crossAxisSpacing: 0,
          mainAxisSpacing: 4,
          childAspectRatio: 0.9,
          children: mm.pluginsMap.entries.map(
            (entry) {
              final plugin = entry.value;

              return InkWell(
                onTap: () {
                  // Set the tapped plugin as the active one.
                  // 将点击的插件设置为活动插件。
                  manaState.setActivePluginName(plugin.name);
                  // Trigger the main logic of the plugin.
                  // 触发插件的主要逻辑。
                  plugin.onTrigger();

                  // Hide the plugin management panel after a plugin is selected.
                  // 选择插件后隐藏插件管理面板。
                  manaState.setPluginManagementPanelVisible(false);
                },
                // Build the visual representation of the plugin item.
                // 构建插件项的可视化表示。
                child: _buildPluginItem(plugin, locale, manaState.activePluginName == plugin.name),
              );
            },
          ).toList(),
        );
      },
    );
  }

  /// Builds a single visual item for a plugin in the grid.
  ///
  /// 为网格中的插件构建单个可视化项。
  ///
  /// [plugin]: The [ManaPluggable] instance to display.
  /// [plugin]: 要显示的 [ManaPluggable] 实例。
  /// [locale]: The current locale for localized display names.
  /// [locale]: 当前区域设置，用于本地化显示名称。
  /// [active]: A boolean indicating if this plugin is currently active.
  /// [active]: 指示此插件当前是否活动的布尔值。
  Widget _buildPluginItem(ManaPluggable plugin, Locale locale, bool active) {
    var style = const TextStyle(fontSize: 10);

    // Apply a different style if the plugin is active.
    // 如果插件处于活动状态，则应用不同的样式。
    if (active) {
      style = const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold);
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      // 'spacing' is not a valid property for Column, consider using SizedBox for spacing.
      // 'spacing' 不是 Column 的有效属性，可以考虑使用 SizedBox 进行间距。
      // Note: There's a typo in the original code. 'spacing' should be replaced with SizedBox between children or similar.
      // 注意：原始代码中存在一个拼写错误。'spacing' 应该替换为子元素之间的 SizedBox 或类似方式。
      // spacing: 4, // This line causes an error. Removed or replaced with SizedBox for correctness.
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Image(
              image: plugin.iconImageProvider,
              width: iconSize,
              height: iconSize,
            ),
          ),
        ),
        // Adding a SizedBox for spacing between the icon and text.
        // 在图标和文本之间添加一个 SizedBox 用于间距。
        const SizedBox(height: 4),
        Text(
          plugin.getLocalizedDisplayName(locale),
          style: style,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
