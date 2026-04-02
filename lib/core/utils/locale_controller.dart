import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';

class LocaleController extends Notifier<AppLocale> {
  @override
  AppLocale build() => AppLocale.es;

  void setSpanish() {
    state = AppLocale.es;
    LocaleSettings.setLocale(AppLocale.es);
  }

  void setEnglish() {
    state = AppLocale.en;
    LocaleSettings.setLocale(AppLocale.en);
  }
}

final localeControllerProvider = NotifierProvider<LocaleController, AppLocale>(
  LocaleController.new,
);
