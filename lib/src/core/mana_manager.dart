import 'package:flutter/cupertino.dart';

import 'mana_state.dart';

/// An InheritedNotifier that provides access to a [ManaState] object down the widget tree.
///
/// 一个 InheritedNotifier，用于在 widget 树中向下提供 [ManaState] 对象的访问。
class ManaManager extends InheritedNotifier<ManaState> {
  /// Creates a [ManaManager].
  ///
  /// 创建一个 [ManaManager] 实例。
  const ManaManager({super.key, super.notifier, required super.child});

  /// Retrieves the [ManaState] from the nearest [ManaManager] in the widget tree.
  ///
  /// 从 widget 树中最近的 [ManaManager] 获取 [ManaState]。
  ///
  /// Throws an assertion error if no [ManaManager] is found.
  /// 如果没有找到 [ManaManager]，则抛出断言错误。
  static ManaState of(BuildContext context) {
    final ManaManager? result = context.dependOnInheritedWidgetOfExactType<ManaManager>();
    assert(result != null, 'Not found ManaManager');
    return result!.notifier!;
  }
}
