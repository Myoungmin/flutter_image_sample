import 'package:flutter_image_sample/src/view/base_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mainViewModelProvider =
    NotifierProvider.autoDispose<MainViewModel, MainViewState>(
        MainViewModel.new);

class MainViewState extends BaseViewState {
  MainViewState({required this.isBusy});

  @override
  final bool isBusy;

  MainViewState copyWith({bool? isBusy}) {
    return MainViewState(isBusy: isBusy ?? this.isBusy);
  }
}

class MainViewModel extends BaseViewModel<MainViewState> {
  @override
  MainViewState build() {
    return MainViewState(isBusy: false);
  }

  Future<void> circularIndicatorTest(int seconds) async {
    state = state.copyWith(isBusy: true);
    await Future.delayed(Duration(seconds: seconds));
    state = state.copyWith(isBusy: false);
  }
}
