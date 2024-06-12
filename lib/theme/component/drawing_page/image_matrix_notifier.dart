import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageMatrixProvider =
    NotifierProvider<ImageMatrixNotifier, Matrix4>(ImageMatrixNotifier.new);

class ImageMatrixNotifier extends Notifier<Matrix4> {
  @override
  Matrix4 build() => Matrix4.identity();

  void rotate90Degrees() {
    final currentMatrix = state.clone();

    state = currentMatrix..rotateZ(90 * 3.1415927 / 180);
  }

  void translateByOffset(Offset offset) {
    final currentMatrix = state.clone();

    // translation 부분만 초기화
    currentMatrix.setTranslationRaw(0, 0, 0);

    state = currentMatrix..translate(offset.dx, offset.dy);
  }

  void scaleByFactor(double scaleFactor) {
    final currentMatrix = state.clone();

    // scale 부분만 초기화
    currentMatrix.setEntry(0, 0, 1.0);
    currentMatrix.setEntry(1, 1, 1.0);
    currentMatrix.setEntry(2, 2, 1.0);

    state = currentMatrix..scale(scaleFactor, scaleFactor);
  }
}
