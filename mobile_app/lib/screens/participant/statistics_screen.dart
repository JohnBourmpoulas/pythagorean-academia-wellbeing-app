import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic> statistics = {};

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.get(
        '/participant/statistics.php',
        auth: true,
      );

      if (!mounted) return;

      if (response['success'] != true) {
        setState(() {
          errorMessage =
              response['message']?.toString() ?? 'Could not load statistics';
          isLoading = false;
        });
        return;
      }

      setState(() {
        statistics = Map<String, dynamic>.from(response['statistics'] ?? {});
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  int intValue(String key) {
    return int.tryParse(statistics[key]?.toString() ?? '') ?? 0;
  }

  double doubleValue(String key) {
    return double.tryParse(statistics[key]?.toString() ?? '') ?? 0.0;
  }

  String textValue(String key) {
    final value = statistics[key];
    if (value == null || value.toString() == 'null') return '';
    return value.toString();
  }

  Map<String, dynamic> mapValue(String key) {
    return Map<String, dynamic>.from(statistics[key] ?? {});
  }

  List<Map<String, dynamic>> listValue(String key) {
    return List<Map<String, dynamic>>.from(statistics[key] ?? []);
  }

  double reflectionValue(String key) {
    final reflections = mapValue('reflections');
    return double.tryParse(reflections[key]?.toString() ?? '') ?? 0.0;
  }

  int mapInt(Map<String, dynamic> map, String key) {
    return int.tryParse(map[key]?.toString() ?? '') ?? 0;
  }

  String mapText(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null || value.toString() == 'null') return '';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
              : RefreshIndicator(
            onRefresh: loadStatistics,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  const SizedBox(height: 28),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else ...[
                    _overviewCard(),
                    const SizedBox(height: 20),
                    _programSummaryCard(),
                    const SizedBox(height: 20),
                    _weeklyProgressCard(),
                    const SizedBox(height: 20),
                    _dailyProgressCard(),
                    const SizedBox(height: 20),
                    _reflectionCard(),
                    const SizedBox(height: 20),
                    _metricsCard(),
                    const SizedBox(height: 20),
                    _recentActivityCard(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.18),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (Navigator.canPop(context)) Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'Statistics',
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

  Widget _overviewCard() {
    final title = textValue('program_title').isEmpty
        ? 'Current Program'
        : textValue('program_title');
    final progress = intValue('completion_percent').clamp(0, 100);
    final currentWeek = intValue('current_week');
    final totalWeeks = intValue('total_weeks');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Week $currentWeek of $totalWeeks',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: SizedBox(
              width: 180,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 158,
                    height: 158,
                    child: CircularProgressIndicator(
                      value: progress / 100,
                      strokeWidth: 15,
                      strokeCap: StrokeCap.round,
                      backgroundColor: const Color(0xFFE8EEF8),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF5A5CF6),
                      ),
                    ),
                  ),
                  Container(
                    width: 108,
                    height: 108,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$progress%',
                      style: const TextStyle(
                        color: Color(0xFF0F3D84),
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _simpleStat(
                  value: intValue('completed_tasks').toString(),
                  label: 'Completed',
                ),
              ),
              Expanded(
                child: _simpleStat(
                  value: intValue('total_tasks').toString(),
                  label: 'Total',
                ),
              ),
              Expanded(
                child: _simpleStat(
                  value: intValue('pending_tasks').toString(),
                  label: 'Pending',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _programSummaryCard() {
    final currentWeekStats = mapValue('current_week_stats');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Program Summary',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _summaryBox(
                  icon: Icons.star_rounded,
                  iconColor: Colors.orange,
                  label: 'Points',
                  value: intValue('total_points').toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _summaryBox(
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF2F61D2),
                  label: 'This Week',
                  value: '${mapInt(currentWeekStats, 'percent')}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _wideSummaryBox(
            icon: Icons.favorite_rounded,
            iconColor: const Color(0xFFFF2F68),
            label: 'Wellness Score',
            value: intValue('wellness_score').toString(),
          ),
          const SizedBox(height: 12),
          _wideSummaryBox(
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFF6F4BB2),
            label: 'Best Week',
            value: intValue('best_week') <= 0
                ? '-'
                : 'Week ${intValue('best_week')} • ${intValue('best_week_percent')}%',
          ),
        ],
      ),
    );
  }

  Widget _weeklyProgressCard() {
    final weekly = listValue('weekly_progress');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          if (weekly.isEmpty)
            const Text(
              'No weekly progress yet.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
            )
          else
            SizedBox(
              height: 155,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: weekly.map(_weekBar).toList(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _weekBar(Map<String, dynamic> week) {
    final percent = mapInt(week, 'percent').clamp(0, 100);
    final weekNumber = mapInt(week, 'week');
    final height = 28.0 + (percent / 100) * 78.0;

    return Container(
      width: 62,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$percent%',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 34,
            height: height,
            decoration: BoxDecoration(
              color: percent > 0
                  ? const Color(0xFF2F61D2)
                  : const Color(0xFFDCEBFF),
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'W$weekNumber',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dailyProgressCard() {
    final daily = listValue('daily_progress');
    final visibleDays = daily.take(14).toList();

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Activity Stats',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (visibleDays.isEmpty)
            const Text(
              'No daily activities have been created yet.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
            )
          else
            ...visibleDays.map(_dayRow),
        ],
      ),
    );
  }

  Widget _dayRow(Map<String, dynamic> day) {
    final dayNumber = mapInt(day, 'day_number');
    final completed = mapInt(day, 'completed_tasks');
    final total = mapInt(day, 'total_tasks');
    final percent = mapInt(day, 'percent').clamp(0, 100);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: percent == 100
                ? const Color(0xFFD9F8E2)
                : const Color(0xFFE8F1FF),
            child: Icon(
              percent == 100
                  ? Icons.check_rounded
                  : Icons.calendar_today_rounded,
              color: percent == 100
                  ? const Color(0xFF48B657)
                  : const Color(0xFF2F61D2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $dayNumber',
                  style: const TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: percent / 100,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFE8EEF8),
                    valueColor: const AlwaysStoppedAnimation(
                      Color(0xFF2F61D2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '$completed/$total',
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reflectionCard() {
    final count = mapInt(mapValue('reflections'), 'count');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reflection Averages',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$count reflections submitted',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          _progressRow('Mood', reflectionValue('mood'), Icons.sentiment_satisfied_alt_rounded),
          _progressRow('Stress', reflectionValue('stress'), Icons.psychology_alt_rounded),
          _progressRow('Energy', reflectionValue('energy'), Icons.bolt_rounded),
          _progressRow('Sleep', reflectionValue('sleep'), Icons.nights_stay_rounded),
        ],
      ),
    );
  }

  Widget _metricsCard() {
    final metrics = listValue('metrics');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Metrics',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Wearable values will appear here when health sync is connected.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 16),
          if (metrics.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Text(
                'No wearable metrics have been synced yet.',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ...metrics.map(_metricTile),
        ],
      ),
    );
  }

  Widget _metricTile(Map<String, dynamic> metric) {
    final type = mapText(metric, 'metric_type');
    final average = mapText(metric, 'average_value').isEmpty
        ? '-'
        : mapText(metric, 'average_value');
    final max = mapText(metric, 'max_value').isEmpty
        ? '-'
        : mapText(metric, 'max_value');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F1FF),
            child: Icon(
              _metricIcon(type),
              color: const Color(0xFF2F61D2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _prettyMetric(type),
              style: const TextStyle(
                color: Color(0xFF0F3D84),
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Avg $average',
                style: const TextStyle(
                  color: Color(0xFF17213A),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Max $max',
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentActivityCard() {
    final recent = listValue('recent_activity');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (recent.isEmpty)
            const Text(
              'No recent activity yet.',
              style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
            )
          else
            ...recent.map(_historyTile),
        ],
      ),
    );
  }

  Widget _historyTile(Map<String, dynamic> item) {
    final title = mapText(item, 'title').isEmpty
        ? 'Activity'
        : mapText(item, 'title');
    final createdAt = mapText(item, 'created_at');
    final eventType = mapText(item, 'event_type');

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F1FF),
            child: Icon(
              _historyIcon(eventType),
              color: const Color(0xFF2F61D2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (createdAt.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    createdAt,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _progressRow(String label, double value, IconData icon) {
    final safeValue = value.clamp(0.0, 5.0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFE8F1FF),
            child: Icon(icon, color: const Color(0xFF2F61D2), size: 19),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 64,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F3D84),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: safeValue / 5,
                minHeight: 12,
                backgroundColor: const Color(0xFFE8EEF8),
                valueColor: const AlwaysStoppedAnimation(
                  Color(0xFF2F61D2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 34,
            child: Text(
              safeValue.toStringAsFixed(1),
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _simpleStat({required String value, required String label}) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F3D84),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _summaryBox({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _wideSummaryBox({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _prettyMetric(String type) {
    switch (type) {
      case 'steps':
        return 'Steps';
      case 'sleep_hours':
        return 'Sleep Hours';
      case 'heart_rate':
        return 'Heart Rate';
      case 'calories':
        return 'Calories';
      case 'distance':
        return 'Distance';
      case 'spo2':
        return 'SpO₂';
      default:
        if (type.isEmpty) return 'Metric';
        return type
            .replaceAll('_', ' ')
            .split(' ')
            .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
            .join(' ');
    }
  }

  IconData _metricIcon(String type) {
    switch (type) {
      case 'steps':
        return Icons.directions_walk_rounded;
      case 'sleep_hours':
        return Icons.nights_stay_rounded;
      case 'heart_rate':
        return Icons.favorite_rounded;
      case 'calories':
        return Icons.local_fire_department_rounded;
      case 'distance':
        return Icons.route_rounded;
      case 'spo2':
        return Icons.bloodtype_rounded;
      default:
        return Icons.analytics_rounded;
    }
  }

  IconData _historyIcon(String eventType) {
    switch (eventType) {
      case 'activity_completed':
        return Icons.check_circle_rounded;
      case 'reflection_submitted':
        return Icons.edit_note_rounded;
      case 'assessment_completed':
        return Icons.assignment_turned_in_rounded;
      default:
        return Icons.history_rounded;
    }
  }

  Widget _messageCard(String message) {
    return _WhiteCard(
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF0F3D84),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
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
