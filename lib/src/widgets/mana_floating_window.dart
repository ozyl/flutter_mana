import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'nil.dart';

enum PositionType {
  normal,
  top,
  bottom,
}

class ManaFloatingWindow extends StatefulWidget {
  final String name;

  final Widget content;

  final Widget? barrier;

  final Widget? setting;

  final double? initialWidth;

  final double? initialHeight;

  final PositionType position;

  final double? dx;

  final double? dy;

  final bool showControls;

  final bool showBarrier;

  final bool minimizeShowBarrier;

  final bool drag;

  final VoidCallback? onClose;

  final VoidCallback? onMinimize;

  const ManaFloatingWindow({
    super.key,
    required this.name,
    required this.content,
    this.barrier,
    this.setting,
    this.initialWidth,
    this.initialHeight,
    this.position = PositionType.normal,
    this.dx,
    this.dy,
    this.showControls = true,
    this.showBarrier = true,
    this.minimizeShowBarrier = false,
    this.drag = true,
    this.onClose,
    this.onMinimize,
  });

  @override
  State<ManaFloatingWindow> createState() => _ManaFloatingWindowState();
}

class _ManaFloatingWindowState extends State<ManaFloatingWindow> {
  static const double _initialScale = 0.6;

  Offset _currentOffset = Offset.zero;

  bool _isHandlePressed = false;

  bool _isVisible = false;

  bool _isFullscreen = false;

  bool _isClosing = false;

  bool _showSetting = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateInitialPosition();
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

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
    } else if (widget.initialHeight != null && widget.initialHeight! > 0 && widget.initialHeight! < 1) {
      height = screenSize.height * widget.initialHeight!;
    }
    return Size(width, height);
  }

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

  void _onPanUpdate(DragUpdateDetails details) {
    final Size screenSize = MediaQuery.of(context).size;
    final Size windowSize = _getWindowActualSize(screenSize);

    setState(() {
      _currentOffset += details.delta;

      _currentOffset = Offset(_currentOffset.dx.clamp(0.0, screenSize.width - windowSize.width), _currentOffset.dy);

      _currentOffset = Offset(_currentOffset.dx, _currentOffset.dy.clamp(0.0, screenSize.height - windowSize.height));
    });
  }

  void _onFullscreen() {
    _isFullscreen = !_isFullscreen;
    final manaState = ManaScope.of(context);
    if (widget.name != ManaPluginManager.name) {
      manaState.floatActionButtonVisible.value = !_isFullscreen;
    }
    manaState.floatWindowMainFullscreen.value = _isFullscreen;
    setState(() {});
  }

  void _onMinimize() {
    widget.onMinimize?.call();
    final manaState = ManaScope.of(context);
    if (widget.name == ManaPluginManager.name) {
      manaState.pluginManagementPanelVisible.value = false;
    } else {
      manaState.floatWindowMainVisible.value = false;
    }
    manaState.floatActionButtonVisible.value = true;
  }

  void _onClose() {
    if (_isClosing) {
      return;
    }
    _isClosing = true;

    setState(() {
      _isVisible = false;
    });

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        widget.onClose?.call();
        final manaState = ManaScope.of(context);
        if (widget.name == ManaPluginManager.name) {
          manaState.pluginManagementPanelVisible.value = false;
        }
        manaState.activePluginName.value = '';
        manaState.floatActionButtonVisible.value = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final manaState = ManaScope.of(context);
    final Size screenSize = MediaQuery.of(context).size;
    final Size windowSize = _getWindowActualSize(screenSize);

    final double currentLeft = _isFullscreen ? 0 : _currentOffset.dx;
    final double currentTop = _isFullscreen ? 0 : _currentOffset.dy;
    final double currentWidth = _isFullscreen ? screenSize.width : windowSize.width;
    final double currentHeight = _isFullscreen ? screenSize.height : windowSize.height;

    return Stack(
      children: [
        if (widget.showBarrier)
          widget.barrier ??
              AnimatedOpacity(
                opacity: _isVisible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: GestureDetector(
                  onTap: _onMinimize,
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
        ValueListenableBuilder(
          valueListenable: manaState.floatWindowMainVisible,
          builder: (context, value, _) {
            return value
                ? Positioned(
                    left: currentLeft,
                    top: currentTop,
                    width: currentWidth,
                    height: currentHeight,
                    child: AnimatedOpacity(
                      opacity: _isVisible ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 300),
                      child: AnimatedScale(
                        scale: _isVisible ? 1.0 : _initialScale,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                        alignment: Alignment.center,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: (_isFullscreen || widget.initialHeight == double.infinity)
                                ? BorderRadius.zero
                                : BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 16,
                                spreadRadius: 0,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ClipRRect(
                            borderRadius: (_isFullscreen || widget.initialHeight == double.infinity)
                                ? BorderRadius.zero
                                : BorderRadius.circular(8),
                            child: Container(
                              color: Colors.white,
                              child: SafeArea(
                                left: _isFullscreen,
                                top: _isFullscreen || widget.initialHeight == double.infinity,
                                right: _isFullscreen,
                                bottom: _isFullscreen || widget.position == PositionType.bottom,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (widget.showControls)
                                      _WindowControls(
                                        drag: widget.drag && !_isFullscreen,
                                        isFullscreen: _isFullscreen,
                                        isHandlePressed: _isHandlePressed && !_isFullscreen,
                                        showSettingButton: widget.setting != null,
                                        onHandlePanStart: () => setState(() => _isHandlePressed = true),
                                        onHandlePanEnd: () => setState(() => _isHandlePressed = false),
                                        onToggleSetting: () => setState(() => _showSetting = !_showSetting),
                                        onPanUpdate: _onPanUpdate,
                                        onFullscreen: _onFullscreen,
                                        onMinimize: _onMinimize,
                                        onClose: _onClose,
                                      ),
                                    Expanded(
                                        child: (_showSetting && widget.setting != null)
                                            ? widget.setting!
                                            : widget.content),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : nilPosition;
          },
        ),
      ],
    );
  }
}

class _WindowControls extends StatelessWidget {
  final bool drag;

  final bool isFullscreen;

  final bool isHandlePressed;

  final bool showSettingButton;

  final VoidCallback onHandlePanStart;

  final VoidCallback onHandlePanEnd;

  final GestureDragUpdateCallback onPanUpdate;

  final VoidCallback onToggleSetting;

  final VoidCallback onFullscreen;

  final VoidCallback onMinimize;

  final VoidCallback onClose;

  const _WindowControls({
    required this.drag,
    required this.isFullscreen,
    required this.isHandlePressed,
    required this.showSettingButton,
    required this.onHandlePanStart,
    required this.onHandlePanEnd,
    required this.onPanUpdate,
    required this.onToggleSetting,
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
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
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
            Expanded(
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
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (showSettingButton)
                  IconButton(
                    icon: const Icon(Icons.settings, size: 18, color: Colors.black54),
                    onPressed: onToggleSetting,
                  ),
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
