import 'package:flutter/cupertino.dart';

class ManaState with ChangeNotifier {
  /// 激活的插件名
  String _activePluginName = '';

  String get activePluginName => _activePluginName;

  /// 插件管理面板是否可见
  bool _pluginManagementPanelVisible = false;

  bool get pluginManagementPanelVisible => _pluginManagementPanelVisible;

  /// 浮动窗口主体是否可见
  bool _floatWindowMainVisible = true;

  bool get floatWindowMainVisible => _floatWindowMainVisible;

  /// 浮动窗口主体是否全屏
  bool _floatWindowMainFullscreen = false;

  bool get floatWindowMainFullscreen => _floatWindowMainFullscreen;

  /// 浮动按钮是否可见
  bool _floatActionButtonVisible = true;

  bool get floatActionButtonVisible => _floatActionButtonVisible;

  /// 浮动按钮的大小
  double _floatActionButtonSize = 50;

  double get floatActionButtonSize => _floatActionButtonSize;

  /// 浮动按钮的透明度
  double _floatActionButtonOpacity = 1;

  double get floatActionButtonOpacity => _floatActionButtonOpacity;

  ManaState({
    String? initialActivePluginName = '',
    bool? initialPluginManagementPanelVisible = false,
    bool? initialFloatWindowMainVisible = true,
    bool? floatWindowMainFullscreen = false,
    bool? initialFloatActionButtonVisible = true,
    double? initialFloatActionButtonSize = 50,
    double? initialFloatActionButtonOpacity = 1,
  })  : _activePluginName = initialActivePluginName ?? '',
        _pluginManagementPanelVisible = initialPluginManagementPanelVisible ?? false,
        _floatWindowMainVisible = initialFloatWindowMainVisible ?? true,
        _floatWindowMainFullscreen = floatWindowMainFullscreen ?? false,
        _floatActionButtonVisible = initialFloatActionButtonVisible ?? true,
        _floatActionButtonSize = initialFloatActionButtonSize ?? 50,
        _floatActionButtonOpacity = initialFloatActionButtonOpacity ?? 1;

  void setActivePluginName([String pluginName = '']) {
    _activePluginName = pluginName;
    notifyListeners();
  }

  void setPluginManagementPanelVisible(bool? visible, [bool toggle = false]) {
    if (visible == null && toggle) {
      _pluginManagementPanelVisible = !_pluginManagementPanelVisible;
    } else {
      _pluginManagementPanelVisible = visible ?? true;
    }
    notifyListeners();
  }

  void setFloatWindowMainVisible(bool? visible, [bool toggle = false]) {
    if (visible == null && toggle) {
      _floatWindowMainVisible = !_floatWindowMainVisible;
    } else {
      _floatWindowMainVisible = visible ?? true;
    }
    notifyListeners();
  }

  void setFloatWindowMainFullscreen(bool? fullscreen, [bool toggle = false]) {
    if (fullscreen == null && toggle) {
      _floatWindowMainFullscreen = !_floatWindowMainFullscreen;
    } else {
      _floatWindowMainFullscreen = fullscreen ?? true;
    }
    notifyListeners();
  }

  void setFloatActionButtonVisible(bool? visible, [bool toggle = false]) {
    if (visible == null && toggle) {
      _floatActionButtonVisible = !_floatActionButtonVisible;
    } else {
      _floatActionButtonVisible = visible ?? true;
    }
    notifyListeners();
  }

  void setFloatActionButtonSize([double size = 50]) {
    _floatActionButtonSize = size;
    notifyListeners();
  }

  void setFloatActionButtonOpacity([double opacity = 1]) {
    _floatActionButtonOpacity = opacity;
    notifyListeners();
  }
}
