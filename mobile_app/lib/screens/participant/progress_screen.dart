import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? progress;

  @override
  void initState() {
    super.initState();
    loadProgress();
  }

  Future<void> loadProgress() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/participant/progress.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load progress';
      });
      return;
    }

    setState(() {
      progress = Map<String, dynamic>.from(response['progress'] ?? {});
      isLoading = false;
    });
  }

  int value(String key) {
    return int.tryParse(progress?[key]?.toString() ?? '') ?? 0;
  }

  String text(String key) {
    final raw = progress?[key];
    if (raw == null) return '';
    final output = raw.toString().trim();
    if (output == 'null') return '';
    return output;
  }

  List<Map<String, dynamic>> listValue(String key) {
    final raw = progress?[key];
    if (raw is List) {
      return raw.map((item) => Map<String, dynamic>.from(item)).toList();
    }
    return [];
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
            onRefresh: loadProgress,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 26),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else ...[
                    _summaryCard(),
                    const SizedBox(height: 22),
                    _pointsCard(),
                    const SizedBox(height: 22),
                    _weeklyCard(),
                    const SizedBox(height: 22),
                    _achievementsCard(),
                    const SizedBox(height: 22),
                    _historyCard(),
                  ],
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
            onPressed: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'Progress',
            style: TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    final percent = value('progress_percent').clamp(0, 100);
    final completed = value('completed_tasks');
    final total = value('total_tasks');
    final streak = value('streak');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text('program_title').isEmpty
                ? 'Current Program'
                : text('program_title'),
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 24,
              height: 1.22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Week ${value('current_week')} of ${value('total_weeks')}',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 26),
          Center(
            child: _LargePercentCircle(percent: percent),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  title: 'Completed',
                  value: completed.toString(),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  title: 'Total',
                  value: total.toString(),
                ),
              ),
              Expanded(
                child: _MiniStat(
                  title: 'Streak',
                  value: '${streak}d',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pointsCard() {
    final totalPoints = value('total_points');
    final remaining = value('remaining_tasks');
    final wellnessScore = value('wellness_score');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Program Summary',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _MetricBox(
                  icon: Icons.star_rounded,
                  title: 'Points',
                  value: totalPoints.toString(),
                  iconColor: Color(0xFFFF9800),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _MetricBox(
                  icon: Icons.pending_actions_rounded,
                  title: 'Remaining',
                  value: remaining.toString(),
                  iconColor: Color(0xFF2F61D2),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MetricBox(
            icon: Icons.favorite_rounded,
            title: 'Wellness Score',
            value: wellnessScore.toString(),
            iconColor: Color(0xFFFF2D55),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _weeklyCard() {
    final rows = listValue('weekly_progress');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 165,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final item = index < rows.length ? rows[index] : {};
                final percent =
                (int.tryParse(item['percent']?.toString() ?? '') ?? 0)
                    .clamp(0, 100);

                final dateText = item['day']?.toString() ??
                    item['label']?.toString() ??
                    _shortDay(index);

                final barHeight = 28 + (percent * 0.75);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight.toDouble(),
                          width: 26,
                          decoration: BoxDecoration(
                            color: percent > 0
                                ? const Color(0xFF2F61D2)
                                : const Color(0xFFDCEBFF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '$percent%',
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 10,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          dateText.length > 3
                              ? dateText.substring(0, 3)
                              : dateText,
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 10,
                            height: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _shortDay(int index) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[index];
  }

  Widget _achievementsCard() {
    final items = listValue('achievements');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Achievements',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text(
              'Complete activities to unlock achievements.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                height: 1.35,
              ),
            )
          else
            ...items.map(
                  (item) => _ListItem(
                icon: iconFromName(item['icon']?.toString() ?? ''),
                title: item['title']?.toString() ?? '',
                subtitle: item['description']?.toString() ?? '',
              ),
            ),
        ],
      ),
    );
  }

  IconData iconFromName(String icon) {
    switch (icon) {
      case 'check_circle':
        return Icons.check_circle_rounded;
      case 'local_fire_department':
        return Icons.local_fire_department_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'flag':
        return Icons.flag_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      default:
        return Icons.emoji_events_rounded;
    }
  }

  Widget _historyCard() {
    final items = listValue('history');

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent History',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          if (items.isEmpty)
            const Text(
              'No activity history yet.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                height: 1.35,
              ),
            )
          else
            ...items.map(
                  (item) => _ListItem(
                icon: Icons.history_rounded,
                title: item['title']?.toString() ?? '',
                subtitle: item['created_at']?.toString() ?? '',
              ),
            ),
        ],
      ),
    );
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

class _LargePercentCircle extends StatelessWidget {
  final int percent;

  const _LargePercentCircle({required this.percent});

  @override
  Widget build(BuildContext context) {
    final safe = percent.clamp(0, 100);

    return SizedBox(
      width: 166,
      height: 166,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 150,
            height: 150,
            child: CircularProgressIndicator(
              value: safe / 100,
              strokeWidth: 15,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFE8EEF8),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF5A5CF6)),
            ),
          ),
          Container(
            width: 104,
            height: 104,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$safe%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F3D84),
                  fontSize: 33,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String title;
  final String value;

  const _MiniStat({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF0F3D84),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _MetricBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;
  final bool fullWidth;

  const _MetricBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 14,
                fontWeight: FontWeight.w600,
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
}

class _ListItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: const Color(0xFFE8F1FF),
        child: Icon(icon, color: const Color(0xFF2F61D2)),
      ),
      title: Text(
        title.isEmpty ? 'Untitled' : title,
        style: const TextStyle(
          color: Color(0xFF0F3D84),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: subtitle.isEmpty ? null : Text(subtitle),
    );
  }
}

class _WhiteCard extends StatelessWidget {
  final Widget child;

  const _WhiteCard({
    required this.child,
  });

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

  const _Gradient({
    required this.child,
  });

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
