import 'package:flutter/material.dart';

import '../../services/api_service.dart';

class AssessmentQuestionsScreen extends StatefulWidget {
  final Map<String, dynamic> assessment;

  const AssessmentQuestionsScreen({
    super.key,
    required this.assessment,
  });

  @override
  State<AssessmentQuestionsScreen> createState() =>
      _AssessmentQuestionsScreenState();
}

class _AssessmentQuestionsScreenState extends State<AssessmentQuestionsScreen> {
  bool isSubmitting = false;

  final List<String> questions = const [
    'How would you rate your overall wellbeing today?',
    'How manageable was your stress level recently?',
    'How satisfied are you with your sleep quality?',
    'How motivated do you feel to continue the program?',
    'How balanced do you feel physically and mentally?',
  ];

  late List<int> answers;

  @override
  void initState() {
    super.initState();
    answers = List<int>.filled(questions.length, 3);
  }

  int get assessmentId =>
      int.tryParse(widget.assessment['id']?.toString() ?? '') ?? 0;

  String get title => widget.assessment['title']?.toString() ?? 'Assessment';

  String get assessmentType {
    final raw = (widget.assessment['assessment_type'] ??
        widget.assessment['type'] ??
        widget.assessment['id'] ??
        widget.assessment['title'] ??
        'wellness')
        .toString()
        .toLowerCase()
        .trim();

    if (raw.contains('sleep')) return 'sleep';
    if (raw.contains('stress')) return 'stress';
    if (raw.contains('wellness')) return 'wellness';

    return 'wellness';
  }

  Future<void> submitAssessment() async {
    setState(() => isSubmitting = true);

    final response = await ApiService.post(
      '/participant/submit_assessment.php',
      {
        'assessment_id': assessmentId,
        'assessment_type': assessmentType,
        'type': assessmentType,
        'answers': List.generate(
          questions.length,
              (i) => {
            'question_text': questions[i],
            'answer_value': answers[i].toString(),
          },
        ),
      },
      auth: true,
    );

    if (!mounted) return;

    setState(() => isSubmitting = false);

    if (response['success'] != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            response['message']?.toString() ?? 'Could not submit assessment',
          ),
        ),
      );
      return;
    }

    Navigator.pop(context, true);
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
                _summaryCard(),
                const SizedBox(height: 24),
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
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F1FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  assessmentType == 'sleep'
                      ? Icons.nights_stay_rounded
                      : assessmentType == 'stress'
                      ? Icons.psychology_rounded
                      : Icons.assignment_rounded,
                  color: const Color(0xFF2F61D2),
                  size: 32,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF0F3D84),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${questions.length} questions',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Complete this questionnaire to update your wellness score.',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 17,
              height: 1.35,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _card() {
    return _WhiteCard(
      child: Column(
        children: [
          ...List.generate(questions.length, _questionItem),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isSubmitting ? null : submitAssessment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F61D2),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(isSubmitting ? 'Please wait...' : 'Submit Assessment'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _questionItem(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F6FA),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFFE8F1FF),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Color(0xFF2F61D2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    questions[index],
                    style: const TextStyle(
                      color: Color(0xFF0F3D84),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  answers[index].toString(),
                  style: const TextStyle(
                    color: Color(0xFF2F61D2),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Slider(
              value: answers[index].toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              label: answers[index].toString(),
              activeColor: const Color(0xFF2F61D2),
              inactiveColor: const Color(0xFFDDE6F5),
              onChanged: (v) => setState(() => answers[index] = v.round()),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Low',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'High',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
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
