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

  void rotateByDirection(Direction direction) {
    final currentMatrix = state.clone();

    // rotate 부분을 초기화
    currentMatrix.setEntry(0, 0, 1.0);
    currentMatrix.setEntry(0, 1, 0.0);
    currentMatrix.setEntry(0, 2, 0.0);
    currentMatrix.setEntry(1, 0, 0.0);
    currentMatrix.setEntry(1, 1, 1.0);
    currentMatrix.setEntry(1, 2, 0.0);
    currentMatrix.setEntry(2, 0, 0.0);
    currentMatrix.setEntry(2, 1, 0.0);
    currentMatrix.setEntry(2, 2, 1.0);

    state = currentMatrix..rotateZ(direction.getAngle() * 3.1415927 / 180);
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

  void setMatrix(
      Offset offset, Direction direction, double scale, Offset imageCenter) {
    state = Matrix4.identity()
      ..translate(offset.dx, offset.dy)
      ..scale(scale)
      ..translate(imageCenter.dx, imageCenter.dy)
      ..rotateZ(direction.getAngle() * 3.1415927 / 180)
      ..translate(-imageCenter.dx, -imageCenter.dy);
  }
}

enum Direction {
  none(0),
  cw90(90),
  cw180(180),
  cw270(270);

  final int angle;
  const Direction(this.angle);

  int getAngle() => angle;
}
