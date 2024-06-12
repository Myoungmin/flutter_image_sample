import 'package:flutter/gestures.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/drawing_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gestureControllerProvider =
    NotifierProvider<GestureControllerNotifier, GestureController>(
        GestureControllerNotifier.new);

class GestureControllerNotifier extends Notifier<GestureController> {
  @override
  GestureController build() => GestureController();
}

class GestureController {
  DrawingMode drawingMode = DrawingMode.none;
  Offset startingPoint = Offset.zero;
  Offset endingPoint = Offset.zero;
  Offset imageOffset = Offset.zero;
  Offset lastPanPosition = Offset.zero;
  Offset dragStart = Offset.zero;
  double scale = 1.0;
  Offset hoverPosition = Offset.zero;
  bool isDragging = false;

  void onPanStart(DragStartDetails details) {
    if (drawingMode == DrawingMode.pan) {
      dragStart = details.localPosition;
      lastPanPosition = imageOffset;
    } else {
      startingPoint = toImagePosition(details.localPosition);
      endingPoint = toImagePosition(details.localPosition);
      isDragging = true;
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (drawingMode == DrawingMode.pan) {
      Offset delta = details.localPosition - dragStart;
      imageOffset = lastPanPosition + delta;
    } else {
      endingPoint = toImagePosition(details.localPosition);
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (drawingMode == DrawingMode.pan) {
      return;
    } else {
      isDragging = false;
    }
  }

  void onSecondaryTapDown(TapDownDetails details) {}

  void onPointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      double scaleFactor = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
      Offset focalPoint = event.localPosition;
      scaleImage(focalPoint, scaleFactor);
    }
  }

  void onHover(PointerEvent event) {
    hoverPosition = event.localPosition;
  }

  void scaleImage(Offset focalPoint, double scaleFactor) {
    // 0.5 ~ 3.0으로 비율 제한할 때 아래 코드
    //final double newScale = (scale * scaleFactor).clamp(0.5, 3.0);

    final double newScale = scale * scaleFactor;
    if (newScale == scale) return;

    final Offset imageOffsetBefore = imageOffset;

    // focalPoint에서 이미지의 현재 오프셋을 뺀 후, 현재 스케일로 나누어 포컬 포인트가 이미지 내에서 차지하는 상대적인 위치를 계산
    final Offset focalPointInImage = (focalPoint - imageOffsetBefore) / scale;
    scale = newScale;

    // 새로운 스케일을 적용한 후, 포컬 포인트를 기준으로 이미지의 새로운 오프셋을 계산
    // 이 계산을 통해 포컬 포인트가 확대/축소 후에도 동일한 화면 위치에 유지
    imageOffset = focalPoint - focalPointInImage * scale;
  }

  Offset toImagePosition(Offset localPosition) {
    // localPosition에서 현재 이미지의 오프셋을 뺀다
    // imageOffset은 이미지가 화면 내에서 어디에 위치해 있는지를 나타낸다
    // 이를 통해 입력 위치를 이미지의 좌상단을 기준으로 한 좌표계로 변환
    return (localPosition - imageOffset) / scale;
  }
}
