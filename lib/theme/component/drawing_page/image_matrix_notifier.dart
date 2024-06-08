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
}
