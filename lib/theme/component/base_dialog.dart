import 'package:flutter/material.dart';
import 'package:flutter_image_sample/src/service/theme_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BaseDialog extends ConsumerWidget {
  const BaseDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
  });

  final String? title;
  final Widget? content;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      backgroundColor: ref.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      titlePadding: const EdgeInsets.all(16),
      contentPadding: const EdgeInsets.all(16).copyWith(
        top: title != null ? 0 : 16,
      ),
      actionsPadding: const EdgeInsets.all(16),
      title: title != null
          ? Text(
              title!,
              style: ref.textTheme.displayMedium!.copyWith(
                fontWeight: FontWeight.w600,
                color: ref.theme.colorScheme.onSurface,
              ),
            )
          : null,
      content: content,
      actions: actions,
    );
  }
}
