import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

enum PositionType {
  normal,
  top,
  bottom,
}

/// A customizable floating window widget.
///
/// This widget provides a resizable and draggable window with optional
/// control buttons for full-screen, minimize, and close actions.
///
/// 一个可自定义的浮动窗口组件。
/// 该组件提供了一个可调整大小和可拖动的窗口，并带有用于全屏、最小化和关闭操作的可选控制按钮。
class ManaFloatingWindow extends StatefulWidget {
  /// The unique name of the window
  ///
  /// 窗口唯一名字，可以是插件的唯一名字
  final String name;

  /// The content area of the window.
  ///
  /// 窗口内容区域。
  final Widget body;

  /// A custom modal overlay.
  /// If not provided, a default transparent GestureDetector will be used.
  ///
  /// 自定义蒙层。
  /// 如果不传入，将使用默认的透明 GestureDetector。
  final Widget? modal;

  /// The initial width of the window.
  /// If not provided, defaults to 60% of the screen width.
  ///
  /// 窗口的初始宽度。
  /// 如果不传入，默认为屏幕宽度的0.6。
  final double? initialWidth;

  /// The initial height of the window.
  /// If not provided, defaults to 60% of the screen height.
  ///
  /// 窗口的初始高度。
  /// 如果不传入，默认为屏幕高度的0.6。
  final double? initialHeight;

  /// The initial position of the window.
  ///
  /// 窗口位置
  final PositionType position;

  /// The initial dx of the window.
  ///
  /// 窗口的初始横坐标
  final double? dx;

  /// The initial dy of the window.
  ///
  /// 窗口的初始纵坐标
  final double? dy;

  /// Controls whether the top control bar is displayed.
  /// Defaults to true.
  ///
  /// 控制顶部控制栏是否显示。
  /// 默认为true。
  final bool showControls;

  /// Controls whether the modal is displayed.
  /// Defaults to true.
  ///
  /// 控制modal是否显示。
  /// 默认为true。
  final bool showModal;

  /// Can the window be dragged.
  /// Default to true.
  ///
  /// 窗口是否可以被拖动。
  /// 默认为true。
  final bool drag;

  /// Callback triggered when the window is closed.
  ///
  /// 窗口关闭时触发。
  final VoidCallback? onClose;

  /// Callback triggered when the window is minimized.
  ///
  /// 窗口缩小时触发。
  final VoidCallback? onMinimize;

  /// Constructs a [ManaFloatingWindow].
  ///
  /// 构造函数。
  const ManaFloatingWindow({
    super.key,
    required this.name,
    required this.body,
    this.modal,
    this.initialWidth,
    this.initialHeight,
    this.position = PositionType.normal,
    this.dx,
    this.dy,
    this.showControls = true,
    this.showModal = true,
    this.drag = true,
    this.onClose,
    this.onMinimize,
  });

  @override
  State<ManaFloatingWindow> createState() => _ManaFloatingWindowState();
}

class _ManaFloatingWindowState extends State<ManaFloatingWindow> {
  /// Initial scale for the window animation.
  ///
  /// 窗口动画的初始缩放比例。
  static const double _initialScale = 0.6;

  /// Tracks the current offset (position) of the window.
  ///
  /// 跟踪窗口当前的位置偏移量。
  Offset _currentOffset = Offset.zero;

  /// Tracks whether the drag handle is pressed, for animation effects.
  ///
  /// 跟踪拖动条是否被按住的状态，用于动画效果。
  bool _isHandlePressed = false;

  /// Controls the visibility of the window itself, for fade-in/out animation.
  ///
  /// 控制窗口自身的可见性，用于淡入淡出动画。
  bool _isVisible = false;

  /// Whether the window is currently in full-screen mode.
  ///
  /// 窗口是否全屏。
  bool _isFullscreen = false;

  /// Controls whether the window is currently closing, to prevent multiple pop triggers.
  ///
  /// 控制是否正在关闭窗口，防止多次触发pop。
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();

    // Adds a listener to the [ManaPluginManager] to rebuild the UI when plugin events occur.
    // 向 [ManaPluginManager] 添加一个监听器，以便在插件事件发生时重建 UI。
    ManaPluginManager.instance.addListener(_handlePluginEvent);

    // Executes after the first frame is rendered, used to calculate the initial
    // centered position of the window and trigger fade-in and scale animations.
    //
    // 在第一帧渲染完成后执行，用于计算窗口的初始居中位置并触发淡入和缩放动画。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateInitialPosition();
      setState(() {
        _isVisible = true; // Triggers window fade-in and scale animation.
      });
    });
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

  /// Calculates the actual size of the window based on initial width/height or screen dimensions.
  ///
  /// 根据初始宽度/高度或屏幕尺寸计算窗口的实际大小。
  Size _getWindowActualSize(Size screenSize) {
    double width = widget.initialWidth ?? 0;
    if (widget.initialWidth == null) {
      width = (screenSize.width * 0.6).clamp(300, 600);
    } else if (widget.initialWidth == double.infinity) {
      width = screenSize.width;
    }
    double height = widget.initialHeight ?? 0;
    if (widget.initialHeight == null) {
      height = screenSize.height * 0.6;
    } else if (widget.initialHeight == double.infinity) {
      height = screenSize.height;
    }
    return Size(width, height);
  }

  /// Calculates the initial centered position of the window.
  ///
  /// 计算窗口的初始居中位置。
  void _calculateInitialPosition() {
    final Size screenSize = MediaQuery.of(context).size;
    final Size windowSize = _getWindowActualSize(screenSize);

    final dx = widget.dx ?? (screenSize.width - windowSize.width) / 2;
    double dy = 0;

    switch (widget.position) {
      case PositionType.normal:
        dy = widget.dy ?? (screenSize.height - windowSize.height) / 2;

      case PositionType.top:
        dy = 100;

      case PositionType.bottom:
        dy = screenSize.height - windowSize.height;
    }

    setState(() {
      _currentOffset = Offset(dx, dy);
    });
  }

  /// Updates the window's position when dragged, clamping it within screen boundaries.
  ///
  /// 当拖动更新时，更新窗口位置并限制在屏幕边界内。
  void _onPanUpdate(DragUpdateDetails details) {
    final Size screenSize = MediaQuery.of(context).size;
    final Size windowSize = _getWindowActualSize(screenSize);

    setState(() {
      // Update position.
      // 更新位置。
      _currentOffset += details.delta;

      // Clamp X-axis position within screen bounds.
      // 限制X轴位置在屏幕范围内。
      _currentOffset = Offset(_currentOffset.dx.clamp(0.0, screenSize.width - windowSize.width), _currentOffset.dy);

      // Clamp Y-axis position within screen bounds.
      // 限制Y轴位置在屏幕范围内。
      _currentOffset = Offset(_currentOffset.dx, _currentOffset.dy.clamp(0.0, screenSize.height - windowSize.height));
    });
  }

  /// Callback for full-screen action.
  ///
  /// 全屏回调。
  void _onFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  /// Callback for minimize action.
  ///
  /// 最小化回调。
  void _onMinimize() {
    widget.onMinimize?.call();
    if (widget.name == ManaPluginManager.name) {
      ManaPluginManager.instance.setManaPluginManagerVisibility(false);
    } else {
      ManaPluginManager.instance.setManaPluginManagerMainVisibility(false);
    }
  }

  /// Callback for closing the window.
  ///
  /// 关闭窗口的回调。
  void _onClose() {
    // If already closing, do nothing.
    // 如果已经正在关闭，则不执行任何操作。
    if (_isClosing) {
      return;
    }
    _isClosing = true;

    setState(() {
      _isVisible = false;
    });
    // After the animation completes, remove the window from the navigation stack.
    // 动画结束后，从路由栈中移除窗口。
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onClose?.call();
        if (widget.name == ManaPluginManager.name) {
          ManaPluginManager.instance.setManaPluginManagerVisibility(false);
        }
        ManaPluginManager.instance.deactivateManaPluggable(ManaPluginManager.instance.activatedManaPluggable);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final Size windowSize = _getWindowActualSize(screenSize);

    final double currentLeft = _isFullscreen ? 0 : _currentOffset.dx;
    final double currentTop = _isFullscreen ? 0 : _currentOffset.dy;
    final double currentWidth = _isFullscreen ? screenSize.width : windowSize.width;
    final double currentHeight = _isFullscreen ? screenSize.height : windowSize.height;

    return Stack(
      children: [
        // Transparent clickable layer filling the entire container.
        // AnimatedOpacity is used for fade-in/out of the clickable layer,
        // enhancing the window closing animation.
        // 充满整个容器的透明点击层。
        // AnimatedOpacity用于点击层淡入淡出，增加关闭窗口的动画效果。
        if (widget.showModal)
          widget.modal ??
              AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: _onMinimize, // Tap transparent layer to minimize window.
                  // 点击透明层关闭窗口。
                  child: Container(
                    color: Colors.transparent, // Nearly transparent, but captures tap events.
                    // 近乎透明，但能捕获点击事件。
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

        if (ManaPluginManager.instance.manaPluginManagerWindowMainVisibility)
          Positioned(
            left: currentLeft,
            top: currentTop,
            width: currentWidth,
            height: currentHeight,
            child: AnimatedOpacity(
              // Controls the overall fade-in/out of the window.
              // 控制窗口整体的淡入淡出。
              opacity: _isVisible ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: AnimatedScale(
                // Controls the window scaling from small to large from the center.
                // 控制窗口从中心由小到大缩放。
                scale: _isVisible ? 1.0 : _initialScale,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                alignment: Alignment.center,
                child: Material(
                  elevation: 8,
                  borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: ClipRRect(
                    borderRadius: _isFullscreen ? BorderRadius.zero : BorderRadius.circular(8),
                    child: Container(
                      color: Colors.white,
                      child: SafeArea(
                        left: _isFullscreen,
                        top: _isFullscreen,
                        right: _isFullscreen,
                        bottom: _isFullscreen,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Top control bar, visibility determined by showControls.
                            // 顶部控制栏，根据showControls决定是否显示。
                            if (widget.showControls)
                              _WindowControls(
                                drag: widget.drag,
                                isFullscreen: _isFullscreen,
                                isHandlePressed: _isHandlePressed && !_isFullscreen,
                                // Set _isHandlePressed to true on drag start, false on drag end.
                                // 拖动开始时设置_isHandlePressed为true，结束时设置为false。
                                onHandlePanStart: () => setState(() => _isHandlePressed = true),
                                onHandlePanEnd: () => setState(() => _isHandlePressed = false),
                                onPanUpdate: _onPanUpdate,
                                onFullscreen: _onFullscreen,
                                onMinimize: _onMinimize,
                                onClose: _onClose,
                              ),
                            // Main content area.
                            // 主体内容区域。
                            Expanded(child: widget.body),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// A sub-widget for the top control bar of the window.
///
/// Contains full-screen, minimize, drag handle, and close buttons.
///
/// 顶部控制栏小组件。
/// 包含全屏、缩小、拖动控件和关闭按钮。
class _WindowControls extends StatelessWidget {
  /// Can the window be dragged.
  /// Default to true.
  ///
  /// 窗口是否可以被拖动。
  /// 默认为true。
  final bool drag;

  /// Whether the window is in full-screen mode.
  ///
  /// 是否处于全屏状态。
  final bool isFullscreen;

  /// Whether the drag handle is currently pressed.
  ///
  /// 拖动控件是否被按住的状态。
  final bool isHandlePressed;

  /// Callback for when the drag handle starts being dragged.
  ///
  /// 拖动控件拖动开始的回调。
  final VoidCallback onHandlePanStart;

  /// Callback for when the drag handle stops being dragged.
  ///
  /// 拖动控件拖动结束的回调。
  final VoidCallback onHandlePanEnd;

  /// Callback for when the drag handle is being dragged (updates position).
  ///
  /// 拖动控件拖动更新的回调。
  final GestureDragUpdateCallback onPanUpdate;

  /// Callback triggered when the window goes full-screen.
  ///
  /// 窗口全屏时触发。
  final VoidCallback onFullscreen;

  /// Callback triggered when the window is minimized.
  ///
  /// 窗口缩小时触发。
  final VoidCallback onMinimize;

  /// Callback for the close button tap.
  ///
  /// 关闭按钮点击回调。
  final VoidCallback onClose;

  /// Constructs a [_WindowControls] widget.
  ///
  /// 构造函数。
  const _WindowControls({
    required this.drag,
    required this.isFullscreen,
    required this.isHandlePressed,
    required this.onHandlePanStart,
    required this.onHandlePanEnd,
    required this.onPanUpdate,
    required this.onFullscreen,
    required this.onMinimize,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(0),
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        // BorderRadius is not set here because the outer Material and ClipRRect
        // already handle the rounded corners.
        // 这里不设置borderRadius，因为外部的Material和ClipRRect已经处理了圆角。
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left buttons: Fullscreen / Minimize.
          // 左侧按钮：全屏 / 缩小。
          Flexible(
            fit: FlexFit.tight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen, size: 18, color: Colors.black54),
                  onPressed: onFullscreen,
                ),
                IconButton(
                  icon: const Icon(Icons.remove, size: 18, color: Colors.black54),
                  onPressed: onMinimize,
                ),
              ],
            ),
          ),

          if (drag)
            // Central draggable area (drag handle), wrapped in a transparent container
            // to increase the clickable area.
            // 中间可拖动区域（拖动控件），由透明容器包裹，增加可点击区域。
            Flexible(
              // Use Flexible to let it occupy the remaining space.
              // 使用Flexible让其占据剩余空间。
              fit: FlexFit.tight,
              child: GestureDetector(
                onPanStart: (details) => onHandlePanStart(),
                onPanEnd: (details) => onHandlePanEnd(),
                onPanUpdate: onPanUpdate,
                child: Container(
                  color: Colors.transparent,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    height: isHandlePressed ? 6 : 4,
                    width: isHandlePressed ? 60 : 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(isHandlePressed ? 3 : 2),
                    ),
                  ),
                ),
              ),
            ),

          Flexible(
            fit: FlexFit.tight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Right close button.
                // 右侧关闭按钮。
                IconButton(
                  icon: const Icon(Icons.close, size: 18, color: Colors.black54),
                  onPressed: onClose,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
