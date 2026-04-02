import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_providers.dart';
import '../widgets/mototracker_splash_art.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Give the full startup animation (1 800 ms) plus a short pause to breathe.
    Future<void>.delayed(const Duration(milliseconds: 2400), () {
      if (!mounted) return;
      final user = ref.read(authRepositoryProvider).currentUser;
      context.go(user == null ? '/auth' : '/garage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: MotoTrackerSplashArt()),
    );
  }
}
