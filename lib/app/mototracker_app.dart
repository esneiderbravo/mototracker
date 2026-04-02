// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/router/app_router.dart';
import '../core/theme/AppTheme.dart';
import '../i18n/strings.g.dart';

class MotoTrackerApp extends ConsumerWidget {
  const MotoTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return TranslationProvider(
      child: Builder(
        builder: (ctx) => MaterialApp.router(
          title: 'MotoTracker',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: router,
          locale: TranslationProvider.of(ctx).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      ),
    );
  }
}
