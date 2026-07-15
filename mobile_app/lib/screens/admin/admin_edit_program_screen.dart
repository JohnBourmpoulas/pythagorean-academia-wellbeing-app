import 'package:flutter/material.dart';

import '../../models/program.dart';
import '../../repositories/program_repository.dart';
import '../../widgets/app_widgets.dart';

class AdminEditProgramScreen extends StatefulWidget {
  final Program program;

  const AdminEditProgramScreen({
    super.key,
    required this.program,
  });

  @override
  State<AdminEditProgramScreen> createState() => _AdminEditProgramScreenState();
}

class _AdminEditProgramScreenState extends State<AdminEditProgramScreen> {
  final ProgramRepository programRepository = ProgramRepository();

  late final TextEditingController titleController;
  late final TextEditingController shortTitleController;
  late final TextEditingController descriptionController;
  late final TextEditingController durationController;
  late final TextEditingController maxParticipantsController;
  late final TextEditingController statusController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleController = TextEditingController(text: widget.program.title);
    shortTitleController =
        TextEditingController(text: widget.program.shortTitle);
    descriptionController =
        TextEditingController(text: widget.program.description);
    durationController =
        TextEditingController(text: widget.program.durationWeeks.toString());
    maxParticipantsController = TextEditingController(
      text: widget.program.maxParticipants?.toString() ?? '',
    );
    statusController = TextEditingController(text: widget.program.status);
  }

  Future<void> saveChanges() async {
    final duration = int.tryParse(durationController.text.trim());
    final maxParticipants =
    int.tryParse(maxParticipantsController.text.trim());

    if (titleController.text.trim().isEmpty ||
        shortTitleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        duration == null ||
        duration <= 0 ||
        statusController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await programRepository.updateProgram(
      programId: widget.program.id,
      title: titleController.text,
      shortTitle: shortTitleController.text,
      description: descriptionController.text,
      durationWeeks: duration,
      status: statusController.text,
      maxParticipants: maxParticipants,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not update program')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Program updated successfully')),
    );

    Navigator.pop(context);
  }

  Future<void> deleteProgram() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Program'),
        content: const Text(
          'Are you sure you want to delete this program?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) return;

    setState(() => isLoading = true);

    final success = await programRepository.deleteProgram(widget.program.id);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete program')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Program deleted successfully')),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    shortTitleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    maxParticipantsController.dispose();
    statusController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppGradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _topBar(context, 'Edit Program'),
                const SizedBox(height: 34),
                WhiteCard(
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Program Title',
                        hint: '',
                        controller: titleController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Short Title',
                        hint: '',
                        controller: shortTitleController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Description',
                        hint: '',
                        controller: descriptionController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Duration (weeks)',
                        hint: '',
                        controller: durationController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Max Participants',
                        hint: '',
                        controller: maxParticipantsController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Status',
                        hint: 'active / inactive',
                        controller: statusController,
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        text: isLoading ? 'Please wait...' : 'Save Changes',
                        onPressed: isLoading ? () {} : () => saveChanges(),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: isLoading ? null : deleteProgram,
                          child: const Text('Delete Program'),
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

  Widget _topBar(BuildContext context, String title) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.white.withOpacity(0.2),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}