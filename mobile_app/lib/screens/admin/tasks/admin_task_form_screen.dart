import 'package:flutter/material.dart';

import '../../../repositories/task_repository.dart';
import '../../../services/api_service.dart';

class AdminTaskFormScreen extends StatefulWidget {
  final int programId;
  final int dayNumber;
  final int? totalProgramDays;
  final Map<String, dynamic>? task;

  const AdminTaskFormScreen({
    super.key,
    required this.programId,
    required this.dayNumber,
    this.totalProgramDays,
    this.task,
  });

  @override
  State<AdminTaskFormScreen> createState() => _AdminTaskFormScreenState();
}

class _AdminTaskFormScreenState extends State<AdminTaskFormScreen> {
  final TaskRepository repository = TaskRepository();

  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();
  final pointsController = TextEditingController();
  final instructionsController = TextEditingController();
  final orderController = TextEditingController();

  bool isSaving = false;
  bool isLoadingLibrary = true;

  int dayNumber = 1;
  String taskType = 'custom';
  bool isRequired = true;
  int? selectedLibraryItemId;

  List<Map<String, dynamic>> libraryItems = [];

  final List<Map<String, dynamic>> taskTypes = const [
    {'label': 'Custom', 'value': 'custom'},
    {'label': 'Video', 'value': 'video'},
    {'label': 'Audio', 'value': 'audio'},
    {'label': 'Article', 'value': 'article'},
    {'label': 'PDF', 'value': 'pdf'},
    {'label': 'Reflection', 'value': 'reflection'},
    {'label': 'Assessment', 'value': 'assessment'},
    {'label': 'Walking', 'value': 'walking'},
    {'label': 'Meditation', 'value': 'meditation'},
    {'label': 'Breathing', 'value': 'breathing'},
    {'label': 'Exercise', 'value': 'exercise'},
  ];

  bool get isEditing => widget.task != null;

  int get maxProgramDays {
    final value = widget.totalProgramDays ?? 30;
    return value <= 0 ? 30 : value;
  }

  int get durationWeeks {
    final weeks = (maxProgramDays / 7).ceil();
    return weeks <= 0 ? 1 : weeks;
  }

  int clampDay(int value) {
    if (value <= 0) return 1;
    if (value > maxProgramDays) return maxProgramDays;
    return value;
  }

  @override
  void initState() {
    super.initState();
    dayNumber = clampDay(widget.dayNumber);
    fillForm();
    loadLibraryItems();
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    pointsController.dispose();
    instructionsController.dispose();
    orderController.dispose();
    super.dispose();
  }

  void fillForm() {
    final task = widget.task;

    if (task == null) {
      pointsController.text = '10';
      orderController.text = '0';
      return;
    }

    titleController.text = textValue(task, 'title');
    descriptionController.text = textValue(task, 'description');
    instructionsController.text = textValue(task, 'instructions');
    durationController.text = textValue(task, 'duration_minutes');
    pointsController.text = textValue(task, 'points').isEmpty
        ? '10'
        : textValue(task, 'points');
    orderController.text = textValue(task, 'order_index').isEmpty
        ? '0'
        : textValue(task, 'order_index');

    dayNumber = clampDay(intValue(task['day_number'], widget.dayNumber));
    taskType = textValue(task, 'task_type').isEmpty
        ? 'custom'
        : textValue(task, 'task_type');

    isRequired = intValue(task['is_required'], 1) == 1;

    final rawLibraryId = task['library_item_id'];
    if (rawLibraryId != null && rawLibraryId.toString().trim().isNotEmpty) {
      selectedLibraryItemId = int.tryParse(rawLibraryId.toString());
    }
  }

  Future<void> loadLibraryItems() async {
    setState(() => isLoadingLibrary = true);

    try {
      final response = await ApiService.get(
        '/admin/library/list.php',
        auth: true,
      );

      if (!mounted) return;

      if (response['success'] == true) {
        setState(() {
          libraryItems = List<Map<String, dynamic>>.from(
            response['items'] ??
                response['library'] ??
                response['resources'] ??
                response['data'] ??
                [],
          );
          isLoadingLibrary = false;
        });
      } else {
        setState(() => isLoadingLibrary = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoadingLibrary = false);
    }
  }

  String textValue(Map<String, dynamic> item, String key) {
    final raw = item[key];
    if (raw == null) return '';
    final text = raw.toString().trim();
    if (text == 'null') return '';
    return text;
  }

  int intValue(dynamic value, int fallback) {
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  bool get needsLibraryItem {
    return ['video', 'audio', 'article', 'pdf'].contains(taskType);
  }

  List<Map<String, dynamic>> filteredLibraryItems() {
    if (!needsLibraryItem) return [];

    return libraryItems.where((item) {
      final type = (item['type'] ?? item['media_type'] ?? '')
          .toString()
          .toLowerCase();

      if (taskType == 'pdf') {
        return type == 'pdf' || type == 'document';
      }

      return type == taskType;
    }).toList();
  }

  Future<void> saveTask() async {
    final title = titleController.text.trim();

    if (title.isEmpty) {
      showMessage('Title is required');
      return;
    }

    if (needsLibraryItem && selectedLibraryItemId == null) {
      showMessage('Please select a library item');
      return;
    }

    setState(() => isSaving = true);

    final data = {
      if (isEditing) 'id': widget.task!['id'],
      'program_id': widget.programId,
      'day_number': dayNumber,
      'order_index': int.tryParse(orderController.text.trim()) ?? 0,
      'title': title,
      'description': descriptionController.text.trim(),
      'task_type': taskType,
      'library_item_id': needsLibraryItem ? selectedLibraryItemId : null,
      'duration_minutes': durationController.text.trim().isEmpty
          ? null
          : int.tryParse(durationController.text.trim()),
      'points': int.tryParse(pointsController.text.trim()) ?? 10,
      'instructions': instructionsController.text.trim(),
      'is_required': isRequired ? 1 : 0,
    };

    try {
      final success = isEditing
          ? await repository.updateTask(data)
          : await repository.createTask(data);

      if (!mounted) return;

      setState(() => isSaving = false);

      if (!success) {
        showMessage('Could not save task');
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEditing ? 'Task updated' : 'Task created'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() => isSaving = false);
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

  @override
  Widget build(BuildContext context) {
    final library = filteredLibraryItems();

    return Scaffold(
      body: _Gradient(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(),
                const SizedBox(height: 28),
                _WhiteCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Basic Information'),
                      _input(
                        controller: titleController,
                        label: 'Title',
                        icon: Icons.title_rounded,
                      ),
                      const SizedBox(height: 14),
                      _input(
                        controller: descriptionController,
                        label: 'Description',
                        icon: Icons.description_rounded,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 22),
                      _sectionTitle('Task Setup'),
                      _programDurationInfo(),
                      const SizedBox(height: 14),
                      _dayDropdown(),
                      const SizedBox(height: 14),
                      _typeDropdown(),
                      const SizedBox(height: 14),
                      if (needsLibraryItem)
                        isLoadingLibrary
                            ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 18),
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        )
                            : _libraryDropdown(library),
                      if (needsLibraryItem) const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _input(
                              controller: durationController,
                              label: 'Duration',
                              icon: Icons.timer_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _input(
                              controller: pointsController,
                              label: 'Points',
                              icon: Icons.star_rounded,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _input(
                        controller: orderController,
                        label: 'Order',
                        icon: Icons.format_list_numbered_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 18),
                      _requiredSwitch(),
                      const SizedBox(height: 22),
                      _sectionTitle('Instructions'),
                      _input(
                        controller: instructionsController,
                        label: 'Instructions for participant',
                        icon: Icons.info_rounded,
                        maxLines: 5,
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: isSaving ? null : saveTask,
                          icon: isSaving
                              ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : const Icon(Icons.save_rounded),
                          label: Text(
                            isSaving
                                ? 'Saving...'
                                : isEditing
                                ? 'Update Task'
                                : 'Create Task',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                ),
              ],
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
        Expanded(
          child: Text(
            isEditing ? 'Edit Task' : 'Add Task',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0F3D84),
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: const Color(0xFF2F61D2)),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _programDurationInfo() {
    return Container(
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
              'Program duration: $durationWeeks week${durationWeeks == 1 ? '' : 's'} • $maxProgramDays days',
              style: const TextStyle(
                color: Color(0xFF0F3D84),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayDropdown() {
    return DropdownButtonFormField<int>(
      value: dayNumber,
      decoration: InputDecoration(
        labelText: 'Program Day',
        prefixIcon: const Icon(
          Icons.calendar_today_rounded,
          color: Color(0xFF2F61D2),
        ),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      items: List.generate(
        maxProgramDays,
            (index) => DropdownMenuItem(
          value: index + 1,
          child: Text('Day ${index + 1}'),
        ),
      ),
      onChanged: (value) {
        if (value == null) return;
        setState(() => dayNumber = clampDay(value));
      },
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<String>(
      value: taskType,
      decoration: InputDecoration(
        labelText: 'Task Type',
        prefixIcon: Icon(
          iconForType(taskType),
          color: const Color(0xFF2F61D2),
        ),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      items: taskTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type['value'].toString(),
          child: Text(type['label'].toString()),
        );
      }).toList(),
      onChanged: (value) {
        if (value == null) return;

        setState(() {
          taskType = value;
          selectedLibraryItemId = null;
        });
      },
    );
  }

  Widget _libraryDropdown(List<Map<String, dynamic>> library) {
    if (library.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF4E5),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          'No $taskType resources found in Library.',
          style: const TextStyle(
            color: Color(0xFF92400E),
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    final validSelected = library.any(
          (item) => int.tryParse(item['id']?.toString() ?? '') == selectedLibraryItemId,
    );

    return DropdownButtonFormField<int>(
      value: validSelected ? selectedLibraryItemId : null,
      decoration: InputDecoration(
        labelText: 'Library Item',
        prefixIcon: const Icon(
          Icons.menu_book_rounded,
          color: Color(0xFF2F61D2),
        ),
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      items: library.map((item) {
        final id = int.tryParse(item['id']?.toString() ?? '') ?? 0;
        final title = item['title']?.toString() ?? 'Untitled resource';

        return DropdownMenuItem<int>(
          value: id,
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => selectedLibraryItemId = value);
      },
    );
  }

  Widget _requiredSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F1FF),
            child: Icon(
              isRequired
                  ? Icons.priority_high_rounded
                  : Icons.remove_rounded,
              color: const Color(0xFF2F61D2),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Required Task',
                  style: TextStyle(
                    color: Color(0xFF0F3D84),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Participant should complete this by the end of the day.',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: isRequired,
            activeColor: const Color(0xFF2F61D2),
            onChanged: (value) {
              setState(() => isRequired = value);
            },
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