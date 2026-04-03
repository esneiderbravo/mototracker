import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/text_formatters.dart';
import '../../../../i18n/strings.g.dart';
import '../../../../shared/widgets/async_value_builder.dart';
import '../providers/soat_providers.dart';
import '../widgets/soat_expiry_banner.dart';

final _lookupPlateProvider = StateProvider.autoDispose<String>((ref) => '');

class SoatLookupScreen extends ConsumerStatefulWidget {
  const SoatLookupScreen({this.initialPlate, super.key});

  final String? initialPlate;

  @override
  ConsumerState<SoatLookupScreen> createState() => _SoatLookupScreenState();
}

class _SoatLookupScreenState extends ConsumerState<SoatLookupScreen> {
  late final TextEditingController _plateController;

  @override
  void initState() {
    super.initState();
    _plateController = TextEditingController(text: widget.initialPlate ?? '');
    if (_plateController.text.trim().isNotEmpty) {
      ref.read(_lookupPlateProvider.notifier).state = _plateController.text.trim();
    }
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);
    final plate = ref.watch(_lookupPlateProvider);
    final result = ref.watch(soatByLicensePlateProvider(plate));

    return Scaffold(
      appBar: AppBar(title: Text(t.soat.lookup)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _plateController,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: const [
                      UpperCaseTextFormatter(),
                      AlphanumericNoSpaceFormatter(),
                    ],
                    decoration: InputDecoration(labelText: t.soat.plate),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    ref.read(_lookupPlateProvider.notifier).state = _plateController.text.trim();
                  },
                  child: Text(t.soat.search),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (plate.isNotEmpty)
              Expanded(
                child: AsyncValueBuilder(
                  value: result,
                  onData: (policy) {
                    if (policy == null) {
                      return Center(child: Text(t.soat.notFoundByPlate));
                    }
                    return SoatExpiryBanner(policy: policy);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
