import 'dart:ui';

import 'package:flutter/material.dart';

enum DrawingMode { point, line, rectangle, text }

class DrawingPage extends StatefulWidget {
  const DrawingPage({Key? key}) : super(key: key);

  @override
  _DrawingPageState createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage> {
  final AnnotationController controller = AnnotationController();

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
      switch (controller.currentMode) {
        case DrawingMode.point:
          controller.addPoint(controller.endingPoint);
          break;
        case DrawingMode.line:
          controller.addLine(controller.startingPoint, controller.endingPoint);
          break;
        case DrawingMode.rectangle:
          controller.addRect(controller.startingPoint, controller.endingPoint);
          break;
        case DrawingMode.text:
          controller.addText("Sample Text", controller.endingPoint);
          break;
      }
    });
  }

  void clear() {
    setState(() {
      controller.clear();
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
                onPanStart: (details) =>
                    setMode(controller.currentMode, details.localPosition),
                onPanUpdate: (details) => updatePoints(details.localPosition),
                onPanEnd: (details) => endDrawing(),
                child: CustomPaint(
                  painter: AnnotationPainter(controller: controller),
                  child: Center(child: Text(controller.position)),
                ),
              ),
            ),
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
            ],
          ),
        ],
      ),
    );
  }
}

class AnnotationController {
  Offset startingPoint = Offset.zero;
  Offset endingPoint = Offset.zero;
  List<Offset> points = [];
  List<Offset> lineStartPoints = [];
  List<Offset> lineEndPoints = [];
  List<Offset> rectStartPoints = [];
  List<Offset> rectEndPoints = [];
  List<String> texts = [];
  List<Offset> textPositions = [];
  String position = 'Mouse Position: ';
  DrawingMode currentMode = DrawingMode.point;

  void addPoint(Offset point) => points.add(point);
  void addLine(Offset start, Offset end) {
    lineStartPoints.add(start);
    lineEndPoints.add(end);
  }

  void addRect(Offset start, Offset end) {
    rectStartPoints.add(start);
    rectEndPoints.add(end);
  }

  void addText(String text, Offset position) {
    texts.add(text);
    textPositions.add(position);
  }

  void clear() {
    points.clear();
    lineStartPoints.clear();
    lineEndPoints.clear();
    rectStartPoints.clear();
    rectEndPoints.clear();
    texts.clear();
    textPositions.clear();
  }
}

class AnnotationPainter extends CustomPainter {
  final AnnotationController controller;

  AnnotationPainter({required this.controller});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // Draw points
    paint.color = Colors.red;
    canvas.drawPoints(PointMode.points, controller.points, paint);

    // Draw lines
    paint.color = Colors.green;
    for (int i = 0; i < controller.lineStartPoints.length; i++) {
      canvas.drawLine(
          controller.lineStartPoints[i], controller.lineEndPoints[i], paint);
    }

    // Draw rectangles
    paint.color = Colors.blue;
    for (int i = 0; i < controller.rectStartPoints.length; i++) {
      canvas.drawRect(
          Rect.fromPoints(
              controller.rectStartPoints[i], controller.rectEndPoints[i]),
          paint);
    }

    // Draw text
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < controller.texts.length; i++) {
      final textSpan = TextSpan(
        text: controller.texts[i],
        style: const TextStyle(color: Colors.black, fontSize: 16),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, controller.textPositions[i]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
