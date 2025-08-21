import 'package:flutter/cupertino.dart';

class ManaState {
  /// 激活的插件名
  final ValueNotifier<String> activePluginName;

  /// 插件管理面板是否可见
  final ValueNotifier<bool> pluginManagementPanelVisible;

  /// 浮动窗口主体是否可见
  final ValueNotifier<bool> floatWindowMainVisible;

  /// 浮动窗口主体是否全屏
  final ValueNotifier<bool> floatWindowMainFullscreen;

  /// 浮动按钮是否可见
  final ValueNotifier<bool> floatingButtonVisible;

  /// 浮动按钮的大小
  final ValueNotifier<double> floatingButtonSize;

  /// 浮动按钮的透明度
  final ValueNotifier<double> floatingButtonOpacity;

  ManaState({
    String? initialActivePluginName,
    bool? initialPluginManagementPanelVisible,
    bool? initialFloatWindowMainVisible,
    bool? floatWindowMainFullscreen,
    bool? initialFloatingButtonVisible,
    double? initialFloatingButtonSize,
    double? initialFloatingButtonOpacity,
  })  : activePluginName = ValueNotifier(initialActivePluginName ?? ''),
        pluginManagementPanelVisible = ValueNotifier(initialPluginManagementPanelVisible ?? false),
        floatWindowMainVisible = ValueNotifier(initialFloatWindowMainVisible ?? false),
        floatWindowMainFullscreen = ValueNotifier(floatWindowMainFullscreen ?? false),
        floatingButtonVisible = ValueNotifier(initialFloatingButtonVisible ?? true),
        floatingButtonSize = ValueNotifier(initialFloatingButtonSize ?? 50),
        floatingButtonOpacity = ValueNotifier(initialFloatingButtonOpacity ?? 1);

  // 释放资源
  void dispose() {
    activePluginName.dispose();
    pluginManagementPanelVisible.dispose();
    floatWindowMainVisible.dispose();
    floatWindowMainFullscreen.dispose();
    floatingButtonVisible.dispose();
    floatingButtonSize.dispose();
    floatingButtonOpacity.dispose();
  }
}
