import 'package:flutter/material.dart';
import 'package:flutter_image_sample/src/service/theme_service.dart';
import 'package:flutter_image_sample/src/view/base_view.dart';
import 'package:flutter_image_sample/src/view/main/main_view_model.dart';
import 'package:flutter_image_sample/theme/component/base_dialog.dart';
import 'package:flutter_image_sample/theme/res/layout.dart';
import 'package:flutter_image_sample/util/lang/generated/l10n.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModelProvider: mainViewModelProvider,
      builder: (ref, viewModel, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            S.current.hello,
            style: ref.textTheme.titleLarge?.copyWith(
              color: ref.colorScheme.onSurface,
            ),
          ),
        ),
        body: Center(
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (context) {
                  return BaseDialog(
                    title: S.current.hello,
                    content: Text(
                      S.current.hello,
                      style: ref.textTheme.titleLarge?.copyWith(
                        color: ref.theme.colorScheme.onSurface,
                      ),
                    ),
                    actions: [
                      TextButton(
                        child: Text(
                          S.current.cancel,
                          style: ref.textTheme.bodyLarge?.copyWith(
                            color: ref.theme.colorScheme.onSurface,
                          ),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          await Future.delayed(const Duration(seconds: 1));
                          await viewModel.circularIndicatorTest(2);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              context.layout(
                S.current.desktop,
                mobile: S.current.mobile,
                tablet: S.current.tablet,
                desktop: S.current.desktop,
              ),
              style: ref.textTheme.displayLarge?.copyWith(
                color: ref.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
