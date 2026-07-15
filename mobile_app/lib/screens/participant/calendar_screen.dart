import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  bool isLoading = true;
  String? errorMessage;

  Map<String, dynamic>? program;
  Map<String, dynamic>? summary;
  List<Map<String, dynamic>> events = [];
  List<Map<String, dynamic>> days = [];

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  Future<void> loadEvents() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.get(
        '/participant/calendar.php',
        auth: true,
      );

      if (!mounted) return;

      if (response['success'] != true) {
        setState(() {
          isLoading = false;
          errorMessage =
              response['message']?.toString() ?? 'Could not load calendar';
        });
        return;
      }

      setState(() {
        program = Map<String, dynamic>.from(response['program'] ?? {});
        summary = Map<String, dynamic>.from(response['summary'] ?? {});
        events = List<Map<String, dynamic>>.from(response['events'] ?? []);
        days = List<Map<String, dynamic>>.from(response['days'] ?? []);
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Could not load calendar';
      });
    }
  }

  Map<String, List<Map<String, dynamic>>> groupedEvents() {
    final map = <String, List<Map<String, dynamic>>>{};

    for (final event in events) {
      final date = text(event['task_date']).isEmpty
          ? 'Unknown date'
          : text(event['task_date']);

      map.putIfAbsent(date, () => []);
      map[date]!.add(event);
    }

    return map;
  }

  int intValue(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String text(dynamic value) {
    if (value == null) return '';
    final result = value.toString().trim();
    if (result == 'null') return '';
    return result;
  }

  String formatDate(String rawDate) {
    if (rawDate.isEmpty || rawDate == 'Unknown date') return rawDate;

    try {
      final date = DateTime.parse(rawDate);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  String dayName(String rawDate) {
    try {
      final date = DateTime.parse(rawDate);
      const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return names[date.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  bool isCompleted(Map<String, dynamic> event) {
    return text(event['status']) == 'completed';
  }

  IconData iconForType(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Icons.play_circle_fill_rounded;
      case 'audio':
        return Icons.headphones_rounded;
      case 'article':
        return Icons.article_rounded;
      case 'pdf':
        return Icons.picture_as_pdf_rounded;
      case 'reflection':
        return Icons.edit_note_rounded;
      case 'assessment':
        return Icons.assignment_rounded;
      case 'walking':
        return Icons.directions_walk_rounded;
      case 'meditation':
        return Icons.self_improvement_rounded;
      case 'breathing':
        return Icons.air_rounded;
      case 'exercise':
        return Icons.fitness_center_rounded;
      default:
        return Icons.task_alt_rounded;
    }
  }

  String labelForType(String type) {
    if (type.isEmpty) return 'Custom';
    return type[0].toUpperCase() + type.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupedEvents();

    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
              : RefreshIndicator(
            onRefresh: loadEvents,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 28),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else ...[
                    _summaryCard(),
                    const SizedBox(height: 22),
                    _weekOverviewCard(),
                    const SizedBox(height: 22),
                    if (events.isEmpty)
                      _messageCard('No calendar activities found')
                    else
                      ...grouped.entries.map(
                            (entry) => _dateGroup(entry.key, entry.value),
                      ),
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
          backgroundColor: Colors.white.withValues(alpha: 0.18),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'Calendar',
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

  Widget _summaryCard() {
    final programTitle = text(program?['title']).isEmpty
        ? 'Current Program'
        : text(program?['title']);

    final completed = intValue(summary?['completed']);
    final total = intValue(summary?['total']);
    final pending = intValue(summary?['pending']);
    final percent = intValue(summary?['percent']);

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Program Calendar',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            programTitle,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _summaryMetric(
                  icon: Icons.check_circle_rounded,
                  label: 'Completed',
                  value: completed.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  icon: Icons.calendar_month_rounded,
                  label: 'Total',
                  value: total.toString(),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryMetric(
                  icon: Icons.schedule_rounded,
                  label: 'Pending',
                  value: pending.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: percent.clamp(0, 100) / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE8F1FF),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2F61D2),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Color(0xFF0F3D84),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryMetric({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2F61D2), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _weekOverviewCard() {
    final visibleDays = days.take(14).toList();

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Days',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          if (visibleDays.isEmpty)
            const Text(
              'No days found for this program.',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 15,
                height: 1.35,
              ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: visibleDays.map(_dayCircle).toList(),
            ),
        ],
      ),
    );
  }

  Widget _dayCircle(Map<String, dynamic> day) {
    final percent = intValue(day['percent']);
    final completed = percent == 100;
    final dayNumber = intValue(day['day_number']);

    return Container(
      width: 66,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: completed ? const Color(0xFFDDFBE8) : const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: completed ? Colors.green : const Color(0xFFE8F1FF),
        ),
      ),
      child: Column(
        children: [
          Icon(
            completed ? Icons.check_rounded : Icons.event_rounded,
            color: completed ? Colors.green : const Color(0xFF2F61D2),
            size: 20,
          ),
          const SizedBox(height: 6),
          Text(
            'D$dayNumber',
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$percent%',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dateGroup(String date, List<Map<String, dynamic>> items) {
    final completed = items.where(isCompleted).length;
    final total = items.length;
    final first = items.isNotEmpty ? items.first : <String, dynamic>{};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '${dayName(date)} ${formatDate(date)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              '$completed/$total done',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Day ${intValue(first['day_number'])} • Week ${intValue(first['week_number'])}',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        ...items.map(_eventCard),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _eventCard(Map<String, dynamic> event) {
    final completed = isCompleted(event);
    final type = text(event['task_type']);
    final duration = intValue(event['duration_minutes']);
    final points = intValue(event['points']);
    final required = intValue(event['is_required']) == 1;
    final description = text(event['description']);
    final libraryTitle = text(event['library_title']);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor:
            completed ? const Color(0xFFDDFBE8) : const Color(0xFFE8F1FF),
            child: Icon(
              completed ? Icons.check_rounded : iconForType(type),
              color: completed ? Colors.green : const Color(0xFF2F61D2),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${completed ? 'COMPLETED' : 'PENDING'} • ${labelForType(type).toUpperCase()}',
                  style: TextStyle(
                    color: completed ? Colors.green : const Color(0xFF2F61D2),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  text(event['title']).isEmpty
                      ? 'Untitled activity'
                      : text(event['title']),
                  style: const TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 20,
                    height: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
                if (libraryTitle.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _InfoPill(
                    icon: Icons.menu_book_rounded,
                    text: libraryTitle,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (duration > 0)
                      _InfoPill(
                        icon: Icons.timer_rounded,
                        text: '$duration min',
                      ),
                    _InfoPill(
                      icon: Icons.star_rounded,
                      text: '$points pts',
                    ),
                    _InfoPill(
                      icon: required
                          ? Icons.priority_high_rounded
                          : Icons.remove_rounded,
                      text: required ? 'Required' : 'Optional',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Icon(
            completed ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: completed ? Colors.green : const Color(0xFFCBD5E1),
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

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFF2F61D2), size: 15),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
            color: Colors.black.withValues(alpha: 0.10),
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
