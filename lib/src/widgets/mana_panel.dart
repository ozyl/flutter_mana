import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

/// The [ManaPanel] widget displays a grid of available plugins.
/// Users can tap on a plugin to activate it and close the panel.
///
/// [ManaPanel] 部件显示可用插件的网格。
/// 用户可以点击插件来激活它并关闭面板。
class ManaPanel extends StatefulWidget {
  /// Constructs a [ManaPanel].
  ///
  /// 构造一个 [ManaPanel]。
  const ManaPanel({super.key});

  @override
  State<ManaPanel> createState() => _ManaPanelState();
}

class _ManaPanelState extends State<ManaPanel> {
  /// The size of each plugin icon in the panel.
  ///
  /// 图标的尺寸。
  static const double iconSize = 40;

  @override
  void initState() {
    super.initState();
    // Adds a listener to the [ManaPluginManager] to rebuild the UI when plugin events occur.
    // 向 [ManaPluginManager] 添加一个监听器，以便在插件事件发生时重建 UI。
    ManaPluginManager.instance.addListener(_handlePluginEvent);
  }

  @override
  void dispose() {
    // Removes the listener when the widget is disposed to prevent memory leaks.
    // 在部件被销毁时移除监听器，以防止内存泄漏。
    ManaPluginManager.instance.removeListener(_handlePluginEvent);
    super.dispose();
  }

  /// Handles events triggered by the [ManaPluginManager].
  /// It forces a UI update if the widget is mounted.
  ///
  /// 处理 [ManaPluginManager] 触发的事件。
  /// 如果部件已挂载，则强制更新 UI。
  void _handlePluginEvent(ManaPluginEvent event, ManaPluggable? plugin) {
    // Update the UI.
    // 更新UI。
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the current locale to display localized plugin names.
    // 获取当前语言环境以显示本地化插件名称。
    Locale currentLocale = Localizations.localeOf(context);

    // [LayoutBuilder] is used to get the available space and calculate the number of columns dynamically.
    // 使用 [LayoutBuilder] 获取可用空间并动态计算列数。
    return LayoutBuilder(builder: (context, constraints) {
      final mm = ManaPluginManager.instance;

      // Calculates the number of columns based on the available width and icon size.
      // 0.6 is an arbitrary factor to make the panel roughly 60% of the screen width.
      // 根据可用宽度和图标大小计算列数。
      // 0.6 是一个任意因子，使面板大致为屏幕宽度的 60%。
      final crossAxisCount = (constraints.maxWidth * 0.6 / iconSize).floor();

      return GridView.count(
        crossAxisCount: crossAxisCount,
        padding: const EdgeInsets.all(0),
        crossAxisSpacing: 0,
        // Column spacing. 列间距。
        mainAxisSpacing: 0,
        // Row spacing. 行间距。
        childAspectRatio: 1,
        // Adjust aspect ratio. 调整宽高比。
        children: mm.pluginsMap.entries.map((entry) {
          final plugin = entry.value;

          return InkWell(
            onTap: () {
              // Activate the selected plugin.
              // 激活选定的插件。
              mm.activateManaPluggable(plugin);

              plugin.onTrigger();

              // Hide the plugin manager panel after selection.
              // 选择后隐藏插件管理器面板。
              mm.setManaPluginManagerVisibility(false);
              setState(() {});
            },
            // Builds each plugin item with its icon and name, highlighting if active.
            // 构建每个插件项，包括其图标和名称，如果处于激活状态则高亮显示。
            child: _buildPluginItem(plugin, currentLocale, mm.activatedManaPluggable?.name == plugin.name),
          );
        }).toList(),
      );
    });
  }

  /// Builds a single plugin item widget.
  /// [plugin] The plugin to display.
  /// [locale] The current locale for localization.
  /// [active] Whether the plugin is currently active.
  ///
  /// 构建单个插件项部件。
  /// [plugin] 要显示的插件。
  /// [locale] 用于本地化的当前语言环境。
  /// [active] 插件当前是否处于激活状态。
  Widget _buildPluginItem(ManaPluggable plugin, Locale locale, bool active) {
    var style = const TextStyle(fontSize: 10);

    // Apply a different style if the plugin is active.
    // 如果插件处于激活状态，则应用不同的样式。
    if (active) {
      style = const TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Rounded icon container.
        // 圆角图标容器。
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
        const SizedBox(height: 2),
        // Plugin name.
        // 插件名称。
        Text(
          plugin.getLocalizedDisplayName(locale),
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
