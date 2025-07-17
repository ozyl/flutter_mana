import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'icon.dart';

/// Horizontal margin for the float button.
/// 浮动按钮的水平边距。
const double mx = 10;

/// Vertical margin for the float button from the top.
/// 浮动按钮距离顶部的垂直边距。
const double my = 60;

/// Distance from the bottom of the screen for the initial position of the float button.
/// 浮动按钮初始位置距离屏幕底部的距离。
const double bottomDistance = 100;

/// A customizable floating action button that can be dragged and positioned on the screen.
///
/// 一个可自定义的浮动操作按钮，可以在屏幕上拖动和定位。
class FloatButton extends StatefulWidget {
  /// Creates a [FloatButton].
  ///
  /// 创建一个 [FloatButton]。
  const FloatButton({
    super.key,
  });

  @override
  State<FloatButton> createState() => _FloatButtonState();
}

class _FloatButtonState extends State<FloatButton> {
  late ManaState _manaState;

  /// Stores the size of the current window.
  ///
  /// 存储当前窗口的大小。
  Size _windowSize = Size.zero;

  /// Stores the size of the float button.
  ///
  /// 存储浮动按钮的大小。
  Size _dotSize = Size(50, 50);

  /// Stores the opacity of the float button.
  ///
  /// 存储浮动按钮的不透明度。
  double _opacity = 1;

  /// The x-coordinate of the float button's position.
  ///
  /// 浮动按钮位置的X坐标。
  double _dx = 0;

  /// The y-coordinate of the float button's position.
  ///
  /// 浮动按钮位置的Y坐标。
  double _dy = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _manaState = ManaScope.of(context);
    _manaState.floatActionButtonSize.addListener(_resetPosition);
    _manaState.floatActionButtonOpacity.addListener(_resetPosition);
    _resetPosition();
  }

  @override
  void dispose() {
    _manaState.floatActionButtonSize.removeListener(_resetPosition);
    _manaState.floatActionButtonOpacity.removeListener(_resetPosition);
    super.dispose();
  }

  /// Resets the position of the float button based on window size and stored preferences.
  ///
  /// 根据窗口大小和存储的偏好设置重置浮动按钮的位置。
  void _resetPosition() {
    if (!mounted) {
      return;
    }

    _windowSize = MediaQuery.sizeOf(context);

    final size = _manaState.floatActionButtonSize.value;

    _dotSize = Size(size, size);

    _opacity = _manaState.floatActionButtonOpacity.value;

    final position = ManaStore.instance.getFloatActionButtonPosition();

    if (position.$1 < _windowSize.width && position.$2 < _windowSize.height) {
      if (position.$1 > 0 || position.$2 > 0) {
        _dx = position.$1;
        _dy = position.$2;
      }
    } else {
      _dx = _windowSize.width - _dotSize.width - mx;

      _dy = _windowSize.height - _dotSize.height - bottomDistance;
    }

    if (_dx + _dotSize.width / 2 < _windowSize.width / 2) {
      _dx = mx;
    } else {
      _dx = _windowSize.width - _dotSize.width - mx;
    }

    if (_dy < my) {
      _dy = my;
    } else if (_dy + _dotSize.height + my > _windowSize.height) {
      _dy = _windowSize.height - _dotSize.height - my;
    }

    setState(() {});
  }

  /// Updates the float button's position during a drag gesture.
  ///
  /// 在拖动手势期间更新浮动按钮的位置。
  void dragEvent(DragUpdateDetails details) {
    setState(() {
      _dx = details.globalPosition.dx - _dotSize.width / 2;
      _dy = details.globalPosition.dy - _dotSize.height / 2;
    });
  }

  /// Finalizes the float button's position after a drag gesture ends.
  ///
  /// 拖动结束后，确定浮动按钮的最终位置。
  void dragEnd(DragEndDetails details) {
    setState(() {
      if (_dx + _dotSize.width / 2 < _windowSize.width / 2) {
        _dx = mx;
      } else {
        _dx = _windowSize.width - _dotSize.width - mx;
      }

      if (_dy < my) {
        _dy = my;
      } else if (_dy + _dotSize.height + my > _windowSize.height) {
        _dy = _windowSize.height - _dotSize.height - my;
      }

      ManaStore.instance.setFloatActionButtonPosition(_dx, _dy);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _dx,
      top: _dy,
      child: GestureDetector(
        onTap: () {
          if (_manaState.activePluginName.value.isNotEmpty && !_manaState.floatWindowMainVisible.value) {
            _manaState.floatWindowMainVisible.value = true;

            if (_manaState.floatWindowMainFullscreen.value) {
              _manaState.floatActionButtonVisible.value = false;
            }
            return;
          }

          _manaState.pluginManagementPanelVisible.value = !_manaState.pluginManagementPanelVisible.value;
        },
        onVerticalDragEnd: dragEnd,
        onHorizontalDragEnd: dragEnd,
        onHorizontalDragUpdate: dragEvent,
        onVerticalDragUpdate: dragEvent,
        child: Opacity(
          opacity: _opacity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0.0, 0.0),
                  blurRadius: 2.0,
                  spreadRadius: 1.0,
                ),
              ],
            ),
            width: _dotSize.width,
            height: _dotSize.height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ValueListenableBuilder(
                  valueListenable: _manaState.activePluginName,
                  builder: (context, name, child) {
                    final icon = ManaPluginManager.instance.pluginsMap[name]?.iconImageProvider;
                    return Image(image: icon ?? iconImage);
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
