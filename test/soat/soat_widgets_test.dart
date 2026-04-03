import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mototracker/features/soat/domain/entities/soat_policy.dart';
import 'package:mototracker/features/soat/domain/repositories/soat_policy_repository.dart';
import 'package:mototracker/features/soat/presentation/providers/soat_providers.dart';
import 'package:mototracker/features/soat/presentation/screens/soat_list_screen.dart';
import 'package:mototracker/features/soat/presentation/screens/soat_lookup_screen.dart';
import 'package:mototracker/i18n/strings.g.dart';

class _WidgetFakeSoatRepository implements SoatPolicyRepository {
  _WidgetFakeSoatRepository({required this.items, this.lookupResult});

  final List<SoatPolicy> items;
  final SoatPolicy? lookupResult;

  @override
  Future<void> add(SoatPolicy policy) async {}

  @override
  Future<SoatPolicy?> getActiveByLicensePlate({
    required String userId,
    required String licensePlate,
  }) async {
    return lookupResult;
  }

  @override
  Future<SoatPolicy?> getActivePolicy(String motorcycleId) async =>
      items.isEmpty ? null : items.first;

  @override
  Future<SoatPolicy?> getById(String id) async => null;

  @override
  Future<List<SoatPolicy>> getExpiringSoon({required String userId, required int days}) async => [];

  @override
  Future<List<SoatPolicy>> getHistoryByLicensePlate({
    required String userId,
    required String licensePlate,
  }) async => [];

  @override
  Future<void> remove(String id) async {}

  @override
  Future<void> update(SoatPolicy policy) async {}

  @override
  Stream<List<SoatPolicy>> watchByMotorcycle(String motorcycleId) => Stream.value(items);
}

void main() {
  setUp(() {
    LocaleSettings.setLocale(AppLocale.en);
  });

  testWidgets('SoatListScreen shows empty state', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          soatPolicyRepositoryProvider.overrideWithValue(
            _WidgetFakeSoatRepository(items: const []),
          ),
        ],
        child: TranslationProvider(
          child: const MaterialApp(home: SoatListScreen(motorcycleId: 'm-1')),
        ),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('No SOAT policies registered'), findsOneWidget);
  });

  testWidgets('SoatLookupScreen shows not-found state after search', (tester) async {
    final router = GoRouter(
      routes: [GoRoute(path: '/', builder: (context, state) => const SoatLookupScreen())],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          soatPolicyRepositoryProvider.overrideWithValue(
            _WidgetFakeSoatRepository(items: const [], lookupResult: null),
          ),
        ],
        child: TranslationProvider(child: MaterialApp.router(routerConfig: router)),
      ),
    );

    await tester.enterText(find.byType(TextField), 'abc123');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();

    expect(find.text('No active SOAT found for this plate'), findsOneWidget);
  });

  testWidgets('SoatListScreen navigates to detail route on card tap', (tester) async {
    final policy = SoatPolicy(
      id: 'p-1',
      userId: 'u-1',
      motorcycleId: 'm-1',
      insurer: 'Mapfre',
      policyNumber: 'ABC123',
      startDate: DateTime(2026, 1, 1),
      expiryDate: DateTime(2026, 12, 31),
      notes: '',
      createdAt: DateTime(2026, 1, 1),
    );

    final router = GoRouter(
      initialLocation: '/garage/m-1/soat',
      routes: [
        GoRoute(
          path: '/garage/:id/soat',
          builder: (_, state) => SoatListScreen(motorcycleId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/garage/:id/soat/:soatId',
          builder: (_, state) => Scaffold(body: Text('detail:${state.pathParameters['soatId']}')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          soatPolicyRepositoryProvider.overrideWithValue(
            _WidgetFakeSoatRepository(items: [policy]),
          ),
        ],
        child: TranslationProvider(child: MaterialApp.router(routerConfig: router)),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('ABC123'));
    await tester.pumpAndSettle();

    expect(find.text('detail:p-1'), findsOneWidget);
  });
}
