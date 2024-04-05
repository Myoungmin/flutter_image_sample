import 'package:flutter/material.dart';

enum Language {
  en,
  ko;

  Locale get locale {
    switch (this) {
      case Language.en:
        return IntlHelper.en;
      case Language.ko:
        return IntlHelper.ko;
    }
  }
}

abstract class IntlHelper {
  // 지원 언어
  static const Locale en = Locale('en');
  static const Locale ko = Locale('ko');
}
