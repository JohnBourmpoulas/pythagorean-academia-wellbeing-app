import 'package:flutter/material.dart';

import '../../repositories/program_repository.dart';
import '../../widgets/app_widgets.dart';

class AdminCreateProgramScreen extends StatefulWidget {
  const AdminCreateProgramScreen({super.key});

  @override
  State<AdminCreateProgramScreen> createState() =>
      _AdminCreateProgramScreenState();
}

class _AdminCreateProgramScreenState extends State<AdminCreateProgramScreen> {
  final ProgramRepository programRepository = ProgramRepository();

  final titleController = TextEditingController();
  final shortTitleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController();
  final maxParticipantsController = TextEditingController();

  bool isLoading = false;

  Future<void> createProgram() async {
    final duration = int.tryParse(durationController.text.trim());
    final maxParticipants =
    int.tryParse(maxParticipantsController.text.trim());

    if (titleController.text.trim().isEmpty ||
        shortTitleController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty ||
        duration == null ||
        duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    setState(() => isLoading = true);

    final success = await programRepository.createProgram(
      title: titleController.text,
      shortTitle: shortTitleController.text,
      description: descriptionController.text,
      durationWeeks: duration,
      maxParticipants: maxParticipants,
    );

    if (!mounted) return;

    setState(() => isLoading = false);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not create program')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Program created successfully')),
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
                _topBar(context, 'Create New\nProgram'),
                const SizedBox(height: 28),
                WhiteCard(
                  child: Column(
                    children: [
                      AppTextField(
                        label: 'Program Title',
                        hint: 'Enter program title',
                        controller: titleController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Short Title',
                        hint: 'Short program title',
                        controller: shortTitleController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Description',
                        hint: 'Program description',
                        controller: descriptionController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Duration (weeks)',
                        hint: '8',
                        controller: durationController,
                      ),
                      const SizedBox(height: 18),
                      AppTextField(
                        label: 'Max Participants',
                        hint: '50',
                        controller: maxParticipantsController,
                      ),
                      const SizedBox(height: 28),
                      PrimaryButton(
                        text: isLoading ? 'Please wait...' : 'Create Program',
                        onPressed: isLoading ? () {} : () => createProgram(),
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
            height: 1.15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}