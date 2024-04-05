import 'package:flutter/material.dart';
import 'package:flutter_image_sample/util/helper/intl_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final langServiceProvider =
    NotifierProvider<LangService, Locale>(LangService.new);

class LangService extends Notifier<Locale> {
  @override
  Locale build() => IntlHelper.en;

  void setLang(Language lang) {
    state = lang.locale;
  }
}
