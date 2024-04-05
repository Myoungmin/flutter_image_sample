import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class BaseViewModel<S extends BaseViewState>
    extends AutoDisposeNotifier<S> {}

abstract class BaseViewState {
  const BaseViewState();

  bool get isBusy;
}
