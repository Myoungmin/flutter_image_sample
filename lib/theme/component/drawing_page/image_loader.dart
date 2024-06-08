import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imageLoaderProvider =
    NotifierProvider<ImageLoader, ui.Image?>(ImageLoader.new);

class ImageLoader extends Notifier<ui.Image?> {
  @override
  ui.Image? build() => null;

  void loadImage(ImageProvider imageProvider) {
    final ImageStreamListener listener =
        ImageStreamListener((ImageInfo info, bool _) {
      state = info.image;
    });
    imageProvider.resolve(const ImageConfiguration()).addListener(listener);
  }
}
