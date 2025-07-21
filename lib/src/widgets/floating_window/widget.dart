import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';
import 'package:flutter_mana/src/widgets/floating_window/window_controls.dart';
import 'package:flutter_mana/src/widgets/nil.dart';

import 'controller.dart';

class FloatingWindow extends StatefulWidget {
  /// 名称
  final String name;

  /// 内容区域
  final Widget? content;

  /// 遮罩层
  final Widget? barrier;

  /// 设置页组件
  final Widget? setting;

  /// 初始宽度
  final double? initialWidth;

  /// 初始高度
  final double? initialHeight;

  /// 初始位置类型
  final PositionType position;

  /// 自定义初始坐标
  final Offset? initialPosition;

  /// 是否展示控制栏
  final bool showControls;

  /// 是否显示遮罩
  final bool showBarrier;

  /// 是否允许拖拽
  final bool drag;

  /// 关闭回调
  final VoidCallback? onClose;

  /// 最小化回调
  final VoidCallback? onMinimize;

  const FloatingWindow({
    super.key,
    required this.name,
    this.content,
    this.barrier,
    this.setting,
    this.initialWidth,
    this.initialHeight,
    this.position = PositionType.normal,
    this.initialPosition,
    this.showControls = true,
    this.showBarrier = true,
    this.drag = true,
    this.onClose,
    this.onMinimize,
  });

  @override
  State<FloatingWindow> createState() => _FloatingWindowState();
}

class _FloatingWindowState extends State<FloatingWindow> with TickerProviderStateMixin {
  late final FloatingWindowController _controller;

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) {
      _controller.update(context);
      return;
    }
    _controller = FloatingWindowController(
      context,
      this,
      name: widget.name,
      position: widget.position,
      initialPosition: widget.initialPosition,
      initialWidth: widget.initialWidth,
      initialHeight: widget.initialHeight,
    );
    _initialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 构建barrier
  Widget _buildBarrier() {
    return widget.barrier ??
        RepaintBoundary(
          child: FadeTransition(
            opacity: _controller.animation,
            child: GestureDetector(
              onTap: () => _controller.onMinimize(widget.onMinimize),
              behavior: HitTestBehavior.opaque,
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        );
  }

  Widget _buildWindowContent(Size screenSize, Size windowSize, bool fullscreen) {
    final radius =
        (fullscreen || widget.initialHeight == double.infinity) ? BorderRadius.zero : BorderRadius.circular(8);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(50),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: SafeArea(
        left: fullscreen,
        top: fullscreen || widget.initialHeight == double.infinity,
        right: fullscreen,
        bottom: fullscreen || widget.position == PositionType.bottom,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showControls)
              WindowControls(
                  drag: widget.drag,
                  isFullscreen: fullscreen,
                  showSettingButton: widget.setting != null,
                  onPanUpdate: _controller.onPanUpdate,
                  onToggleSetting: _controller.onToggleSetting,
                  onFullscreen: _controller.onFullscreen,
                  onMinimize: () => _controller.onMinimize(widget.onMinimize),
                  onClose: () => _controller.onClose(widget.onClose)),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _controller.showSetting,
                builder: (context, showSetting, _) {
                  if (showSetting && widget.setting != null) {
                    return widget.setting ?? SizedBox();
                  }
                  return widget.content ?? SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Size screenSize, Size windowSize, bool fullscreen) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller.animation,
        builder: (_, child) {
          return Transform.scale(
            scale: 0.8 + 0.2 * _controller.animation.value,
            child: FadeTransition(
              opacity: _controller.animation,
              child: child,
            ),
          );
        },
        child: _buildWindowContent(screenSize, windowSize, fullscreen),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // 拦截返回
      onPopInvokedWithResult: (bool didPop, void result) {
        if (!didPop) {
          if (_controller.manaState.activePluginName.value.isEmpty) {
            _controller.manaState.pluginManagementPanelVisible.value = false;
            return;
          }
          _controller.manaState.floatWindowMainVisible.value = false;
        }
      },
      child: Stack(
        children: [
          if (widget.showBarrier) _buildBarrier(),
          ValueListenableBuilder(
            valueListenable: _controller.manaState.floatWindowMainVisible,
            builder: (context, visible, _) {
              return visible
                  ? ValueListenableBuilder(
                      valueListenable: _controller.fullscreen,
                      builder: (context, fullscreen, _) {
                        return ValueListenableBuilder(
                          valueListenable: _controller.offset,
                          builder: (context, offset, _) {
                            final double currentLeft = fullscreen ? 0 : offset.dx;
                            final double currentTop = fullscreen ? 0 : offset.dy;
                            final double currentWidth =
                                fullscreen ? _controller.screenSize.width : _controller.windowSize.width;
                            final double currentHeight =
                                fullscreen ? _controller.screenSize.height : _controller.windowSize.height;

                            return Positioned(
                              left: currentLeft,
                              top: currentTop,
                              width: currentWidth,
                              height: currentHeight,
                              child: _buildContent(_controller.screenSize, _controller.windowSize, fullscreen),
                            );
                          },
                        );
                      },
                    )
                  : nilPosition;
            },
          ),
        ],
      ),
    );
  }
}
