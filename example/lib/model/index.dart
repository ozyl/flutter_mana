import 'package:flutter/material.dart';

import 'controller.dart';

class PureWhiteModal extends StatelessWidget {
  const PureWhiteModal({
    super.key,
    required this.controller,
    required this.child,
    this.barrierDismissible = true,
    this.barrierColor = Colors.black54,
  });

  final ModalController controller;
  final Widget child;
  final bool barrierDismissible;
  final Color barrierColor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (_, __) {
        return RepaintBoundary(
          child: controller.animation.value == 0
              ? const SizedBox.shrink()
              : Stack(
                  children: [
                    // 遮罩
                    RepaintBoundary(
                      child: FadeTransition(
                        opacity: controller.animation,
                        child: GestureDetector(
                          onTap: barrierDismissible ? controller.hide : null,
                          behavior: HitTestBehavior.opaque,
                          child: Container(color: barrierColor),
                        ),
                      ),
                    ),
                    // 内容
                    RepaintBoundary(
                      child: Center(
                        child: AnimatedBuilder(
                          animation: controller.animation,
                          builder: (_, __) {
                            return Transform.scale(
                              scale: 0.8 + 0.2 * controller.animation.value,
                              child: FadeTransition(
                                opacity: controller.animation,
                                child: Material(color: Colors.white, elevation: 24, child: child),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
