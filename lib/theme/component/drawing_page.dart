import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum DrawingMode { point, line, rectangle, pan, magnify }

class DrawingPage extends StatefulWidget {
  final ImageProvider imageProvider;

  const DrawingPage({Key? key, required this.imageProvider}) : super(key: key);

  @override
  DrawingPageState createState() => DrawingPageState();
}

class DrawingPageState extends State<DrawingPage> {
  final AnnotationController controller = AnnotationController();
  ui.Image? image;
  late ImageStreamListener _imageStreamListener;

  @override
  void initState() {
    super.initState();
    _imageStreamListener = ImageStreamListener(onImageLoaded);
    addImageListener();
  }

  void setImageState(ui.Image newImage) {
    setState(() {
      image = newImage;
    });
  }

  void onImageLoaded(ImageInfo info, bool _) {
    setState(() {
      setImageState(info.image);
    });
  }

  Future<void> addImageListener() async {
    widget.imageProvider
        .resolve(const ImageConfiguration())
        .addListener(_imageStreamListener);
  }

  @override
  void dispose() {
    widget.imageProvider
        .resolve(const ImageConfiguration())
        .removeListener(_imageStreamListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: DrawingCanvas(
              controller: controller,
              image: image,
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

class DrawingCanvas extends StatelessWidget {
  final AnnotationController controller;
  final ui.Image? image;
  final void Function(DragStartDetails) onPanStart;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragEndDetails) onPanEnd;
  final void Function(TapDownDetails) onSecondaryTapDown;
  final void Function(PointerSignalEvent) onPointerSignal;
  final void Function(PointerEvent) onHover;

  const DrawingCanvas({
    Key? key,
    required this.controller,
    this.image,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.onSecondaryTapDown,
    required this.onPointerSignal,
    required this.onHover,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            transform: Matrix4.identity()..rotateZ(0 * 3.1415927 / 180),
            alignment: Alignment.center,
            child: CustomPaint(
              painter: AnnotationPainter(
                controller: controller,
                image: image,
              ),
              child: const Center(),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class Annotation {
  Paint paint;
  Annotation(this.paint);
  void draw(Canvas canvas);
  bool contains(Offset position);
}

class PointAnnotation extends Annotation {
  Offset point;
  static const double pointTolerance = 5.0;
  PointAnnotation(this.point, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas) {
    canvas.drawPoints(
      ui.PointMode.points,
      [point],
      paint,
    );
  }

  @override
  bool contains(Offset position) {
    return (point - position).distance <= pointTolerance;
  }
}

class LineAnnotation extends Annotation {
  Offset start;
  Offset end;
  static const double lineTolerance = 5.0;
  LineAnnotation(this.start, this.end, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas) {
    canvas.drawLine(
      start,
      end,
      paint,
    );
  }

  @override
  bool contains(Offset position) {
    double distance = distanceToLineSegment(
      position,
      start,
      end,
    );
    return distance <= lineTolerance;
  }

  double distanceToLineSegment(Offset point, Offset start, Offset end) {
    // 선분 start-end의 길이의 제곱을 계산합니다.
    double segmentLengthSquared = (start - end).dx * (start - end).dx +
        (start - end).dy * (start - end).dy;

    // 선분의 시작점과 끝점이 동일한 경우, 점 point에서 start까지의 거리를 반환합니다.
    if (segmentLengthSquared == 0.0) {
      return (point - start).distance;
    }

    // 점 point에서 선분 start-end까지의 최단 거리 비율 t를 계산합니다.
    double t = ((point - start).dx * (end - start).dx +
            (point - start).dy * (end - start).dy) /
        segmentLengthSquared;

    // t 값을 0과 1 사이로 클램프하여 투영점이 선분 start-end 내에 있도록 합니다.
    t = t.clamp(0.0, 1.0);

    // t 값을 사용하여 선분 start-end 상의 투영점을 계산합니다.
    Offset projection = Offset(
        start.dx + t * (end.dx - start.dx), start.dy + t * (end.dy - start.dy));

    // 점 point와 투영점 사이의 거리를 반환합니다.
    return (point - projection).distance;
  }
}

class RectAnnotation extends Annotation {
  Offset start;
  Offset end;
  static const double rectTolerance = 5.0;
  RectAnnotation(this.start, this.end, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas) {
    canvas.drawRect(
      Rect.fromPoints(
        start,
        end,
      ),
      paint,
    );
  }

  @override
  bool contains(Offset position) {
    Rect rect = Rect.fromPoints(start, end);
    Rect expandedRect = rect.inflate(rectTolerance);
    Rect contractedRect = rect.deflate(rectTolerance);
    return expandedRect.contains(position) &&
        !contractedRect.contains(position);
  }
}

class AnnotationController {
  List<Annotation> annotations = [];

  void addAnnotation(Annotation annotation) => annotations.add(annotation);
  void removeAnnotationAtPosition(Offset position) {
    annotations.removeWhere((annotation) => annotation.contains(position));
  }

  void clear() => annotations.clear();
}

class AnnotationPainter extends CustomPainter {
  final AnnotationController controller;
  final ui.Image? image;

  AnnotationPainter({
    required this.controller,
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

    for (var element in controller.annotations) {
      element.draw(canvas);
    }
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.controller.annotations != controller.annotations;
  }
}
