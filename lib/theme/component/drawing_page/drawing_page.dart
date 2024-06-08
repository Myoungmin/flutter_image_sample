import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GestureView(
              onPanStart: (DragStartDetails details) {},
              onPanUpdate: (DragUpdateDetails details) {},
              onPanEnd: (DragEndDetails details) {},
              onSecondaryTapDown: (TapDownDetails details) {},
              onPointerSignal: (PointerSignalEvent details) {},
              onHover: (PointerEvent details) {},
            ),
          ),
        ],
      ),
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
