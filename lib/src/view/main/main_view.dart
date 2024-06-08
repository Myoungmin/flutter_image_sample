import 'package:flutter/material.dart';
import 'package:flutter_image_sample/src/service/theme_service.dart';
import 'package:flutter_image_sample/src/view/base_view.dart';
import 'package:flutter_image_sample/src/view/main/main_view_model.dart';
import 'package:flutter_image_sample/theme/component/drawing_page/drawing_page.dart';

class MainView extends StatelessWidget {
  const MainView({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView(
      viewModelProvider: mainViewModelProvider,
      builder: (ref, viewModel, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            "Image",
            style: ref.textTheme.titleLarge?.copyWith(
              color: ref.colorScheme.onSurface,
            ),
          ),
        ),
        body: const Row(
          children: [
            Expanded(
              child: Center(
                child: DrawingPage(
                  imageProvider: NetworkImage(
                      'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
