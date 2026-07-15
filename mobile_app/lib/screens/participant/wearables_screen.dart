import 'dart:async';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/health_service.dart';

class WearablesScreen extends StatefulWidget {
  const WearablesScreen({super.key});

  @override
  State<WearablesScreen> createState() => _WearablesScreenState();
}

class _WearablesScreenState extends State<WearablesScreen> {
  bool isLoading = true;
  bool isSyncing = false;
  bool autoSyncEnabled = false;

  Timer? autoSyncTimer;

  Map<String, dynamic>? stepsMetric;
  Map<String, dynamic>? heartRateMetric;
  Map<String, dynamic>? sleepMetric;

  String? lastSyncAt;
  List<Map<String, dynamic>> devices = [];

  @override
  void initState() {
    super.initState();

    // Δεν κάνουμε αυτόματο Health permission request με το άνοιγμα της οθόνης.
    // Πρώτα φορτώνουμε ό,τι έχει ήδη σωθεί στη βάση.
    // Το auto refresh ξεκινάει μόνο αφού ο χρήστης πατήσει μία φορά Sync Now.
    loadWearables();
  }

  @override
  void dispose() {
    autoSyncTimer?.cancel();
    super.dispose();
  }

  void startAutoSync() {
    autoSyncTimer?.cancel();

    autoSyncEnabled = true;

    // Refresh κάθε 60 δευτερόλεπτα όσο η οθόνη Wearables είναι ανοιχτή.
    autoSyncTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      if (!mounted || isSyncing) return;
      syncNow(silent: true);
    });
  }

  Future<void> loadWearables() async {
    if (mounted) {
      setState(() => isLoading = true);
    }

    final response = await ApiService.get(
      '/participant/wearables.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      final today = response['today'];
      final metrics = response['metrics'];

      Map<String, dynamic>? readMetric(String key) {
        dynamic value;

        if (today is Map<String, dynamic>) {
          value = today[key];
        }

        value ??= metrics is Map<String, dynamic> ? metrics[key] : null;

        if (value is Map<String, dynamic>) {
          return value;
        }

        return null;
      }

      final rawDevices = response['devices'];

      setState(() {
        stepsMetric = readMetric('steps');
        heartRateMetric = readMetric('heart_rate');
        sleepMetric = readMetric('sleep_hours');
        lastSyncAt = response['last_sync_at']?.toString();

        if (rawDevices is List) {
          devices = rawDevices
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList();
        } else {
          devices = [];
        }
      });
    }

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> syncNow({bool silent = false}) async {
    if (isSyncing) return;

    setState(() => isSyncing = true);

    try {
      final healthPayload = await HealthService.syncTodayHealthData();

      final response = await ApiService.post(
        '/participant/save_metrics.php',
        healthPayload,
        auth: true,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        await loadWearables();

        if (!mounted) return;

        startAutoSync();

        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message']?.toString() ??
                    'Health metrics synced successfully',
              ),
            ),
          );
        }
      } else {
        if (!silent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['message']?.toString() ??
                    'Could not save health metrics',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;

      if (!silent) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sync error: Health permissions were not granted. '
                  'Open Health Connect and allow Steps, Heart Rate and Sleep.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSyncing = false);
      }
    }
  }

  String displayMetric(Map<String, dynamic>? metric) {
    if (metric == null) return '-';

    final rawValue = metric['metric_value'];

    if (rawValue == null) return '-';

    final number = double.tryParse(rawValue.toString());

    if (number == null) return rawValue.toString();

    if (number == number.roundToDouble()) {
      return number.round().toString();
    }

    return number.toStringAsFixed(1);
  }

  String displaySleep() {
    final value = displayMetric(sleepMetric);
    if (value == '-') return '-';
    return '${value}h';
  }

  String displayLastSync() {
    if (lastSyncAt == null || lastSyncAt!.trim().isEmpty) return '-';
    return lastSyncAt!;
  }

  String autoSyncText() {
    if (autoSyncEnabled) {
      return 'Auto sync active while this screen is open';
    }

    return 'Tap Sync Now once to enable automatic refresh';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await loadWearables();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 22, 28, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 28),
                  _syncCard(),
                  const SizedBox(height: 22),
                  _metricsCard(),
                  const SizedBox(height: 22),
                  _devicesCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.18),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'Wearables',
            style: TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _syncCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _iconCircle(Icons.health_and_safety),
              const SizedBox(width: 18),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sync with Health Connect',
                      style: TextStyle(
                        color: Color(0xFF0F3D84),
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Reads today\'s steps, heart rate and sleep data.',
                      style: TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            autoSyncText(),
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isSyncing ? null : () => syncNow(),
              icon: isSyncing
                  ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.sync),
              label: Text(isSyncing ? 'Syncing...' : 'Sync Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F61D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricsCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Today's Health Metrics",
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            Row(
              children: [
                Expanded(
                  child: _metricTile(
                    icon: Icons.directions_walk,
                    value: displayMetric(stepsMetric),
                    label: 'Steps',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _metricTile(
                    icon: Icons.favorite,
                    value: displayMetric(heartRateMetric),
                    label: 'Heart Rate',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _metricTile(
                    icon: Icons.nightlight_round,
                    value: displaySleep(),
                    label: 'Sleep',
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _metricTile(
                    icon: Icons.update,
                    value: displayLastSync(),
                    label: 'Last Sync',
                    smallValue: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              lastSyncAt == null
                  ? 'No wearable data synced yet.'
                  : 'Last health sync: $lastSyncAt',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _devicesCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Connected Devices',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          if (devices.isEmpty)
            _deviceTile(
              title: 'Health Connect',
              subtitle: 'Not synced yet',
              status: 'Disconnected',
            )
          else
            ...devices.map((device) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _deviceTile(
                  title: device['provider']?.toString() ?? 'Health Connect',
                  subtitle: device['last_sync_at'] == null
                      ? 'Connected'
                      : 'Last sync: ${device['last_sync_at']}',
                  status: device['status']?.toString() ?? 'connected',
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _metricTile({
    required IconData icon,
    required String value,
    required String label,
    bool smallValue = false,
  }) {
    return Container(
      height: 148,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF2F61D2), size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            textAlign: TextAlign.center,
            maxLines: smallValue ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF0F3D84),
              fontSize: smallValue ? 12 : 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _deviceTile({
    required String title,
    required String subtitle,
    required String status,
  }) {
    final isConnected = status.toLowerCase() == 'connected';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          _iconCircle(Icons.health_and_safety),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isConnected
                  ? const Color(0xFFDDF8E7)
                  : const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              isConnected ? 'Connected' : 'Disconnected',
              style: TextStyle(
                color: isConnected
                    ? const Color(0xFF34A853)
                    : const Color(0xFF6B7280),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconCircle(IconData icon) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Icon(icon, color: const Color(0xFF2F61D2), size: 28),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(34),
      ),
      child: child,
    );
  }
}

class _Gradient extends StatelessWidget {
  final Widget child;

  const _Gradient({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0F3D84),
            Color(0xFF2F61D2),
            Color(0xFF5A5CF6),
          ],
        ),
      ),
      child: child,
    );
  }
}
