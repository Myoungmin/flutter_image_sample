import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageMatrixProvider =
    NotifierProvider<ImageMatrixNotifier, Matrix4>(ImageMatrixNotifier.new);

class ImageMatrixNotifier extends Notifier<Matrix4> {
  @override
  Matrix4 build() => Matrix4.identity();

  void rotate90Degrees() {
    final currentMatrix = state.clone();
    final rotation = Matrix4.identity()..rotateZ(90 * 3.1415927 / 180);
    state = currentMatrix.multiplied(rotation);
  }

  void translateByOffset(Offset offset) {
    final currentMatrix = state.clone();
    final translation = Matrix4.identity()..translate(offset.dx, offset.dy);
    state = currentMatrix.multiplied(translation);
  }

  void scaleByFactor(double scaleFactor) {
    final currentMatrix = state.clone();
    final scaling = Matrix4.identity()..scale(scaleFactor, scaleFactor);
    state = currentMatrix.multiplied(scaling);
  }
}
