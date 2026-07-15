import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'activity_details_screen.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  bool isLoading = true;
  String? errorMessage;

  List<Map<String, dynamic>> tasks = [];
  Map<String, dynamic>? program;
  Map<String, dynamic>? summary;

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await ApiService.get(
        '/participant/daily_plan.php',
        auth: true,
      );

      if (!mounted) return;

      if (response['success'] != true) {
        setState(() {
          isLoading = false;
          errorMessage = response['message']?.toString() ?? 'Could not load plan';
        });
        return;
      }

      setState(() {
        tasks = List<Map<String, dynamic>>.from(response['tasks'] ?? []);
        program = Map<String, dynamic>.from(response['program'] ?? {});
        summary = Map<String, dynamic>.from(response['summary'] ?? {});
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  int intValue(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String textValue(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    if (text == 'null') return '';
    return text;
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
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    final completed = intValue(summary?['completed_tasks']);
    final total = intValue(summary?['total_tasks']);
    final todayProgress = intValue(summary?['today_progress']);
    final currentDay = intValue(program?['current_day']);
    final currentWeek = intValue(program?['current_week']);
    final programTitle = textValue(program?['title']);

    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
              : RefreshIndicator(
            onRefresh: loadTasks,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 24),
                  _programHeader(
                    programTitle: programTitle,
                    currentDay: currentDay,
                    currentWeek: currentWeek,
                    completed: completed,
                    total: total,
                    progress: todayProgress,
                  ),
                  const SizedBox(height: 22),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else if (tasks.isEmpty)
                    _messageCard('No activities scheduled for today')
                  else
                    ...tasks.map(_taskCard),
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
            onPressed: () => Navigator.maybePop(context),
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            "Today's Plan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _programHeader({
    required String programTitle,
    required int currentDay,
    required int currentWeek,
    required int completed,
    required int total,
    required int progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            programTitle.isEmpty ? 'Current Program' : programTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Day $currentDay • Week $currentWeek',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0, 100) / 100,
                    minHeight: 10,
                    backgroundColor: const Color(0xFFE8F1FF),
                    color: const Color(0xFF2F61D2),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: Color(0xFF0F3D84),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$completed of $total activities completed',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _taskCard(Map<String, dynamic> task) {
    final status = textValue(task['status']);
    final completed = status == 'completed';
    final type = textValue(task['task_type']);
    final title = textValue(task['title']);
    final description = textValue(task['description']);
    final duration = intValue(task['duration_minutes']);
    final points = intValue(task['points']);
    final required = intValue(task['is_required']) == 1;
    final libraryTitle = textValue(task['library_title']);

    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: () async {
        final refresh = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ActivityDetailsScreen(task: task)),
        );

        if (refresh == true) {
          loadTasks();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 14,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: completed
                      ? const Color(0xFFDDFBE8)
                      : const Color(0xFFE8F1FF),
                  child: Icon(
                    completed ? Icons.check_circle_rounded : iconForType(type),
                    color: completed ? Colors.green : const Color(0xFF2F61D2),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        completed
                            ? 'COMPLETED • ${labelForType(type).toUpperCase()}'
                            : labelForType(type).toUpperCase(),
                        style: TextStyle(
                          color: completed ? Colors.green : const Color(0xFF2F61D2),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title.isEmpty ? 'Untitled activity' : title,
                        style: const TextStyle(
                          fontSize: 21,
                          color: Color(0xFF0F3D84),
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
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: completed ? Colors.green : const Color(0xFFCBD5E1),
                ),
              ],
            ),
            if (libraryTitle.isNotEmpty) ...[
              const SizedBox(height: 14),
              _InfoPill(
                icon: Icons.menu_book_rounded,
                text: libraryTitle,
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                if (duration > 0)
                  _InfoPill(
                    icon: Icons.timer_rounded,
                    text: '$duration min',
                  ),
                if (duration > 0) const SizedBox(width: 8),
                _InfoPill(
                  icon: Icons.star_rounded,
                  text: '$points pts',
                ),
                const SizedBox(width: 8),
                _InfoPill(
                  icon: required ? Icons.priority_high_rounded : Icons.remove_rounded,
                  text: required ? 'Required' : 'Optional',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
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
    return Flexible(
      child: Container(
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
      ),
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
