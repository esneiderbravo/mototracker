import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/mototracker_app.dart';
import 'core/constants/env.dart';
import 'i18n/strings.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Spanish as default locale
  LocaleSettings.setLocale(AppLocale.es);

  if (Env.hasSupabase) {
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  }

  runApp(const ProviderScope(child: MotoTrackerApp()));
}
