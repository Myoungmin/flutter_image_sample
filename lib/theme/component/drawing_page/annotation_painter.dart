import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/annotation.dart';

class AnnotationPainter extends CustomPainter {
  final List<Annotation> annotations;
  final ui.Image? image;

  AnnotationPainter({
    required this.annotations,
    this.image,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      Rect imageRect = Rect.fromLTWH(
        0,
        0,
        image!.width.toDouble(),
        image!.height.toDouble(),
      );
      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: image!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }

    for (var element in annotations) {
      element.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.annotations != annotations;
  }
}
