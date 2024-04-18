import 'package:flutter/material.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  DrawingPageState createState() => DrawingPageState();
}

class DrawingPageState extends State<DrawingPage> {
  Offset startingPoint = Offset.zero;
  Offset endingPoint = Offset.zero;
  bool drawing = false;

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
      drawing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) => updatePoints(details.localPosition),
        onPanEnd: (details) => endDrawing(),
        child: CustomPaint(
          painter: RectanglePainter(startingPoint, endingPoint),
          child: Container(),
        ),
      ),
    );
  }
}

class RectanglePainter extends CustomPainter {
  final Offset startingPoint;
  final Offset endingPoint;

  RectanglePainter(this.startingPoint, this.endingPoint);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(
      Rect.fromPoints(startingPoint, endingPoint),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
