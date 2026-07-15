import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import 'participant_edit_profile_screen.dart';

class ParticipantProfileScreen extends StatefulWidget {
  const ParticipantProfileScreen({super.key});

  @override
  State<ParticipantProfileScreen> createState() =>
      _ParticipantProfileScreenState();
}

class _ParticipantProfileScreenState extends State<ParticipantProfileScreen> {
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? profile;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final response = await ApiService.get(
      '/participant/profile.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] != true) {
      setState(() {
        isLoading = false;
        errorMessage =
            response['message']?.toString() ?? 'Could not load profile';
      });
      return;
    }

    setState(() {
      profile = Map<String, dynamic>.from(response['profile'] ?? {});
      isLoading = false;
    });
  }

  String value(String key) {
    final v = profile?[key];
    if (v == null) return 'Not provided';

    final text = v.toString().trim();
    if (text.isEmpty || text == 'null') return 'Not provided';

    return text;
  }

  String percentValue(String key) {
    final raw = value(key);
    if (raw == 'Not provided') return raw;
    if (raw.endsWith('%')) return raw;
    return '$raw%';
  }

  String? get photoUrl {
    final photo = profile?['profile_photo']?.toString();
    if (photo == null || photo.trim().isEmpty) return null;

    final serverUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return '$serverUrl/$photo';
  }

  String goalsText() {
    final raw = profile?['goals'];
    if (raw == null) return 'Not provided';

    final text = raw.toString().trim();
    if (text.isEmpty || text == 'null') return 'Not provided';

    return text
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll('"', '')
        .replaceAll(',', ', ');
  }

  String formattedStatus() {
    final status = value('status');
    if (status == 'Not provided') return status;

    switch (status.toLowerCase()) {
      case 'active':
        return '🟢 Active';
      case 'completed':
        return '✅ Completed';
      case 'paused':
        return '🟡 Paused';
      case 'removed':
        return '🔴 Removed';
      default:
        return status;
    }
  }

  String formattedDate(String key) {
    final raw = value(key);
    if (raw == 'Not provided') return raw;

    if (raw.length >= 10) {
      return raw.substring(0, 10);
    }

    return raw;
  }

  String _withUnit(String text, String unit) {
    if (text == 'Not provided') return text;
    return '$text $unit';
  }

  Future<void> openEditScreen(Widget screen) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (mounted && changed == true) {
      loadProfile();
    } else if (mounted) {
      loadProfile();
    }
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
            onRefresh: loadProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _topBar(context),
                  const SizedBox(height: 28),
                  if (errorMessage != null)
                    _messageCard(errorMessage!)
                  else
                    _profileCard(),
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
            'My Profile',
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

  Widget _profileCard() {
    return _WhiteCard(
      child: Column(
        children: [
          CircleAvatar(
            radius: 58,
            backgroundColor: const Color(0xFFE8F1FF),
            backgroundImage: photoUrl == null ? null : NetworkImage(photoUrl!),
            child: photoUrl == null
                ? const Icon(
              Icons.person,
              size: 62,
              color: Color(0xFF2F61D2),
            )
                : null,
          ),
          const SizedBox(height: 18),
          Text(
            value('full_name'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value('email'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 24),
          _editButtons(),

          _sectionTitle('Personal Information'),
          _info('Phone', value('phone')),
          _info('Age', value('age')),
          _info('Profession', value('profession')),

          _sectionTitle('Biometrics'),
          _info('Height', _withUnit(value('height_cm'), 'cm')),
          _info('Weight', _withUnit(value('weight_kg'), 'kg')),
          _info('BMI', value('bmi')),
          _info('Neck Circumference', _withUnit(value('neck_cm'), 'cm')),
          _info('Waist Circumference', _withUnit(value('waist_cm'), 'cm')),

          _sectionTitle('Lifestyle'),
          _info('Nutrition Habits', value('nutrition_habits')),
          _info('Smoking Habits', value('smoking_habits')),
          _info('Physical Activity', value('physical_activity')),
          _info('Sleep Quality', value('sleep_quality')),

          _sectionTitle('Goals'),
          _info('Declared Goals', goalsText()),

          _sectionTitle('Current Program'),
          _info('Program', value('program_title')),
          _info(
            'Week',
            '${value('current_week')} of ${value('total_weeks')}',
          ),
          _info('Progress', percentValue('progress_percent')),
          _info('Wellness Score', value('wellness_score')),

          _sectionTitle('Participant Account'),
          _info('Status', formattedStatus()),
          _info('Start Date', formattedDate('start_date')),
          _info('Joined At', formattedDate('joined_at')),
        ],
      ),
    );
  }

  Widget _editButtons() {
    final currentProfile = profile ?? {};

    return Column(
      children: [
        _editButton(
          icon: Icons.person_rounded,
          title: 'Edit Personal Information',
          screen: EditPersonalInfoScreen(initialData: currentProfile),
        ),
        _editButton(
          icon: Icons.straighten_rounded,
          title: 'Edit Biometrics',
          screen: EditBiometricsScreen(initialData: currentProfile),
        ),
        _editButton(
          icon: Icons.restaurant_rounded,
          title: 'Edit Lifestyle',
          screen: EditLifestyleScreen(initialData: currentProfile),
        ),
        _editButton(
          icon: Icons.flag_rounded,
          title: 'Edit Goals',
          screen: EditGoalsScreen(initialData: currentProfile),
        ),
      ],
    );
  }

  Widget _editButton({
    required IconData icon,
    required String title,
    required Widget screen,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        tileColor: const Color(0xFFE8F1FF),
        leading: Icon(icon, color: const Color(0xFF2F61D2)),
        title: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F3D84),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => openEditScreen(screen),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 12),
        child: Text(
          title,
          style: const TextStyle(
            color: Color(0xFF0F3D84),
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _info(String label, String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF17213A),
              fontSize: 17,
              height: 1.3,
              fontWeight: FontWeight.w600,
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