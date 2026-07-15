import 'dart:io';

import 'package:health/health.dart';

class HealthService {
  static final Health _health = Health();

  static bool _configured = false;

  static Future<void> _configureHealth() async {
    if (_configured) return;

    await _health.configure();
    _configured = true;
  }

  static Future<Map<String, dynamic>> syncTodayHealthData() async {
    await _configureHealth();

    final now = DateTime.now();

    // Κάθε μέρα τα βήματα και οι παλμοί μετριούνται από 00:00 μέχρι τώρα.
    final todayStart = DateTime(now.year, now.month, now.day);

    // Ο ύπνος πιάνεται σε 36 ώρες γιατί συχνά ξεκινάει χθες και τελειώνει σήμερα.
    final sleepStart = now.subtract(const Duration(hours: 36));

    final types = <HealthDataType>[
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_UNKNOWN,
      HealthDataType.SLEEP_SESSION,
    ];

    final permissions = types.map((_) => HealthDataAccess.READ).toList();

    final hasPermissions = await _health.requestAuthorization(
      types,
      permissions: permissions,
    );

    if (!hasPermissions) {
      throw Exception(
        'Health permissions were not granted. Open Health Connect and allow Steps, Heart Rate and Sleep.',
      );
    }

    final recordedAt = _formatDateTime(now);
    final metrics = <Map<String, dynamic>>[];

    final steps = await _readSamsungHealthSteps(todayStart, now);
    metrics.add({
      'metric_type': 'steps',
      'metric_value': steps,
      'metric_unit': 'steps',
      'recorded_at': recordedAt,
    });

    final heartRate = await _readLatestNumber(
      type: HealthDataType.HEART_RATE,
      start: todayStart,
      end: now,
    );

    if (heartRate != null) {
      metrics.add({
        'metric_type': 'heart_rate',
        'metric_value': heartRate,
        'metric_unit': 'bpm',
        'recorded_at': recordedAt,
      });
    }

    final sleepHours = await _readSleepHours(sleepStart, now);

    if (sleepHours != null) {
      metrics.add({
        'metric_type': 'sleep_hours',
        'metric_value': sleepHours,
        'metric_unit': 'hours',
        'recorded_at': recordedAt,
      });
    }

    return {
      'provider': Platform.isAndroid ? 'Health Connect' : 'Apple Health',
      'device_name':
      Platform.isAndroid ? 'Android Health Connect' : 'Apple Health',
      'metrics': metrics,
    };
  }

  static Future<int> _readSamsungHealthSteps(
      DateTime start,
      DateTime end,
      ) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [HealthDataType.STEPS],
        startTime: start,
        endTime: end,
      );

      if (data.isEmpty) {
        return 0;
      }

      var samsungTotal = 0.0;
      var anySamsungSource = false;

      final seen = <String>{};

      for (final point in data) {
        final sourceName = _readSourceName(point).toLowerCase();
        final sourceId = _readSourceId(point).toLowerCase();

        final isSamsung = sourceName.contains('samsung') ||
            sourceId.contains('samsung') ||
            sourceId.contains('shealth') ||
            sourceId.contains('healthplatform');

        if (!isSamsung) {
          continue;
        }

        final value = _extractNumber(point.value);
        if (value == null || value <= 0) {
          continue;
        }

        final key = _dedupeKey(point);
        if (seen.contains(key)) {
          continue;
        }

        seen.add(key);
        anySamsungSource = true;
        samsungTotal += value;
      }

      if (anySamsungSource) {
        return samsungTotal.round();
      }

      // Fallback: αν το Health Connect δεν δώσει source name/id,
      // παίρνουμε το συνολικό άθροισμα του Health Connect.
      final total = await _health.getTotalStepsInInterval(start, end);
      return total ?? 0;
    } catch (_) {
      try {
        final total = await _health.getTotalStepsInInterval(start, end);
        return total ?? 0;
      } catch (_) {
        return 0;
      }
    }
  }

  static String _readSourceName(HealthDataPoint point) {
    try {
      final dynamic dynamicPoint = point;
      final value = dynamicPoint.sourceName;
      if (value != null) return value.toString();
    } catch (_) {}

    try {
      final dynamic dynamicPoint = point;
      final source = dynamicPoint.source;
      if (source != null) return source.toString();
    } catch (_) {}

    return '';
  }

  static String _readSourceId(HealthDataPoint point) {
    try {
      final dynamic dynamicPoint = point;
      final value = dynamicPoint.sourceId;
      if (value != null) return value.toString();
    } catch (_) {}

    try {
      final dynamic dynamicPoint = point;
      final value = dynamicPoint.sourceDeviceId;
      if (value != null) return value.toString();
    } catch (_) {}

    return '';
  }

  static String _dedupeKey(HealthDataPoint point) {
    try {
      final dynamic dynamicPoint = point;
      final uuid = dynamicPoint.uuid;
      if (uuid != null && uuid.toString().isNotEmpty) {
        return uuid.toString();
      }
    } catch (_) {}

    final value = _extractNumber(point.value)?.toStringAsFixed(2) ?? '';
    return '${point.type}_${point.dateFrom.toIso8601String()}_'
        '${point.dateTo.toIso8601String()}_$value';
  }

  static Future<double?> _readLatestNumber({
    required HealthDataType type,
    required DateTime start,
    required DateTime end,
  }) async {
    try {
      final data = await _health.getHealthDataFromTypes(
        types: [type],
        startTime: start,
        endTime: end,
      );

      if (data.isEmpty) return null;

      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));

      for (final point in data) {
        final number = _extractNumber(point.value);
        if (number != null && number > 0) {
          return double.parse(number.toStringAsFixed(1));
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<double?> _readSleepHours(DateTime start, DateTime end) async {
    final stageSleep = await _sumSleepMinutesFromTypes(
      start,
      end,
      [
        HealthDataType.SLEEP_LIGHT,
        HealthDataType.SLEEP_DEEP,
        HealthDataType.SLEEP_REM,
        HealthDataType.SLEEP_UNKNOWN,
      ],
    );

    if (stageSleep > 0) {
      return double.parse((stageSleep / 60).toStringAsFixed(1));
    }

    final asleep = await _sumSleepMinutesFromTypes(
      start,
      end,
      [
        HealthDataType.SLEEP_ASLEEP,
      ],
    );

    if (asleep > 0) {
      return double.parse((asleep / 60).toStringAsFixed(1));
    }

    final session = await _sumSleepMinutesFromTypes(
      start,
      end,
      [
        HealthDataType.SLEEP_SESSION,
      ],
    );

    if (session > 0) {
      return double.parse((session / 60).toStringAsFixed(1));
    }

    return null;
  }

  static Future<double> _sumSleepMinutesFromTypes(
      DateTime start,
      DateTime end,
      List<HealthDataType> types,
      ) async {
    var totalMinutes = 0.0;

    for (final type in types) {
      try {
        final data = await _health.getHealthDataFromTypes(
          types: [type],
          startTime: start,
          endTime: end,
        );

        for (final point in data) {
          final durationMinutes =
              point.dateTo.difference(point.dateFrom).inMinutes;

          if (durationMinutes > 0) {
            totalMinutes += durationMinutes.toDouble();
            continue;
          }

          final valueMinutes = _extractNumber(point.value);
          if (valueMinutes != null && valueMinutes > 0) {
            totalMinutes += valueMinutes;
          }
        }
      } catch (_) {
        // Αν κάποιο sleep type δεν υποστηρίζεται, συνεχίζουμε στα υπόλοιπα.
      }
    }

    return totalMinutes;
  }

  static double? _extractNumber(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    if (value is NumericHealthValue) {
      return value.numericValue.toDouble();
    }

    final direct = double.tryParse(value.toString());
    if (direct != null) {
      return direct;
    }

    final text = value.toString();

    final patterns = <RegExp>[
      RegExp(r'numericValue:\s*([0-9]+(?:\.[0-9]+)?)'),
      RegExp(r'numeric_value:\s*([0-9]+(?:\.[0-9]+)?)'),
      RegExp(r'value:\s*([0-9]+(?:\.[0-9]+)?)'),
      RegExp(r'([0-9]+(?:\.[0-9]+)?)'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return double.tryParse(match.group(1) ?? '');
      }
    }

    return null;
  }

  static String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    String two(int value) => value.toString().padLeft(2, '0');

    return '${local.year}-${two(local.month)}-${two(local.day)} '
        '${two(local.hour)}:${two(local.minute)}:${two(local.second)}';
  }
}
