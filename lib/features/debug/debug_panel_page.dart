import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/api_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/theme/premium_theme.dart';

class DebugPanelPage extends ConsumerStatefulWidget {
  const DebugPanelPage({super.key});

  @override
  ConsumerState<DebugPanelPage> createState() => _DebugPanelPageState();
}

class _DebugPanelPageState extends ConsumerState<DebugPanelPage> {
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();
  final _moduleCtrl = TextEditingController(text: '4');

  @override
  void initState() {
    super.initState();
    final s = StorageService.instance;
    _latCtrl.text = (s.getLatitude() ?? 17.736786411094663).toString();
    _lngCtrl.text = (s.getLongitude() ?? 83.31544903923952).toString();
  }

  @override
  Widget build(BuildContext context) {
    final storage = StorageService.instance;
    final zonesAsync = ref.watch(zonesProvider);
    final headers = ref.watch(headersPreviewProvider);
    final selectedZoneId = ref.watch(selectedZoneIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug Control Panel')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Current Settings'),
            _kv('Language', storage.getLanguage()),
            _kv('Token', storage.getToken()?.isNotEmpty == true ? 'SET' : 'NONE'),
            _kv('Latitude', (storage.getLatitude() ?? '-').toString()),
            _kv('Longitude', (storage.getLongitude() ?? '-').toString()),
            _kv('Zone IDs', storage.getZoneIds().toString()),
            const SizedBox(height: 12),
            _sectionTitle('Headers Preview'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: PremiumTheme.lightGrey),
              ),
              child: Text(headers.toString()),
            ),

            const SizedBox(height: 24),
            _sectionTitle('Set Location'),
            Row(
              children: [
                Expanded(child: _textField('Latitude', _latCtrl)),
                const SizedBox(width: 12),
                Expanded(child: _textField('Longitude', _lngCtrl)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(spacing: 12, children: [
              ElevatedButton(
                onPressed: () async {
                  final lat = double.tryParse(_latCtrl.text);
                  final lng = double.tryParse(_lngCtrl.text);
                  if (lat != null && lng != null) {
                    await StorageService.instance.setLocation(lat, lng);
                    if (mounted) setState(() {});
                  }
                },
                child: const Text('Save Location'),
              ),
              OutlinedButton(
                onPressed: () async {
                  // Reinitialize (will try geolocator then fallback)
                  await ref.read(apiServiceProvider).initializeApp();
                  if (mounted) setState(() {});
                },
                child: const Text('Detect & Set Zone by Location'),
              ),
            ]),

            const SizedBox(height: 24),
            _sectionTitle('Zones'),
            zonesAsync.when(
              data: (zones) {
                return DropdownButton<int>(
                  value: selectedZoneId,
                  hint: const Text('Select Zone'),
                  items: zones.map((z) => DropdownMenuItem<int>(
                        value: z.id,
                        child: Text('[${z.id}] ${z.name}'),
                      )).toList(),
                  onChanged: (val) => ref.read(selectedZoneIdProvider.notifier).state = val,
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text('Zones error: $e'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: selectedZoneId == null
                  ? null
                  : () async {
                      final zoneId = selectedZoneId;
                      await ref.read(apiServiceProvider).setZoneIds([zoneId]);
                      if (mounted) setState(() {});
                    },
              child: const Text('Apply Selected Zone'),
            ),

            const Divider(height: 32),
            _sectionTitle('Test Stores Fetch'),
            Row(children: [
              SizedBox(
                width: 220,
                child: _textField('Module Id (1-5)', _moduleCtrl),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => setState(() {}),
                child: const Text('Fetch'),
              ),
            ]),
            const SizedBox(height: 12),
            Consumer(builder: (context, ref, _) {
              final moduleId = int.tryParse(_moduleCtrl.text) ?? 4;
              final storesAsync = ref.watch(storesByModuleProvider(moduleId));
              return storesAsync.when(
                data: (list) => Text('Fetched stores: ${list.length}'),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              );
            }),

            const SizedBox(height: 16),
            _sectionTitle('Latest Stores (via /stores/latest?type=all)'),
            Consumer(builder: (context, ref, _) {
              final moduleId = int.tryParse(_moduleCtrl.text) ?? 4;
              final latestAsync = ref.watch(latestStoresProvider(moduleId));
              return latestAsync.when(
                data: (list) => Text('Latest stores count: ${list.length}'),
                loading: () => const CircularProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _textField(String label, TextEditingController ctrl) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          t,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            SizedBox(width: 140, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w700))),
            Expanded(child: Text(v)),
          ],
        ),
      );
}
