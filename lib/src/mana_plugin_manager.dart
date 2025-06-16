import 'dart:collection';

import 'mana_pluggable.dart';

/// Defines the types of events that a plugin can trigger.
/// 定义插件可以触发的事件类型。
enum ManaPluginEvent {
  /// The plugin has been activated.
  /// 插件被激活。
  activated,

  /// The plugin has been deactivated.
  /// 插件被取消激活。
  deactivated,

  /// The plugin manager panel is shown.
  /// 插件管理面板展示。
  show,

  /// The plugin manager panel is hidden.
  /// 插件管理面板隐藏。
  hide,

  /// The plugin manager panel main is shown.
  /// 插件管理面板展示。
  mainShow,

  /// The plugin manager panel main is hidden.
  /// 插件管理面板隐藏。
  mainHide,
}

/// A typedef for the plugin callback function.
/// This function is called when a plugin event occurs.
///
/// 插件回调函数。
/// 当插件事件发生时，会调用此函数。
typedef ManaPluginCallback = void Function(
  /// The type of event that occurred.
  /// 事件类型。
  ManaPluginEvent event,

  /// The plugin object related to the event, if any.
  /// 相关的插件对象（如果有）。
  ManaPluggable? plugin,
);

/// [ManaPluginManager] is a singleton class responsible for managing all plugins ([ManaPluggable]).
///
/// [PluginManager] 是一个单例类，用于管理所有插件（[ManaPluggable]）。
class ManaPluginManager {
  static const String name = 'mana_plugin_manager';

  /// The singleton instance of [ManaPluginManager].
  /// It's private and lazily initialized.
  ///
  /// 单例实例，私有且延迟初始化。
  static ManaPluginManager? _instance;

  /// Returns a map of all registered plugins, where the key is the plugin name
  /// and the value is the plugin object.
  ///
  /// 获取当前所有的插件映射（名字 -> 插件对象）。
  LinkedHashMap<String, ManaPluggable> get pluginsMap => _pluginsMap;

  /// Stores a map of registered plugins: key is the plugin name, value is the plugin object.
  ///
  /// 存储已注册插件的映射表：键是插件名称，值是插件对象。
  final LinkedHashMap<String, ManaPluggable> _pluginsMap = LinkedHashMap<String, ManaPluggable>();

  /// The list of observers (callback functions) that need to be notified of events.
  ///
  /// 观察者列表：存储所有需要通知的回调函数。
  final List<ManaPluginCallback> _listeners = [];

  /// The currently activated plugin.
  ///
  /// 当前激活的插件。
  ManaPluggable? _activatedManaPluggable;

  /// Returns the currently activated plugin.
  ///
  /// 获取当前激活的插件。
  ManaPluggable? get activatedManaPluggable => _activatedManaPluggable;

  /// Returns the name of the currently activated plugin.
  ///
  /// 获取当前激活插件的名字。
  String? get activatedManaPluggableName => _activatedManaPluggable?.name;

  /// Indicates whether the plugin manager panel is currently visible.
  ///
  /// 插件管理面板是否展示。
  bool _manaPluginManagerWindowVisibility = false;

  /// Returns the current main visibility status of the plugin manager panel.
  ///
  /// 获取插件管理面板的当前可见性。
  bool get manaPluginManagerWindowVisibility => _manaPluginManagerWindowVisibility;

  /// Indicates whether the plugin manager panel is currently visible.
  ///
  /// 插件管理面板主体是否展示。
  bool _manaPluginManagerWindowMainVisibility = true;

  /// Returns the current main visibility status of the plugin manager panel.
  ///
  /// 获取插件管理面板主体的当前可见性
  bool get manaPluginManagerWindowMainVisibility => _manaPluginManagerWindowMainVisibility;

  /// Returns the singleton instance of [ManaPluginManager].
  /// Initializes it if it hasn't been created yet.
  ///
  /// 获取 [PluginManager] 的单例实例。
  /// 如果尚未创建，则进行初始化。
  static ManaPluginManager get instance {
    _instance ??= ManaPluginManager._();
    return _instance!;
  }

  /// Private constructor to ensure that the class can only be accessed via [instance].
  ///
  /// 私有的构造函数，确保只能通过 instance 访问。
  ManaPluginManager._();

  /// Adds a status listener to be notified of plugin events.
  /// [listener] The callback function to add.
  ///
  /// 添加状态监听器。
  /// [listener] 要添加的回调函数。
  void addListener(ManaPluginCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  /// Removes a status listener.
  /// [listener] The callback function to remove.
  ///
  /// 移除状态监听器。
  /// [listener] 要移除的回调函数。
  void removeListener(ManaPluginCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners about a plugin event.
  /// [event] The type of event that occurred.
  /// [plugin] The plugin object related to the event.
  ///
  /// 通知所有监听器。
  /// [event] 事件类型。
  /// [plugin] 相关的插件对象。
  void _notifyListeners(ManaPluginEvent event, ManaPluggable? plugin) {
    // Create a copy of the listeners list to avoid issues if the list is modified during iteration.
    // 创建监听器副本避免在遍历时修改列表。
    for (final listener in List.of(_listeners)) {
      listener(event, plugin);
    }
  }

  /// Registers a single plugin with the plugin manager.
  /// [plugin] The plugin object to register.
  ///
  /// 注册一个插件到插件管理器中。
  /// [plugin] 要注册的插件对象。
  void register(ManaPluggable plugin) {
    // If the plugin name is empty, do not register it.
    // 如果插件名为空，则不注册。
    if (plugin.name.isEmpty) {
      return;
    }
    // Store the plugin in the map with its name as the key.
    // 将插件以 name 为 key 存入 map 中。
    _pluginsMap[plugin.name] = plugin;
  }

  /// Registers multiple plugins with the plugin manager.
  /// [plugins] The list of plugin objects to register.
  ///
  /// 批量注册多个插件。
  /// [plugins] 要注册的一组插件列表。
  void registerAll(List<ManaPluggable> plugins) {
    for (final plugin in plugins) {
      register(plugin); // Register each plugin individually.
      // 逐个调用 register 方法注册。
    }
  }

  /// Activates a specific plugin.
  /// [pluggable] The plugin object to activate.
  ///
  /// 激活一个插件。
  /// [pluggable] 要激活的插件对象。
  void activateManaPluggable(ManaPluggable pluggable) {
    _activatedManaPluggable = pluggable;
    _notifyListeners(ManaPluginEvent.activated, pluggable);
  }

  /// Deactivates a specific plugin.
  /// [pluggable] The plugin object to deactivate.
  ///
  /// 取消激活某个插件。
  /// [pluggable] 要取消激活的插件对象。
  void deactivateManaPluggable(ManaPluggable? pluggable) {
    // If the currently activated plugin is the one being deactivated, set it to null.
    // 如果当前激活的插件正是要取消的那个，就将其设为 null。
    if (_activatedManaPluggable?.name == pluggable?.name) {
      _activatedManaPluggable = null;
      _notifyListeners(ManaPluginEvent.deactivated, pluggable);
    }
  }

  /// Controls the visibility of the plugin manager panel (show or hide).
  /// [visible] True to show the panel, false to hide it.
  ///
  /// 控制插件管理面板显示或隐藏。
  /// [visible] 为 true 时显示面板，为 false 时隐藏面板。
  void setManaPluginManagerVisibility(bool visible) {
    if (_manaPluginManagerWindowVisibility == visible) {
      return;
    }
    _manaPluginManagerWindowVisibility = visible;
    if (visible) {
      _notifyListeners(ManaPluginEvent.show, null);
      return;
    }
    _notifyListeners(ManaPluginEvent.hide, null);
  }

  /// Controls the main visibility of the plugin manager panel (show or hide).
  /// [visible] True to show the panel, false to hide it.
  ///
  /// 控制插件管理面板主体显示或隐藏。
  /// [visible] 为 true 时显示面板，为 false 时隐藏面板。
  void setManaPluginManagerMainVisibility(bool visible) {
    if (_manaPluginManagerWindowMainVisibility == visible) {
      return;
    }
    _manaPluginManagerWindowMainVisibility = visible;
    if (visible) {
      _notifyListeners(ManaPluginEvent.mainShow, null);
      return;
    }
    _notifyListeners(ManaPluginEvent.mainHide, null);
  }
}
