import 'package:flutter/material.dart';
import 'package:flutter_mana/flutter_mana.dart';

import 'screen_pixel_grabber.dart';

class ColorSucker extends StatefulWidget {
  /// 放大镜半径
  final double magnifierRadius;

  /// 放大镜边框颜色
  final Color borderColor;

  /// 放大镜边框粗细
  final double borderWidth;

  /// 放大镜放大倍数
  final double magnification;

  /// 默认拖动位置（全局坐标，建议居中）
  final Offset? initialPosition;

  /// 拾色结果回调
  final ValueChanged<Color>? onColorChanged;

  const ColorSucker({
    super.key,
    this.magnifierRadius = 50,
    this.borderColor = Colors.grey,
    this.borderWidth = 2,
    this.magnification = 10.0,
    this.initialPosition,
    this.onColorChanged,
  });

  @override
  State<ColorSucker> createState() => _ColorSuckerState();
}

class _ColorSuckerState extends State<ColorSucker> {
  Offset? _dragPosition;
  late ScreenPixelGrabber _pixelGrabber;

  @override
  void initState() {
    super.initState();
    _pixelGrabber = ScreenPixelGrabber(repaintBoundaryKey: manaRootKey);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeColorSucker();
    });
  }

  // 获取屏幕尺寸和默认中心位置
  Offset _getDefaultCenterPosition() {
    final Size screenSize = MediaQuery.sizeOf(context);
    return widget.initialPosition ??
        Offset(
          screenSize.width / 2,
          screenSize.height / 2,
        );
  }

  Future<void> _initializeColorSucker() async {
    final double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    await _pixelGrabber.captureImage(pixelRatio: devicePixelRatio);

    // 初始化放大镜位置并触发第一次颜色拾取
    if (mounted) {
      // 获取屏幕尺寸和默认中心位置
      final defaultCenterPosition = _getDefaultCenterPosition();

      // 确保组件仍然在树中
      setState(() {
        _dragPosition = defaultCenterPosition;
      });
      _onUpdate(defaultCenterPosition); // 首次获取中心的颜色
    }
  }

  /// 拖动时更新放大镜和采样颜色
  Future<void> _onUpdate(Offset globalPosition) async {
    setState(() {
      _dragPosition = globalPosition;
    });
    // 使用 _pixelGrabber 获取颜色
    final color = await _pixelGrabber.getColorAt(globalPosition);
    if (color != null) {
      widget.onColorChanged?.call(color);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 确保 defaultDragPosition 在 build 方法中被正确计算
    final defaultDragPosition = _getDefaultCenterPosition();

    final dragPosition = _dragPosition ?? defaultDragPosition;

    return GestureDetector(
      onPanDown: (details) => _onUpdate(details.globalPosition),
      onPanUpdate: (details) => _onUpdate(details.globalPosition),
      child: Stack(
        children: [
          Positioned(
            left: dragPosition.dx - widget.magnifierRadius,
            top: dragPosition.dy - widget.magnifierRadius,
            child: RawMagnifier(
              size: Size(widget.magnifierRadius * 2, widget.magnifierRadius * 2),
              magnificationScale: widget.magnification,
              decoration: MagnifierDecoration(
                shape: CircleBorder(
                  side: BorderSide(color: widget.borderColor, width: widget.borderWidth),
                ),
              ),
              focalPointOffset: Offset.zero,
              // 提供一个可命中测试的透明Container
              child: Container(
                width: widget.magnifierRadius * 2,
                height: widget.magnifierRadius * 2,
                color: Colors.transparent,
                child: Center(
                  child: Container(
                    width: 15,
                    height: 15,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(
                        color: Colors.red,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
