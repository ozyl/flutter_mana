import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart'; // For RenderRepaintBoundary

/// 这是一个通用的类，用于从屏幕上的特定Widget捕获图像并获取像素颜色。
class ScreenPixelGrabber {
  final GlobalKey repaintBoundaryKey;
  ui.Image? _capturedImage;

  ScreenPixelGrabber({required this.repaintBoundaryKey});

  /// 捕获由 [repaintBoundaryKey] 标识的Widget的图像。
  /// [pixelRatio] 定义了捕获图像的像素密度，通常使用 devicePixelRatio。
  Future<void> captureImage({required double pixelRatio}) async {
    try {
      final RenderRepaintBoundary? boundary =
          repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint("Error: Repaint boundary context is null or not a RenderRepaintBoundary.");
        _capturedImage = null; // 确保在错误时清除旧图像
        return;
      }

      _capturedImage = await boundary.toImage(pixelRatio: pixelRatio);
      debugPrint("Screenshot captured successfully!");
    } catch (e) {
      debugPrint("Error capturing screenshot: $e");
      _capturedImage = null;
    }
  }

  /// 获取捕获图像上某个全局坐标点的像素颜色。
  /// 如果图像未捕获或坐标超出范围，则返回null。
  Future<Color?> getColorAt(Offset globalPosition) async {
    if (_capturedImage == null) {
      debugPrint("Warning: No image captured yet to get color from.");
      return null;
    }

    final RenderBox? box = repaintBoundaryKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) {
      debugPrint("Warning: Repaint boundary context or RenderBox is null in getColorAt.");
      return null;
    }

    // 全局坐标转为图片局部坐标
    final Offset local = box.globalToLocal(globalPosition);

    // 获取截取时的像素比（假设图像宽度与RenderBox宽度匹配）
    final double pixelRatio = _capturedImage!.width / box.size.width;

    // 计算实际像素坐标，并确保不越界
    int px = (local.dx * pixelRatio).round().clamp(0, _capturedImage!.width - 1);
    int py = (local.dy * pixelRatio).round().clamp(0, _capturedImage!.height - 1);

    final ByteData? data = await _capturedImage!.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) {
      debugPrint("Error: Could not get byte data from image in getColorAt.");
      return null;
    }

    final int bytesPerPixel = 4; // RGBA
    final int offset = (py * _capturedImage!.width + px) * bytesPerPixel;

    // 再次进行边界检查以确保安全访问
    if (offset < 0 || offset + bytesPerPixel > data.lengthInBytes) {
      debugPrint(
          "Error: Pixel offset out of bounds in getColorAt. Offset: $offset, Data length: ${data.lengthInBytes}");
      return null;
    }

    final int r = data.getUint8(offset);
    final int g = data.getUint8(offset + 1);
    final int b = data.getUint8(offset + 2);
    final int a = data.getUint8(offset + 3);

    return Color.fromARGB(a, r, g, b);
  }
}
