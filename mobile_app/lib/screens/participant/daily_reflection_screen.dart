import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class DailyReflectionScreen extends StatefulWidget {
  const DailyReflectionScreen({super.key});

  @override
  State<DailyReflectionScreen> createState() => _DailyReflectionScreenState();
}

class _DailyReflectionScreenState extends State<DailyReflectionScreen> {
  final notesController = TextEditingController();

  int mood = 3;
  int stress = 3;
  int energy = 3;
  int sleep = 3;

  bool isSaving = false;

  Future<void> saveReflection() async {
    setState(() => isSaving = true);

    final response = await ApiService.post(
      '/participant/save_reflection.php',
      {
        'mood_level': mood,
        'stress_level': stress,
        'energy_level': energy,
        'sleep_quality': sleep,
        'notes': notesController.text.trim(),
      },
      auth: true,
    );

    if (!mounted) return;

    setState(() => isSaving = false);

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not save reflection',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reflection saved successfully')),
    );

    Navigator.pop(context, true);
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _card(),
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        const Text(
          'Daily\nReflection',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            height: 1.1,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _card() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _slider('Mood', mood, Icons.sentiment_satisfied_alt_rounded, (v) {
            setState(() => mood = v);
          }),
          _slider('Stress', stress, Icons.psychology_rounded, (v) {
            setState(() => stress = v);
          }),
          _slider('Energy', energy, Icons.bolt_rounded, (v) {
            setState(() => energy = v);
          }),
          _slider('Sleep Quality', sleep, Icons.nightlight_round, (v) {
            setState(() => sleep = v);
          }),
          const SizedBox(height: 22),
          const Text(
            'Notes',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: notesController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Write how you feel today...',
              filled: true,
              fillColor: const Color(0xFFF4F6FA),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: isSaving ? null : saveReflection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F61D2),
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                isSaving ? 'Please wait...' : 'Save Reflection',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
      String title,
      int value,
      IconData icon,
      Function(int) onChanged,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF2F61D2)),
              const SizedBox(width: 10),
              Text(
                '$title: $value/5',
                style: const TextStyle(
                  color: Color(0xFF0F3D84),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            label: value.toString(),
            activeColor: const Color(0xFF2F61D2),
            onChanged: (v) => onChanged(v.round()),
          ),
        ],
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