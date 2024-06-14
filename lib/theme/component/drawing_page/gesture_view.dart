import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/annotation.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/annotation_painter.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/image_loader.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/image_matrix_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GestureView extends ConsumerWidget {
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final void Function(TapDownDetails) onSecondaryTapDown;
  final void Function(PointerSignalEvent) onPointerSignal;
  final void Function(PointerEvent) onHover;

  const GestureView({
    Key? key,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onSecondaryTapDown,
    required this.onPointerSignal,
    required this.onHover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<Annotation> annotations = ref.watch(annotationListProvider);
    final ui.Image? image = ref.watch(imageLoaderProvider);
    final Matrix4 imageMatrix = ref.watch(imageMatrixProvider);

    if (image == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final double imageWidth = image.width.toDouble();
    final double imageHeight = image.height.toDouble();

    return Listener(
      onPointerSignal: onPointerSignal,
      child: MouseRegion(
        onHover: onHover,
        child: GestureDetector(
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          onPanEnd: onPanEnd,
          onSecondaryTapDown: onSecondaryTapDown,
          child: Transform(
            transform: imageMatrix,
            alignment: Alignment.center,
            child: CustomPaint(
              painter: AnnotationPainter(
                annotations: annotations,
                image: image,
              ),
              child: SizedBox(
                width: imageWidth,
                height: imageHeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
