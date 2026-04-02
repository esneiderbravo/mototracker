import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mototracker/app/mototracker_app.dart';
import 'package:mototracker/i18n/strings.g.dart';

void main() {
  testWidgets('MotoTracker app boots and routes to auth', (WidgetTester tester) async {
    LocaleSettings.setLocale(AppLocale.es);

    await tester.pumpWidget(const ProviderScope(child: MotoTrackerApp()));
    // Splash delay is 2 400 ms – advance past it then settle.
    await tester.pump(const Duration(milliseconds: 2600));
    await tester.pumpAndSettle();

    // The new auth screen shows mode-switcher tabs – both the tab and the CTA
    // button show the same sign-in label, so match ≥1.
    expect(find.text('Iniciar sesion'), findsAtLeastNWidgets(1));
  });
}
