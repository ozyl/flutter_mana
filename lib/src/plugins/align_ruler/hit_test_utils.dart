import 'package:flutter/rendering.dart';
import 'package:flutter_mana/flutter_mana.dart'; // 确保这里可以访问到 manaRootKey

/// `HitTestUtils` 是一个用于执行 Flutter UI 树命中测试的工具类。
/// 它能够根据给定的屏幕坐标点，找出该点下方有哪些渲染对象（RenderObject）。
/// 这对于实现 UI 调试工具，例如元素检查器或对齐标尺等功能至关重要。
class HitTestUtils {
  /// 在给定的屏幕坐标 [position] 处执行命中测试。
  ///
  /// 该方法会从应用程序的根渲染对象开始，递归地遍历渲染树，
  /// 查找所有包含 [position] 的 RenderObject。
  ///
  /// 返回的 [RenderObject] 列表会根据其绘制区域的面积进行排序，
  /// 面积最小的（通常是层级最深、最具体的部件）排在列表的前面。
  ///
  /// 参数:
  ///   [position]: 进行命中测试的全局屏幕坐标。
  ///
  /// 返回值:
  ///   一个包含所有命中 RenderObject 的列表，按面积从小到大排序。
  static List<RenderObject> hitTest(Offset position) {
    final List<RenderObject> hitResults = <RenderObject>[];
    // 通过 ManaWidget 提供的全局 Key 获取应用程序的根 RenderObject。
    // 这是访问整个渲染树的入口点。
    final RenderObject? rootRenderObject = manaRootKey.currentContext?.findRenderObject();

    // 只有当根 RenderObject 是一个 RenderBox（大多数可见 UI 元素都是）时，
    // 我们才能执行盒模型的命中测试。
    if (rootRenderObject is RenderBox) {
      // BoxHitTestResult 是 RenderBox 专用的命中测试结果收集器。
      // 它能够更精确地处理盒模型的命中信息。
      final BoxHitTestResult result = BoxHitTestResult();
      // 调用根 RenderBox 的 hitTest 方法，开始递归遍历渲染树。
      rootRenderObject.hitTest(result, position: position);

      // 遍历命中测试结果的路径，提取所有 RenderObject。
      // 路径从根到叶子节点，包含所有被命中的 RenderObject。
      for (final HitTestEntry entry in result.path) {
        if (entry.target is RenderObject) {
          hitResults.add(entry.target as RenderObject);
        }
      }
    }

    // 对命中结果进行排序。
    // 按照 RenderObject 语义边界的面积进行升序排序。
    // 这样做的目的是，当我们想要吸附到“最近”或“最具体”的部件时，
    // 通常是面积最小的那个部件。
    hitResults.sort((a, b) {
      final Size sizeA = a.semanticBounds.size;
      final Size sizeB = b.semanticBounds.size;
      final double areaA = sizeA.width * sizeA.height;
      final double areaB = sizeB.width * sizeB.height;
      return areaA.compareTo(areaB);
    });

    return hitResults;
  }
}
