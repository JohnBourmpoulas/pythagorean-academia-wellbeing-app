import 'package:flutter/material.dart';

import '../../../repositories/program_repository.dart';
import '../../../repositories/task_repository.dart';
import 'admin_task_form_screen.dart';

class AdminTasksScreen extends StatefulWidget {
  const AdminTasksScreen({super.key});

  @override
  State<AdminTasksScreen> createState() => _AdminTasksScreenState();
}

class _AdminTasksScreenState extends State<AdminTasksScreen> {
  final ProgramRepository programRepository = ProgramRepository();
  final TaskRepository taskRepository = TaskRepository();

  bool isLoading = true;
  bool isDeleting = false;
  String? errorMessage;

  List<dynamic> programs = [];
  List<Map<String, dynamic>> tasks = [];

  int? selectedProgramId;
  int? selectedDay;

  @override
  void initState() {
    super.initState();
    loadProgramsAndTasks();
  }

  Future<void> loadProgramsAndTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final loadedPrograms = await programRepository.getPrograms();

      if (!mounted) return;

      programs = loadedPrograms;

      if (programs.isNotEmpty && selectedProgramId == null) {
        selectedProgramId = intValue(programs.first['id']);
      }

      normalizeSelectedDay();
      await loadTasks(showLoading: false);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  Future<void> loadTasks({bool showLoading = true}) async {
    if (selectedProgramId == null || selectedProgramId! <= 0) {
      setState(() {
        tasks = [];
        isLoading = false;
      });
      return;
    }

    if (showLoading) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final loadedTasks = await taskRepository.getProgramTasks(
        programId: selectedProgramId!,
        day: selectedDay,
      );

      if (!mounted) return;

      setState(() {
        tasks = loadedTasks;
        isLoading = false;
        errorMessage = null;
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

  String selectedProgramTitle() {
    if (selectedProgramId == null) return '';

    for (final program in programs) {
      if (intValue(program['id']) == selectedProgramId) {
        final title = textValue(program['title']);
        return title.isEmpty ? 'Untitled Program' : title;
      }
    }

    return '';
  }

  Map<String, dynamic>? selectedProgram() {
    if (selectedProgramId == null) return null;

    for (final program in programs) {
      if (intValue(program['id']) == selectedProgramId &&
          program is Map<String, dynamic>) {
        return program;
      }
    }

    return null;
  }

  int selectedProgramDurationWeeks() {
    final program = selectedProgram();
    if (program == null) return 1;

    final weeks = intValue(
      program['duration_weeks'] ??
          program['duration'] ??
          program['weeks'] ??
          program['total_weeks'],
    );

    return weeks <= 0 ? 1 : weeks;
  }

  int selectedProgramTotalDays() {
    final days = selectedProgramDurationWeeks() * 7;
    return days <= 0 ? 7 : days;
  }

  String selectedProgramDurationLabel() {
    final weeks = selectedProgramDurationWeeks();
    final days = selectedProgramTotalDays();

    if (weeks == 1) return '1 week • $days days';
    return '$weeks weeks • $days days';
  }

  void normalizeSelectedDay() {
    if (selectedDay == null) return;

    final totalDays = selectedProgramTotalDays();
    if (selectedDay! > totalDays) {
      selectedDay = totalDays;
    }

    if (selectedDay! <= 0) {
      selectedDay = 1;
    }
  }

  Future<void> openCreateTask() async {
    if (selectedProgramId == null || selectedProgramId! <= 0) {
      showMessage('Please select a program first');
      return;
    }

    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminTaskFormScreen(
          programId: selectedProgramId!,
          dayNumber: selectedDay ?? 1,
          totalProgramDays: selectedProgramTotalDays(),
        ),
      ),
    );

    if (refresh == true) {
      loadTasks();
    }
  }

  Future<void> openEditTask(Map<String, dynamic> task) async {
    final programId = intValue(task['program_id']) > 0
        ? intValue(task['program_id'])
        : selectedProgramId;

    if (programId == null || programId <= 0) {
      showMessage('Invalid program');
      return;
    }

    final dayNumber = intValue(task['day_number']) > 0
        ? intValue(task['day_number'])
        : selectedDay ?? 1;

    final refresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AdminTaskFormScreen(
          programId: programId,
          dayNumber: dayNumber,
          totalProgramDays: selectedProgramTotalDays(),
          task: task,
        ),
      ),
    );

    if (refresh == true) {
      loadTasks();
    }
  }

  Future<void> deleteTask(Map<String, dynamic> task) async {
    final id = intValue(task['id']);

    if (id <= 0) {
      showMessage('Invalid task');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
          'Are you sure you want to delete this daily task?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => isDeleting = true);

    try {
      final success = await taskRepository.deleteTask(id);

      if (!mounted) return;

      setState(() => isDeleting = false);

      if (!success) {
        showMessage('Could not delete task');
        return;
      }

      showMessage('Task deleted');
      loadTasks();
    } catch (e) {
      if (!mounted) return;
      setState(() => isDeleting = false);
      showMessage(e.toString());
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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

  String typeLabel(String type) {
    if (type.trim().isEmpty) return 'Custom';
    final clean = type.trim();
    return clean[0].toUpperCase() + clean.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: selectedProgramId == null ? null : openCreateTask,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2F61D2),
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Task',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _Gradient(
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: loadProgramsAndTasks,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(),
                  const SizedBox(height: 26),
                  _filtersCard(),
                  const SizedBox(height: 22),
                  if (isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 80),
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    )
                  else if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else if (tasks.isEmpty)
                      _emptyCard()
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

  Widget _topBar() {
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
            'Daily Tasks',
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

  Widget _filtersCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Program Builder',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create the daily plan that participants will complete by the end of each day.',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.timelapse_rounded,
                  color: Color(0xFF2F61D2),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    selectedProgramId == null
                        ? 'Select a program'
                        : 'Program duration: ${selectedProgramDurationLabel()}',
                    style: const TextStyle(
                      color: Color(0xFF0F3D84),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          DropdownButtonFormField<int>(
            value: selectedProgramId,
            isExpanded: true,
            decoration: _inputDecoration('Program'),
            items: programs.map((program) {
              final id = intValue(program['id']);
              final title = textValue(program['title']);

              return DropdownMenuItem<int>(
                value: id,
                child: Text(
                  title.isEmpty ? 'Untitled Program' : title,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) async {
              setState(() {
                selectedProgramId = value;
                normalizeSelectedDay();
              });
              await loadTasks();
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<int?>(
            value: selectedDay,
            isExpanded: true,
            decoration: _inputDecoration('Day'),
            items: [
              const DropdownMenuItem<int?>(
                value: null,
                child: Text('All Days'),
              ),
              ...List.generate(
                selectedProgramTotalDays(),
                    (index) => DropdownMenuItem<int?>(
                  value: index + 1,
                  child: Text('Day ${index + 1}'),
                ),
              ),
            ],
            onChanged: (value) async {
              setState(() => selectedDay = value);
              await loadTasks();
            },
          ),
        ],
      ),
    );
  }

  Widget _taskCard(Map<String, dynamic> task) {
    final title = textValue(task['title']);
    final description = textValue(task['description']);
    final type = textValue(task['task_type']);
    final day = textValue(task['day_number']);
    final points = textValue(task['points']);
    final duration = textValue(task['duration_minutes']);
    final libraryTitle = textValue(task['library_title']);
    final instructions = textValue(task['instructions']);
    final isRequired = intValue(task['is_required']) == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(22),
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
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => openEditTask(task),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 31,
                  backgroundColor: const Color(0xFFE8F1FF),
                  child: Icon(
                    iconForType(type),
                    color: const Color(0xFF2F61D2),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${typeLabel(type).toUpperCase()} • DAY ${day.isEmpty ? '-' : day}',
                        style: const TextStyle(
                          color: Color(0xFF2F61D2),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title.isEmpty ? 'Untitled task' : title,
                        style: const TextStyle(
                          color: Color(0xFF0F3D84),
                          fontSize: 21,
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
              ],
            ),
          ),
          if (libraryTitle.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoPill(
              icon: Icons.menu_book_rounded,
              text: libraryTitle,
            ),
          ],
          if (instructions.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                instructions,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (duration.isNotEmpty)
                _InfoPill(
                  icon: Icons.timer_rounded,
                  text: '$duration min',
                ),
              if (duration.isNotEmpty) const SizedBox(width: 8),
              _InfoPill(
                icon: Icons.star_rounded,
                text: '${points.isEmpty ? '0' : points} pts',
              ),
              const SizedBox(width: 8),
              _InfoPill(
                icon: isRequired
                    ? Icons.priority_high_rounded
                    : Icons.remove_rounded,
                text: isRequired ? 'Required' : 'Optional',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => openEditTask(task),
                  icon: const Icon(Icons.edit_rounded),
                  label: const Text('Edit'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2F61D2),
                    side: const BorderSide(color: Color(0xFF2F61D2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: isDeleting ? null : () => deleteTask(task),
                icon: const Icon(
                  Icons.delete_rounded,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return _WhiteCard(
      child: Column(
        children: [
          const Icon(
            Icons.task_alt_rounded,
            color: Color(0xFF2F61D2),
            size: 58,
          ),
          const SizedBox(height: 16),
          Text(
            selectedProgramId == null
                ? 'No programs found'
                : selectedDay == null
                ? 'No tasks found'
                : 'No tasks for Day $selectedDay',
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedProgramId == null
                ? 'Create or select a program first.'
                : 'Use Add Task to build the daily program plan for ${selectedProgramDurationLabel()}.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
              height: 1.35,
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
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: const Color(0xFFF4F6FA),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
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
