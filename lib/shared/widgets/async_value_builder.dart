import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';

class AsyncValueBuilder<T> extends StatelessWidget {
  const AsyncValueBuilder({required this.value, required this.onData, super.key});

  final AsyncValue<T> value;
  final Widget Function(T data) onData;

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    return value.when(
      data: onData,
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('${t.shared.errorLabel}: $error', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
