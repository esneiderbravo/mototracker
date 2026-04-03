import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/screens/change_password_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/garage/presentation/screens/add_motorcycle_screen.dart';
import '../../features/garage/presentation/screens/home_screen.dart';
import '../../features/garage/presentation/screens/motorcycle_detail_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/soat/presentation/screens/add_soat_screen.dart';
import '../../features/soat/presentation/screens/soat_detail_screen.dart';
import '../../features/soat/presentation/screens/soat_list_screen.dart';
import '../../features/soat/presentation/screens/soat_lookup_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/auth', builder: (context, state) => const AuthScreen()),
      GoRoute(
        path: '/garage',
        builder: (context, state) => const HomeScreen(),
        routes: [
          GoRoute(
            path: 'add',
            pageBuilder: (context, state) => CustomTransitionPage<void>(
              key: state.pageKey,
              child: const AddMotorcycleScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.12),
                    end: Offset.zero,
                  ).animate(curve),
                  child: FadeTransition(opacity: curve, child: child),
                );
              },
            ),
          ),
          GoRoute(
            path: ':id',
            builder: (_, state) => MotorcycleDetailScreen(id: state.pathParameters['id']!),
            routes: [
              GoRoute(
                path: 'soat',
                builder: (_, state) => SoatListScreen(motorcycleId: state.pathParameters['id']!),
                routes: [
                  GoRoute(
                    path: 'add',
                    pageBuilder: (context, state) => CustomTransitionPage<void>(
                      key: state.pageKey,
                      child: AddSoatScreen(motorcycleId: state.pathParameters['id']!),
                      transitionsBuilder: _slideAndFade,
                    ),
                  ),
                  GoRoute(
                    path: ':soatId',
                    builder: (_, state) => SoatDetailScreen(
                      motorcycleId: state.pathParameters['id']!,
                      soatId: state.pathParameters['soatId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/soat/lookup',
        builder: (_, state) => SoatLookupScreen(initialPlate: state.uri.queryParameters['plate']),
      ),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(
        path: '/change-password',
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const ChangePasswordScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(curve),
              child: FadeTransition(opacity: curve, child: child),
            );
          },
        ),
      ),
    ],
  );
});

Widget _slideAndFade(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
  return SlideTransition(
    position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(curve),
    child: FadeTransition(opacity: curve, child: child),
  );
}
