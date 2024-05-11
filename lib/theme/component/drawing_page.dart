import 'dart:ui';

import 'package:flutter/material.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  DrawingPageState createState() => DrawingPageState();
}

class DrawingPageState extends State<DrawingPage> {
  Offset startingPoint = Offset.zero;
  Offset endingPoint = Offset.zero;
  List<Offset> points = [];
  List<Offset> lineStartPoints = [];
  List<Offset> lineEndPoints = [];
  List<Offset> rectStartPoints = [];
  List<Offset> rectEndPoints = [];
  List<String> texts = [];
  List<Offset> textPositions = [];
  bool drawing = false;
  String currentMode = ''; // 현재 모드를 저장하는 변수
  String position = 'Mouse Position: ';

  void setMode(String mode, Offset localPosition) {
    setState(() {
      currentMode = mode;
      startingPoint = localPosition;
      endingPoint = localPosition;
    });
  }

  void updatePoints(Offset localPosition) {
    setState(() {
      if (drawing) {
        endingPoint = localPosition;
      } else {
        startingPoint = localPosition;
        endingPoint = localPosition;
        drawing = true;
      }
    });
  }

  void endDrawing() {
    setState(() {
      if (currentMode == 'point') {
        points.add(endingPoint);
      } else if (currentMode == 'line') {
        lineStartPoints.add(startingPoint);
        lineEndPoints.add(endingPoint);
      } else if (currentMode == 'rectangle') {
        rectStartPoints.add(startingPoint);
        rectEndPoints.add(endingPoint);
      } else if (currentMode == 'text') {
        texts.add("Sample Text");
        textPositions.add(endingPoint);
      }
      drawing = false;
    });
  }

  void mouseHover(PointerEvent event) {
    setState(() {
      position =
          'Mouse Position\nx=${event.localPosition.dx.toInt()}\ny=${event.localPosition.dy.toInt()}';
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: MouseRegion(
              onHover: (event) => mouseHover(event),
              child: GestureDetector(
                onPanStart: (details) =>
                    setMode(currentMode, details.localPosition),
                onPanUpdate: (details) => updatePoints(details.localPosition),
                onPanEnd: (details) => endDrawing(),
                child: CustomPaint(
                  painter: RectanglePainter(
                    points: points,
                    lineStartPoints: lineStartPoints,
                    lineEndPoints: lineEndPoints,
                    rectStartPoints: rectStartPoints,
                    rectEndPoints: rectEndPoints,
                    texts: texts,
                    textPositions: textPositions,
                  ),
                  child: Center(child: Text(position)),
                ),
              ),
            ),
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: () => setMode('point', Offset.zero),
                  child: const Text('Add Point')),
              ElevatedButton(
                  onPressed: () => setMode('line', Offset.zero),
                  child: const Text('Add Line')),
              ElevatedButton(
                  onPressed: () => setMode('rectangle', Offset.zero),
                  child: const Text('Add Rectangle')),
              ElevatedButton(
                  onPressed: () => setMode('text', Offset.zero),
                  child: const Text('Add Text')),
              ElevatedButton(onPressed: clear, child: const Text('Clear')),
            ],
          ),
        ],
      ),
    );
  }
}

class RectanglePainter extends CustomPainter {
  final List<Offset> points;
  final List<Offset> lineStartPoints;
  final List<Offset> lineEndPoints;
  final List<Offset> rectStartPoints;
  final List<Offset> rectEndPoints;
  final List<String> texts;
  final List<Offset> textPositions;

  RectanglePainter({
    this.points = const [],
    this.lineStartPoints = const [],
    this.lineEndPoints = const [],
    this.rectStartPoints = const [],
    this.rectEndPoints = const [],
    this.texts = const [],
    this.textPositions = const [],
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    paint.color = Colors.red;
    canvas.drawPoints(PointMode.points, points, paint);

    paint.color = Colors.green;
    for (int i = 0; i < lineStartPoints.length; i++) {
      canvas.drawLine(lineStartPoints[i], lineEndPoints[i], paint);
    }

    paint.color = Colors.blue;
    for (int i = 0; i < rectStartPoints.length; i++) {
      canvas.drawRect(
          Rect.fromPoints(rectStartPoints[i], rectEndPoints[i]), paint);
    }

    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < texts.length; i++) {
      final textSpan = TextSpan(
        text: texts[i],
        style: const TextStyle(color: Colors.black, fontSize: 16),
      );
      textPainter.text = textSpan;
      textPainter.layout();
      textPainter.paint(canvas, textPositions[i]);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
