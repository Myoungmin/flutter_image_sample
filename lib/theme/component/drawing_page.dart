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
}

class PointAnnotation extends Annotation {
  Offset point;
  PointAnnotation(this.point, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas) {
    canvas.drawPoints(ui.PointMode.points, [point], paint);
  }
}

class LineAnnotation extends Annotation {
  Offset start;
  Offset end;
  LineAnnotation(this.start, this.end, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas) {
    canvas.drawLine(start, end, paint);
  }
}

class RectAnnotation extends Annotation {
  Offset start;
  Offset end;
  RectAnnotation(this.start, this.end, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas) {
    canvas.drawRect(Rect.fromPoints(start, end), paint);
  }
}

class TextAnnotation extends Annotation {
  String text;
  Offset position;
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
