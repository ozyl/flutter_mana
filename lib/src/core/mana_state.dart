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
  final ValueNotifier<bool> floatActionButtonVisible;

  /// 浮动按钮的大小
  final ValueNotifier<double> floatActionButtonSize;

  /// 浮动按钮的透明度
  final ValueNotifier<double> floatActionButtonOpacity;

  ManaState({
    String? initialActivePluginName,
    bool? initialPluginManagementPanelVisible,
    bool? initialFloatWindowMainVisible,
    bool? floatWindowMainFullscreen,
    bool? initialFloatActionButtonVisible,
    double? initialFloatActionButtonSize,
    double? initialFloatActionButtonOpacity,
  })  : activePluginName = ValueNotifier(initialActivePluginName ?? ''),
        pluginManagementPanelVisible = ValueNotifier(initialPluginManagementPanelVisible ?? false),
        floatWindowMainVisible = ValueNotifier(initialFloatWindowMainVisible ?? true),
        floatWindowMainFullscreen = ValueNotifier(floatWindowMainFullscreen ?? false),
        floatActionButtonVisible = ValueNotifier(initialFloatActionButtonVisible ?? true),
        floatActionButtonSize = ValueNotifier(initialFloatActionButtonSize ?? 50),
        floatActionButtonOpacity = ValueNotifier(initialFloatActionButtonOpacity ?? 1);

  // 释放资源
  void dispose() {
    activePluginName.dispose();
    pluginManagementPanelVisible.dispose();
    floatWindowMainVisible.dispose();
    floatWindowMainFullscreen.dispose();
    floatActionButtonVisible.dispose();
    floatActionButtonSize.dispose();
    floatActionButtonOpacity.dispose();
  }
}
