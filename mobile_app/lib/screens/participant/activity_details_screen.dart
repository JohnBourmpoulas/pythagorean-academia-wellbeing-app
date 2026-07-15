import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class ActivityDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> task;

  const ActivityDetailsScreen({
    super.key,
    required this.task,
  });

  @override
  State<ActivityDetailsScreen> createState() => _ActivityDetailsScreenState();
}

class _ActivityDetailsScreenState extends State<ActivityDetailsScreen> {
  bool isLoading = false;
  late bool isCompleted;

  @override
  void initState() {
    super.initState();
    isCompleted = textValue(widget.task['status']) == 'completed';
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

  String labelForType(String type) {
    if (type.isEmpty) return 'Custom';
    return type[0].toUpperCase() + type.substring(1).toLowerCase();
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

  Future<void> completeTask() async {
    if (isCompleted) return;

    setState(() => isLoading = true);

    final response = await ApiService.post(
      '/participant/complete_task.php',
      {
        'task_id': widget.task['program_daily_task_id'] ?? widget.task['id'],
      },
      auth: true,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not complete activity',
          ),
        ),
      );
      return;
    }

    setState(() => isCompleted = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '+${response['points_earned'] ?? intValue(widget.task['points'])} points earned',
        ),
      ),
    );

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final title = textValue(widget.task['title']);
    final description = textValue(widget.task['description']);
    final instructions = textValue(widget.task['instructions']);
    final type = textValue(widget.task['task_type']);
    final libraryTitle = textValue(widget.task['library_title']);
    final duration = intValue(widget.task['duration_minutes']);
    final points = intValue(widget.task['points']);
    final required = intValue(widget.task['is_required']) == 1;

    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context),
                const SizedBox(height: 28),
                _WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: isCompleted
                            ? const Color(0xFFDDFBE8)
                            : const Color(0xFFE8F1FF),
                        child: Icon(
                          isCompleted ? Icons.check_circle_rounded : iconForType(type),
                          color: isCompleted ? Colors.green : const Color(0xFF2F61D2),
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isCompleted
                            ? 'COMPLETED • ${labelForType(type).toUpperCase()}'
                            : labelForType(type).toUpperCase(),
                        style: TextStyle(
                          color: isCompleted ? Colors.green : const Color(0xFF2F61D2),
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        title.isEmpty ? 'Untitled activity' : title,
                        style: const TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 28,
                          height: 1.15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 18),
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
                      if (libraryTitle.isNotEmpty) ...[
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F6FA),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.menu_book_rounded,
                                color: Color(0xFF2F61D2),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  libraryTitle,
                                  style: const TextStyle(
                                    color: Color(0xFF0F3D84),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      const Text(
                        'Description',
                        style: TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description.isEmpty ? 'No description provided.' : description,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      if (instructions.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Instructions',
                          style: TextStyle(
                            color: Color(0xFF0F3D84),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          instructions,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 16,
                            height: 1.4,
                          ),
                        ),
                      ],
                      const SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isCompleted || isLoading ? null : completeTask,
                          icon: isLoading
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.check_rounded,
                          ),
                          label: Text(
                            isCompleted
                                ? 'Completed'
                                : isLoading
                                ? 'Please wait...'
                                : 'Mark as Completed',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCompleted
                                ? Colors.green
                                : const Color(0xFF2F61D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
            onPressed: () => Navigator.pop(context, isCompleted),
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'Activity',
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
