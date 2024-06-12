import 'package:flutter/material.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/gesture_controller.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/gesture_view.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/image_loader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DrawingMode { none, point, line, rectangle, pan, magnify }

class DrawingPage extends ConsumerWidget {
  final ImageProvider imageProvider;

  const DrawingPage({Key? key, required this.imageProvider}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.read(imageLoaderProvider.notifier).loadImage(imageProvider);
    GestureController gestureController = ref.read(gestureControllerProvider);

    return GestureView(
      onPanStart: gestureController.onPanStart,
      onPanUpdate: gestureController.onPanUpdate,
      onPanEnd: gestureController.onPanEnd,
      onSecondaryTapDown: gestureController.onSecondaryTapDown,
      onPointerSignal: gestureController.onPointerSignal,
      onHover: gestureController.onHover,
    );
  }
}

final drawingModeProvider =
    NotifierProvider<DrawingModeController, DrawingMode>(
        DrawingModeController.new);

class DrawingModeController extends Notifier<DrawingMode> {
  @override
  DrawingMode build() => DrawingMode.none;
}
