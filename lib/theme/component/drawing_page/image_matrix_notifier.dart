import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageMatrixProvider =
    NotifierProvider<ImageMatrixNotifier, Matrix4>(ImageMatrixNotifier.new);

class ImageMatrixNotifier extends Notifier<Matrix4> {
  @override
  Matrix4 build() => Matrix4.identity();

  void setMatrix(
      Offset offset, Direction direction, double scale, Offset renderBoxCenter) {
    state = Matrix4.identity()
      ..translate(offset.dx, offset.dy)
      ..scale(scale)
      ..translate(renderBoxCenter.dx, renderBoxCenter.dy)
      ..rotateZ(direction.getAngle() * 3.1415927 / 180)
      ..translate(-renderBoxCenter.dx, -renderBoxCenter.dy);
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
