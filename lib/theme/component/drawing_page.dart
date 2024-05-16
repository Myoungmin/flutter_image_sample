import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

enum DrawingMode { point, line, rectangle, text, pan }

class DrawingPage extends StatefulWidget {
  final ImageProvider imageProvider;

  const DrawingPage({Key? key, required this.imageProvider}) : super(key: key);

  @override
  DrawingPageState createState() => DrawingPageState();
}

class DrawingPageState extends State<DrawingPage> {
  final AnnotationController controller = AnnotationController();
  ui.Image? image;
  ui.Image? annotationImage;
  Offset lastPanPosition = Offset.zero;
  Offset dragStart = Offset.zero;
  double scale = 1.0;
  Offset hoverPosition = Offset.zero;

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  Future<void> loadImage() async {
    final resolver = ImageStreamListener((ImageInfo info, bool _) {
      setState(() {
        image = info.image;
        fitToScreen();
        _createAnnotationImage();
      });
    });
    widget.imageProvider
        .resolve(const ImageConfiguration())
        .addListener(resolver);
  }

  void fitToScreen() {
    if (image == null) return;
    final Size screenSize = MediaQuery.of(context).size;
    final double screenWidth = screenSize.width;
    final double screenHeight =
        screenSize.height - 150; // 버튼바 및 기타 UI 요소의 높이를 고려

    final double imageWidth = image!.width.toDouble();
    final double imageHeight = image!.height.toDouble();

    final double widthRatio = screenWidth / imageWidth;
    final double heightRatio = screenHeight / imageHeight;

    setState(() {
      scale = widthRatio < heightRatio ? widthRatio : heightRatio;
      controller.imageOffset = Offset(
        (screenWidth - imageWidth * scale) / 2,
        (screenHeight - imageHeight * scale) / 2,
      );
      controller.scale = scale;
    });
  }

  void setMode(DrawingMode mode, Offset localPosition) {
    setState(() {
      controller.startingPoint = toImagePosition(localPosition);
      controller.endingPoint = toImagePosition(localPosition);
      controller.currentMode = mode;
    });
  }

  void updatePoints(Offset localPosition) {
    setState(() {
      controller.endingPoint = toImagePosition(localPosition);
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
    _createAnnotationImage(); // 주석을 그린 후 이미지 업데이트
  }

  void clear() {
    setState(() {
      controller.clear();
    });
    _createAnnotationImage(); // 주석을 지운 후 이미지 업데이트
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
    _createAnnotationImage(); // 주석을 삭제한 후 이미지 업데이트
  }

  void onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      setState(() {
        double scaleFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
        Offset focalPoint = event.localPosition;
        scaleImage(focalPoint, scaleFactor);
      });
    }
  }

  void scaleImage(Offset focalPoint, double scaleFactor) {
    // 0.5 ~ 3.0으로 비율 제한할 때 아래 코드
    //final double newScale = (scale * scaleFactor).clamp(0.5, 3.0);

    final double newScale = scale * scaleFactor;
    if (newScale == scale) return;

    final Offset imageOffsetBefore = controller.imageOffset;

    // focalPoint에서 이미지의 현재 오프셋을 뺀 후, 현재 스케일로 나누어 포컬 포인트가 이미지 내에서 차지하는 상대적인 위치를 계산
    final Offset focalPointInImage = (focalPoint - imageOffsetBefore) / scale;
    scale = newScale;

    // 새로운 스케일을 적용한 후, 포컬 포인트를 기준으로 이미지의 새로운 오프셋을 계산
    // 이 계산을 통해 포컬 포인트가 확대/축소 후에도 동일한 화면 위치에 유지
    final Offset imageOffsetAfter = focalPoint - focalPointInImage * scale;

    setState(() {
      controller.scale = scale;
      controller.imageOffset = imageOffsetAfter;
    });
  }

  Offset toImagePosition(Offset localPosition) {
    // localPosition에서 현재 이미지의 오프셋(controller.imageOffset)을 뺀다
    // controller.imageOffset은 이미지가 화면 내에서 어디에 위치해 있는지를 나타낸다
    // 이를 통해 입력 위치를 이미지의 좌상단을 기준으로 한 좌표계로 변환
    return (localPosition - controller.imageOffset) / scale;
  }

  Future<void> _createAnnotationImage() async {
    if (image == null) return;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder,
        Rect.fromLTWH(0, 0, image!.width.toDouble(), image!.height.toDouble()));

    // 이미지 그리기
    paintImage(
      canvas: canvas,
      rect: Rect.fromLTWH(
          0, 0, image!.width.toDouble(), image!.height.toDouble()),
      image: image!,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    // 주석 그리기
    for (var element in controller.annotations) {
      if ((element is PointAnnotation && controller.showPoint) ||
          (element is LineAnnotation && controller.showLine) ||
          (element is RectAnnotation && controller.showRect) ||
          (element is TextAnnotation && controller.showText)) {
        element.draw(canvas, 1.0, Offset.zero);
      }
    }

    final picture = recorder.endRecording();
    final img = await picture.toImage(image!.width, image!.height);
    setState(() {
      annotationImage = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Listener(
              onPointerSignal: onPointerSignal,
              child: Row(
                children: [
                  Expanded(
                    child: MouseRegion(
                      onHover: (PointerEvent event) {
                        setState(() {
                          controller.position =
                              'Mouse Position: x=${event.localPosition.dx.toInt()} y=${event.localPosition.dy.toInt()}';
                          hoverPosition = event.localPosition;
                        });
                      },
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
                          painter: AnnotationPainter(
                            controller: controller,
                            image: image,
                            scale: scale,
                          ),
                          child: const Center(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 150,
                    height: 150,
                    child: annotationImage != null
                        ? CustomPaint(
                            painter: ZoomPainter(
                              image: annotationImage,
                              scale: scale,
                              imageOffset: controller.imageOffset,
                              hoverPosition: hoverPosition,
                            ),
                          )
                        : Container(),
                  ),
                ],
              ),
            ),
          ),
          Wrap(
            children: [
              Text(controller.position),
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
              ElevatedButton(onPressed: fitToScreen, child: const Text('Fit')),
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
  void draw(Canvas canvas, double scale, Offset imageOffset);
  bool contains(Offset position, double scale, Offset imageOffset);
}

class PointAnnotation extends Annotation {
  Offset point;
  static const double pointTolerance = 5.0;
  PointAnnotation(this.point, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas, double scale, Offset imageOffset) {
    canvas.drawPoints(
      ui.PointMode.points,
      [(point * scale) + imageOffset],
      paint,
    );
  }

  @override
  bool contains(Offset position, double scale, Offset imageOffset) {
    return ((point * scale) + imageOffset - position).distance <=
        pointTolerance;
  }
}

class LineAnnotation extends Annotation {
  Offset start;
  Offset end;
  static const double lineTolerance = 5.0;
  LineAnnotation(this.start, this.end, Paint paint) : super(paint);

  @override
  void draw(Canvas canvas, double scale, Offset imageOffset) {
    canvas.drawLine(
      (start * scale) + imageOffset,
      (end * scale) + imageOffset,
      paint,
    );
  }

  @override
  bool contains(Offset position, double scale, Offset imageOffset) {
    double distance = distanceToLineSegment(
      position,
      (start * scale) + imageOffset,
      (end * scale) + imageOffset,
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
  void draw(Canvas canvas, double scale, Offset imageOffset) {
    canvas.drawRect(
      Rect.fromPoints(
        (start * scale) + imageOffset,
        (end * scale) + imageOffset,
      ),
      paint,
    );
  }

  @override
  bool contains(Offset position, double scale, Offset imageOffset) {
    Rect rect =
        Rect.fromPoints(start * scale + imageOffset, end * scale + imageOffset);
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
  void draw(Canvas canvas, double scale, Offset imageOffset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: paint.color, fontSize: 16 * scale),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, (position * scale) + imageOffset);
  }

  @override
  bool contains(Offset position, double scale, Offset imageOffset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: paint.color, fontSize: 16),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    Rect textRect = ((this.position * scale) + imageOffset) & textPainter.size;
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
  double scale = 1.0;

  void addAnnotation(Annotation annotation) => annotations.add(annotation);
  void removeAnnotationAtPosition(Offset position) {
    annotations.removeWhere(
        (annotation) => annotation.contains(position, scale, imageOffset));
  }

  void clear() => annotations.clear();
}

class AnnotationPainter extends CustomPainter {
  final AnnotationController controller;
  final ui.Image? image;
  final double scale;

  AnnotationPainter({
    required this.controller,
    this.image,
    required this.scale,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      Rect imageRect = Rect.fromLTWH(
        controller.imageOffset.dx,
        controller.imageOffset.dy,
        image!.width.toDouble() * scale,
        image!.height.toDouble() * scale,
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
      if ((element is PointAnnotation && controller.showPoint) ||
          (element is LineAnnotation && controller.showLine) ||
          (element is RectAnnotation && controller.showRect) ||
          (element is TextAnnotation && controller.showText)) {
        element.draw(canvas, scale, controller.imageOffset);
      }
    }
  }

  @override
  bool shouldRepaint(covariant AnnotationPainter oldDelegate) {
    return oldDelegate.image != image ||
        oldDelegate.controller.imageOffset != controller.imageOffset ||
        oldDelegate.scale != scale ||
        oldDelegate.controller.annotations != controller.annotations;
  }
}

class ZoomPainter extends CustomPainter {
  final ui.Image? image;
  final double scale;
  final Offset imageOffset;
  final Offset hoverPosition;

  ZoomPainter({
    required this.image,
    required this.scale,
    required this.imageOffset,
    required this.hoverPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (image != null) {
      final zoomScale = scale * 2.0;
      final src = Rect.fromLTWH(
        (hoverPosition.dx - imageOffset.dx) / scale -
            size.width / (2 * zoomScale),
        (hoverPosition.dy - imageOffset.dy) / scale -
            size.height / (2 * zoomScale),
        size.width / zoomScale,
        size.height / zoomScale,
      );
      final dst = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(image!, src, dst, Paint());
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
