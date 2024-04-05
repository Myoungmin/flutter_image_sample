import 'package:flutter/material.dart';

class AppTheme {
  AppTheme({
    this.brightness = Brightness.light,
    this.textTheme = Typography.englishLike2021,
    ColorScheme? colorScheme,
  }) : colorScheme = colorScheme ??
            (brightness == Brightness.light
                ? const ColorScheme.light()
                : const ColorScheme.dark());

  final Brightness brightness;
  final TextTheme textTheme;
  final ColorScheme colorScheme;
}
