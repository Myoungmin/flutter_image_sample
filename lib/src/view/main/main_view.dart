import 'package:flutter/material.dart';
import 'package:flutter_image_sample/src/service/theme_service.dart';
import 'package:flutter_image_sample/src/view/base_view.dart';
import 'package:flutter_image_sample/src/view/main/main_view_model.dart';
import 'package:flutter_image_sample/theme/component/drawing_page.dart';

class MainView extends StatefulWidget {
  const MainView({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  String _position = 'Mouse Position: ';

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
        body: Row(
          children: [
            Expanded(
              child: Center(
                child: MouseRegion(
                  onHover: (PointerEvent event) {
                    setState(() {
                      _position =
                          'Mouse Position\nx=${event.localPosition.dx.toInt()}\ny=${event.localPosition.dy.toInt()}';
                    });
                  },
                  child: Image.network(
                    'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg',
                  ),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(_position),
              ),
            ),
            const Expanded(
              child: Center(
                child: DrawingPage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
