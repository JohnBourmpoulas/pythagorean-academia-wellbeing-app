import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class ReflectionHistoryScreen extends StatefulWidget {
  const ReflectionHistoryScreen({super.key});

  @override
  State<ReflectionHistoryScreen> createState() =>
      _ReflectionHistoryScreenState();
}

class _ReflectionHistoryScreenState extends State<ReflectionHistoryScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> reflections = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/participant/reflection_history.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load reflections';
      });
      return;
    }

    setState(() {
      reflections =
      List<Map<String, dynamic>>.from(response['reflections'] ?? []);
      isLoading = false;
    });
  }

  int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _formatDate(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final parts = raw.split('-');
    if (parts.length != 3) return raw;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
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
            onRefresh: loadHistory,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 28),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else if (reflections.isEmpty)
                    _messageCard('No reflections have been submitted yet')
                  else
                    ...reflections.map(_reflectionCard),
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
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'Reflection\nHistory',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              height: 1.1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _reflectionCard(Map<String, dynamic> item) {
    final mood = _toInt(item['mood_level']);
    final stress = _toInt(item['stress_level']);
    final energy = _toInt(item['energy_level']);
    final sleep = _toInt(item['sleep_quality']);
    final notes = item['notes']?.toString() ?? '';
    final date = _formatDate(item['reflection_date']?.toString());

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
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
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE8F1FF),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: Color(0xFF2F61D2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  date,
                  style: const TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _scoreRow('Mood', mood, Icons.sentiment_satisfied_alt_rounded),
          _scoreRow('Stress', stress, Icons.psychology_rounded),
          _scoreRow('Energy', energy, Icons.bolt_rounded),
          _scoreRow('Sleep', sleep, Icons.nightlight_round),
          if (notes.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                notes,
                style: const TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 15,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _scoreRow(String label, int value, IconData icon) {
    final safeValue = value.clamp(0, 5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2F61D2), size: 22),
          const SizedBox(width: 10),
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF0F3D84),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: safeValue / 5,
                minHeight: 10,
                backgroundColor: const Color(0xFFE8EEF8),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF2F61D2)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '$safeValue/5',
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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