import 'dart:ui' as ui;

import 'package:flutter/material.dart';

enum DrawingMode { point, line, rectangle, text, pan }

class DrawingPage extends StatefulWidget {
  final ImageProvider imageProvider;

  const DrawingPage({Key? key, required this.imageProvider}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final AnnotationController controller = AnnotationController();
  ui.Image? image;
  Offset lastPanPosition = Offset.zero;
  Offset dragStart = Offset.zero;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final resolver = ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        image = info.image;
      });
    });
    widget.imageProvider
        .resolve(const ImageConfiguration())
        .addListener(resolver);
  }

  void setMode(DrawingMode mode, Offset localPosition) {
    setState(() {
      controller.startingPoint = localPosition;
      controller.endingPoint = localPosition;
      controller.currentMode = mode;
    });
  }

  void updatePoints(Offset localPosition) {
    setState(() {
      controller.endingPoint = localPosition;
    });
  }

  void endDrawing() {
    setState(() {
      final paint = Paint()
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      switch (controller.currentMode) {
        case DrawingMode.point:
          if (controller.showPoint) {
            paint.color = Colors.red;
            controller
                .addAnnotation(PointAnnotation(controller.endingPoint, paint));
          }
          break;
        case DrawingMode.line:
          if (controller.showLine) {
            paint.color = Colors.green;
            controller.addAnnotation(LineAnnotation(
                controller.startingPoint, controller.endingPoint, paint));
          }
          break;
        case DrawingMode.rectangle:
          if (controller.showRect) {
            paint.color = Colors.blue;
            controller.addAnnotation(RectAnnotation(
                controller.startingPoint, controller.endingPoint, paint));
          }
          break;
        case DrawingMode.text:
          if (controller.showText) {
            controller.addAnnotation(
                TextAnnotation("Sample Text", controller.endingPoint, paint));
          }
          break;
        case DrawingMode.pan:
          break;
      }
    });
  }

  void clear() {
    setState(() {
      controller.clear();
    });
  }

  void onPanStart(DragStartDetails details) {
    if (controller.currentMode == DrawingMode.pan) {
      dragStart = details.localPosition;
      lastPanPosition = controller.imageOffset;
    } else {
      setMode(controller.currentMode, details.localPosition);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (controller.currentMode == DrawingMode.pan) {
      Offset delta = details.localPosition - dragStart;
      setState(() {
        controller.imageOffset = lastPanPosition + delta;
      });
    } else {
      updatePoints(details.localPosition);
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (controller.currentMode == DrawingMode.pan) {
      lastPanPosition = controller.imageOffset;
    } else {
      endDrawing();
    }
  }

  void onSecondaryTapDown(TapDownDetails details) {
    Offset position = details.localPosition;
    setState(() {
      controller.removeAnnotationAtPosition(position);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: MouseRegion(
              onHover: (PointerEvent event) => setState(() {
                controller.position =
                    'Mouse Position: x=${event.localPosition.dx.toInt()} y=${event.localPosition.dy.toInt()}';
              }),
              child: GestureDetector(
                onPanStart: (details) {
                  onPanStart(details);
                },
                onPanUpdate: (details) {
                  onPanUpdate(details);
                },
                onPanEnd: (details) {
                  onPanEnd(details);
                },
                onSecondaryTapDown: onSecondaryTapDown,
                child: CustomPaint(
                  painter:
                      AnnotationPainter(controller: controller, image: image),
                  child: Center(child: Text(controller.position)),
                ),
              ),
            ),
          ),
          Wrap(
            children: [
              CheckboxListTile(
                title: const Text("Show Points"),
                value: controller.showPoint,
                onChanged: (bool? value) {
                  setState(() {
                    controller.showPoint = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Show Lines"),
                value: controller.showLine,
                onChanged: (bool? value) {
                  setState(() {
                    controller.showLine = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Show Rectangles"),
                value: controller.showRect,
                onChanged: (bool? value) {
                  setState(() {
                    controller.showRect = value!;
                  });
                },
              ),
              CheckboxListTile(
                title: const Text("Show Text"),
                value: controller.showText,
                onChanged: (bool? value) {
                  setState(() {
                    controller.showText = value!;
                  });
                },
              ),
            ],
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => setMode(DrawingMode.point, Offset.zero),
                  child: const Text('Add Point')),
              ElevatedButton(
                  onPressed: () => setMode(DrawingMode.line, Offset.zero),
                  child: const Text('Add Line')),
              ElevatedButton(
                  onPressed: () => setMode(DrawingMode.rectangle, Offset.zero),
                  child: const Text('Add Rectangle')),
              ElevatedButton(
                  onPressed: () => setMode(DrawingMode.text, Offset.zero),
                  child: const Text('Add Text')),
              ElevatedButton(onPressed: clear, child: const Text('Clear')),
              ElevatedButton(
                  onPressed: () => setMode(DrawingMode.pan, Offset.zero),
                  child: const Text('Pan')),
            ],
          ),
        ],
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
    canvas.drawPoints(ui.PointMode.points, [point], paint);
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
    canvas.drawLine(start, end, paint);
  }

  @override
  bool contains(Offset position) {
    double distance = _distanceToLineSegment(position, start, end);
    return distance <= lineTolerance;
  }

  double _distanceToLineSegment(Offset point, Offset start, Offset end) {
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
    canvas.drawRect(Rect.fromPoints(start, end), paint);
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

class TextAnnotation extends Annotation {
  String text;
  Offset position;
  static const double textPadding = 5.0;
  TextAnnotation(this.text, this.position, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: text, style: TextStyle(color: paint.color, fontSize: 16)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }

  @override
  bool contains(Offset position) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: text, style: TextStyle(color: paint.color, fontSize: 16)),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    Rect textRect = position & textPainter.size;
    return textRect.inflate(textPadding).contains(position);
  }
}

class AnnotationController {
  Offset startingPoint = Offset.zero;
  Offset endingPoint = Offset.zero;
  Offset imageOffset = Offset.zero;
  String position = 'Mouse Position: ';
  DrawingMode currentMode = DrawingMode.point;
  List<Annotation> annotations = [];
  bool showPoint = true;
  bool showLine = true;
  bool showRect = true;
  bool showText = true;

  void addAnnotation(Annotation annotation) => annotations.add(annotation);
  void removeAnnotationAtPosition(Offset position) {
    annotations.removeWhere((annotation) => annotation.contains(position));
  }

  void clear() => annotations.clear();
}

class AnnotationPainter extends CustomPainter {
  final AnnotationController controller;
  final ui.Image? image;

  AnnotationPainter({required this.controller, this.image});

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      Rect imageRect = Rect.fromLTWH(controller.imageOffset.dx,
          controller.imageOffset.dy, size.width, size.height);
      paintImage(
        canvas: canvas,
        rect: imageRect,
        image: image!,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      );
    }

    for (var element in controller.annotations) {
      if ((element is PointAnnotation && controller.showPoint) ||
          (element is LineAnnotation && controller.showLine) ||
          (element is RectAnnotation && controller.showRect) ||
          (element is TextAnnotation && controller.showText)) {
        element.draw(canvas);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.controller.imageOffset != controller.imageOffset;
  }
}
