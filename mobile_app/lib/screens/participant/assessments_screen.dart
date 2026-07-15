import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import 'assessment_questions_screen.dart';

class AssessmentsScreen extends StatefulWidget {
  const AssessmentsScreen({super.key});

  @override
  State<AssessmentsScreen> createState() => _AssessmentsScreenState();
}

class _AssessmentsScreenState extends State<AssessmentsScreen> {
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> assessments = [];
  Map<String, dynamic> summary = {};

  static const Color darkBlue = Color(0xFF0F3D84);
  static const Color blue = Color(0xFF2F61D2);
  static const Color purple = Color(0xFF5A5CF6);
  static const Color softBg = Color(0xFFF4F6FA);

  @override
  void initState() {
    super.initState();
    loadAssessments();
  }

  Future<void> loadAssessments() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/participant/assessments.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load assessments';
        assessments = [];
        summary = {};
      });
      return;
    }

    final loadedAssessments = List<Map<String, dynamic>>.from(
      response['assessments'] ?? [],
    );

    final loadedSummary = Map<String, dynamic>.from(response['summary'] ?? {});

    setState(() {
      assessments = loadedAssessments;
      summary = loadedSummary;
      isLoading = false;
    });
  }

  int toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is bool) return value ? 1 : 0;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String textValue(dynamic value) {
    if (value == null) return '';
    final text = value.toString().trim();
    if (text == 'null') return '';
    return text;
  }

  bool truthy(dynamic value) {
    if (value == true) return true;
    final text = textValue(value).toLowerCase();
    return text == '1' || text == 'true' || text == 'yes' || text == 'completed';
  }

  String assessmentType(Map<String, dynamic> item) {
    final raw = textValue(
      item['assessment_type'] ?? item['type'] ?? item['id'] ?? item['title'],
    ).toLowerCase();

    if (raw.contains('sleep')) return 'sleep';
    if (raw.contains('stress')) return 'stress';
    if (raw.contains('wellness')) return 'wellness';

    return raw;
  }

  bool isCompleted(Map<String, dynamic> item) {
    final status = textValue(item['status']).toLowerCase();
    return status == 'completed' ||
        truthy(item['completed']) ||
        truthy(item['is_completed']);
  }

  bool isAvailable(Map<String, dynamic> item) {
    if (truthy(item['is_available'])) return true;
    return !isCompleted(item);
  }

  int completedCount() {
    final fromSummary = toInt(summary['completed']);
    if (fromSummary > 0 || assessments.isEmpty) return fromSummary;
    return assessments.where(isCompleted).length;
  }

  int totalCount() {
    final fromSummary = toInt(summary['total']);
    if (fromSummary > 0 || assessments.isEmpty) return fromSummary;
    return assessments.length;
  }

  int pendingCount() {
    final fromSummary = toInt(summary['pending']);
    if (fromSummary > 0 || assessments.isEmpty) return fromSummary;
    return (totalCount() - completedCount()).clamp(0, 9999);
  }

  int progressPercent() {
    final fromSummary = toInt(summary['progress_percent']);
    if (fromSummary > 0) return fromSummary.clamp(0, 100);

    final total = totalCount();
    if (total <= 0) return 0;
    return ((completedCount() / total) * 100).round().clamp(0, 100);
  }

  int daysRemainingFor(Map<String, dynamic> item) {
    final fromApi = toInt(item['days_remaining'] ?? item['days_until_next']);
    if (fromApi > 0) return fromApi;

    final next = parseDate(item['next_available_at']);
    if (next == null) return 0;

    final now = DateTime.now();
    if (!next.isAfter(now)) return 0;

    final hours = next.difference(now).inHours;
    return (hours / 24).ceil().clamp(1, 9999);
  }

  int summaryDaysRemaining() {
    final fromApi = toInt(summary['days_until_next'] ?? summary['days_remaining']);
    if (fromApi > 0) return fromApi;

    final dates = assessments
        .where(isCompleted)
        .map((item) => parseDate(item['next_available_at']))
        .whereType<DateTime>()
        .where((date) => date.isAfter(DateTime.now()))
        .toList();

    if (dates.isEmpty) return 0;

    dates.sort();
    final hours = dates.first.difference(DateTime.now()).inHours;
    return (hours / 24).ceil().clamp(1, 9999);
  }

  DateTime? parseDate(dynamic value) {
    final text = textValue(value);
    if (text.isEmpty) return null;

    final normalized = text.contains('T') ? text : text.replaceFirst(' ', 'T');
    return DateTime.tryParse(normalized);
  }

  String shortDate(dynamic value) {
    final date = parseDate(value);
    if (date == null) return textValue(value);

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  IconData iconFor(Map<String, dynamic> item) {
    final type = assessmentType(item);
    if (type == 'sleep') return Icons.nights_stay_rounded;
    if (type == 'stress') return Icons.psychology_rounded;
    return Icons.assignment_rounded;
  }

  Color iconColorFor(Map<String, dynamic> item) {
    if (isCompleted(item)) return Colors.green;
    return blue;
  }

  Color iconBgFor(Map<String, dynamic> item) {
    if (isCompleted(item)) return const Color(0xFFDDFBE8);
    return const Color(0xFFE8F1FF);
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
            onRefresh: loadAssessments,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 42),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 28),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else ...[
                    _summaryCard(),
                    const SizedBox(height: 18),
                    _countdownCard(),
                    const SizedBox(height: 24),
                    if (assessments.isEmpty)
                      _emptyCard()
                    else
                      ...assessments.map(_assessmentCard),
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
          backgroundColor: Colors.white.withOpacity(0.18),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(width: 18),
        const Expanded(
          child: Text(
            'Assessments',
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
    final completed = completedCount();
    final total = totalCount();
    final pending = pendingCount();
    final progress = progressPercent();

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assessment Summary',
            style: TextStyle(
              color: darkBlue,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  icon: Icons.check_circle_rounded,
                  value: completed,
                  label: 'Completed',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryTile(
                  icon: Icons.assignment_rounded,
                  value: total,
                  label: 'Total',
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _summaryTile(
                  icon: Icons.pending_actions_rounded,
                  value: pending,
                  label: 'Pending',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 12,
                    backgroundColor: const Color(0xFFE8F1FF),
                    valueColor: const AlwaysStoppedAnimation<Color>(blue),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                '$progress%',
                style: const TextStyle(
                  color: darkBlue,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _countdownCard() {
    final days = summaryDaysRemaining();

    if (assessments.isEmpty) {
      return const SizedBox.shrink();
    }

    if (days <= 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F1FF),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.45)),
        ),
        child: const Row(
          children: [
            Icon(Icons.lock_open_rounded, color: blue, size: 28),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'At least one assessment is available now.',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F1FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.45)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_bottom_rounded, color: blue, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              days == 1
                  ? 'Next assessment opens in 1 day.'
                  : 'Next assessment opens in $days days.',
              style: const TextStyle(
                color: darkBlue,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required int value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(icon, color: blue, size: 28),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
              color: darkBlue,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyCard() {
    return _WhiteCard(
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 58,
            color: blue,
          ),
          SizedBox(height: 16),
          Text(
            'No assessments yet',
            style: TextStyle(
              color: darkBlue,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'When assessments are assigned to your program, they will appear here.',
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

  Widget _assessmentCard(Map<String, dynamic> item) {
    final completed = isCompleted(item);
    final available = isAvailable(item);
    final daysLeft = daysRemainingFor(item);
    final title = textValue(item['title']).isEmpty
        ? 'Assessment'
        : textValue(item['title']);
    final description = textValue(item['description']);
    final score = toInt(item['score']);
    final completedAt = textValue(item['completed_at'] ?? item['result_date']);
    final nextAvailableAt = textValue(item['next_available_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(28),
        onTap: available
            ? () async {
          final refresh = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssessmentQuestionsScreen(
                assessment: item,
              ),
            ),
          );

          if (refresh == true) {
            await loadAssessments();
          }
        }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: iconBgFor(item),
                child: Icon(
                  completed ? Icons.check_circle_rounded : iconFor(item),
                  color: iconColorFor(item),
                  size: 30,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      completed ? 'COMPLETED' : 'PENDING',
                      style: TextStyle(
                        color: completed ? Colors.green : blue,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          height: 1.3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (completed || score > 0)
                          _chip(
                            icon: Icons.favorite_rounded,
                            text: 'Score $score%',
                          ),
                        if (completedAt.isNotEmpty)
                          _chip(
                            icon: Icons.check_rounded,
                            text: 'Completed ${shortDate(completedAt)}',
                          ),
                        if (completed && daysLeft > 0)
                          _chip(
                            icon: Icons.hourglass_bottom_rounded,
                            text: daysLeft == 1
                                ? 'Opens in 1 day'
                                : 'Opens in $daysLeft days',
                          ),
                        if (completed && nextAvailableAt.isNotEmpty)
                          _chip(
                            icon: Icons.event_available_rounded,
                            text: 'Next ${shortDate(nextAvailableAt)}',
                          ),
                        if (!completed)
                          _chip(
                            icon: Icons.lock_open_rounded,
                            text: 'Available now',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(
                completed ? Icons.lock_clock_rounded : Icons.chevron_right_rounded,
                color: completed ? Colors.green : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: softBg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: blue),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 12,
              fontWeight: FontWeight.w700,
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
          color: darkBlue,
          fontSize: 18,
          fontWeight: FontWeight.bold,
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
