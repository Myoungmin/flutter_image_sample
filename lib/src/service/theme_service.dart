import 'package:flutter/material.dart';
import 'package:flutter_image_sample/theme/foundation/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeServiceProvider =
    NotifierProvider<ThemeService, AppTheme>(ThemeService.new);

class ThemeService extends Notifier<AppTheme> {
  ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: state.colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: state.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(
          color: state.colorScheme.onSurface,
        ),
        titleTextStyle: state.textTheme.displayMedium?.copyWith(
          color: state.colorScheme.onSurface,
        ),
      ),
    );
  }

  @override
  AppTheme build() => AppTheme(brightness: Brightness.light);

  void toggleTheme() {
    if (state.brightness == Brightness.light) {
      state = AppTheme(brightness: Brightness.dark);
    } else {
      state = AppTheme(brightness: Brightness.light);
    }
  }
}

extension ThemeServiceExt on WidgetRef {
  ThemeService get themeService => watch(themeServiceProvider.notifier);
  AppTheme get theme => watch(themeServiceProvider);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
}
