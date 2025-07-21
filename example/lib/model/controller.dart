import 'package:flutter/material.dart';

class ModalController extends ChangeNotifier {
  ModalController({this.duration = const Duration(milliseconds: 2000)});

  final Duration duration;
  late final AnimationController _ac;

  Animation<double> get animation => _ac.view;
  bool get isOpen => _ac.value == 1;

  void attach(TickerProvider vsync) {
    _ac = AnimationController(vsync: vsync, duration: duration);
    _ac.addListener(notifyListeners);
  }

  void detach() {
    _ac.removeListener(notifyListeners);
    _ac.dispose();
  }

  Future<void> show() => _ac.forward();
  Future<void> hide() => _ac.reverse();
}
