import 'package:flutter/material.dart';

import '../../config/api_config.dart';
import '../../models/participant_dashboard.dart';
import '../../repositories/participant_repository.dart';
import '../../services/api_service.dart';
import '../auth/login_screen.dart';
import 'assessments_screen.dart';
import 'calendar_screen.dart';
import 'daily_plan_screen.dart';
import 'daily_reflection_screen.dart';
import 'documents_screen.dart';
import 'messages_screen.dart';
import 'participant_profile_screen.dart';
import 'participant_settings_screen.dart';
import 'progress_screen.dart';
import 'reflection_history_screen.dart';
import 'statistics_screen.dart';
import 'wearables_screen.dart';
import 'wellness_library_screen.dart';

class ParticipantHomeScreen extends StatefulWidget {
  const ParticipantHomeScreen({super.key});

  @override
  State<ParticipantHomeScreen> createState() => _ParticipantHomeScreenState();
}

class _ParticipantHomeScreenState extends State<ParticipantHomeScreen> {
  int selectedIndex = 0;
  int unreadMessages = 0;

  @override
  void initState() {
    super.initState();
    loadUnreadMessages();
  }

  List<Widget> get pages => [
    const ParticipantDashboardScreen(),
    const DailyPlanScreen(),
    const WellnessLibraryScreen(),
    const ProgressScreen(),
    ParticipantMoreScreen(
      unreadMessages: unreadMessages,
      onMessagesClosed: loadUnreadMessages,
    ),
  ];

  Future<void> loadUnreadMessages() async {
    final response = await ApiService.get(
      '/participant/messages/unread_count.php',
      auth: true,
    );

    if (!mounted) return;

    if (response['success'] == true) {
      setState(() {
        unreadMessages =
            int.tryParse(response['unread_count']?.toString() ?? '0') ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF4057E8),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() => selectedIndex = index);
            if (index == 4) {
              loadUnreadMessages();
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_rounded),
              label: 'Plan',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              label: 'Library',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.trending_up_rounded),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: _NavBadgeIcon(
                icon: Icons.more_horiz_rounded,
                badge: unreadMessages,
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}

class ParticipantDashboardScreen extends StatefulWidget {
  const ParticipantDashboardScreen({super.key});

  @override
  State<ParticipantDashboardScreen> createState() =>
      _ParticipantDashboardScreenState();
}

class _ParticipantDashboardScreenState
    extends State<ParticipantDashboardScreen> {
  final ParticipantRepository repository = ParticipantRepository();

  ParticipantDashboard? dashboard;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final data = await repository.getDashboard();

    if (!mounted) return;

    setState(() {
      dashboard = data;
      isLoading = false;
      errorMessage =
      data == null ? 'Could not load participant dashboard' : null;
    });
  }

  Future<void> logout() async {
    await ApiService.clearToken();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  String get firstName {
    final name = dashboard?.fullName.trim() ?? '';
    if (name.isEmpty) return '';
    return name.split(' ').first;
  }

  String? get profilePhotoUrl {
    final photo = dashboard?.profilePhoto;
    if (photo == null || photo.trim().isEmpty) return null;

    final serverUrl = ApiConfig.baseUrl.replaceFirst(RegExp(r'/api/?$'), '');
    return '$serverUrl/$photo';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ParticipantGradient(
        child: SafeArea(
          child: isLoading
              ? const Center(
            child: CircularProgressIndicator(color: Colors.white),
          )
              : errorMessage != null
              ? _errorState()
              : RefreshIndicator(
            onRefresh: loadDashboard,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(28, 24, 28, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header(),
                  const SizedBox(height: 30),
                  _currentProgramCard(),
                  const SizedBox(height: 24),
                  _todayActivityCard(),
                  const SizedBox(height: 24),
                  _weeklyProgressCard(),
                  const SizedBox(height: 24),
                  _quickActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: _WhiteCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 54,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Something went wrong',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF17213A),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: loadDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F61D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Row(
      children: [
        if (profilePhotoUrl != null) ...[
          CircleAvatar(
            radius: 28,
            backgroundImage: NetworkImage(profilePhotoUrl!),
            backgroundColor: Colors.white.withOpacity(0.2),
          ),
          const SizedBox(width: 14),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome back,',
                style: TextStyle(color: Colors.white70, fontSize: 20),
              ),
              const SizedBox(height: 4),
              Text(
                firstName,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: logout,
          style: TextButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.18),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: const Text(
            'Logout',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _currentProgramCard() {
    return _WhiteCard(
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Program',
                  style: TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dashboard!.programName,
                  style: const TextStyle(
                    color: Color(0xFF0F3D84),
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Week ${dashboard!.currentWeek} of ${dashboard!.totalWeeks}',
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          _CircularProgress(percent: dashboard!.completionPercent),
        ],
      ),
    );
  }

  Widget _todayActivityCard() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Today\'s Progress',
            style: TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _MetricItem(
                  icon: Icons.task_alt_rounded,
                  iconColor: Color(0xFF2F61D2),
                  value: dashboard!.completedTasksCount.toString(),
                  label: 'Done',
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.format_list_numbered_rounded,
                  iconColor: Color(0xFFB14CFF),
                  value: dashboard!.todayTasksCount.toString(),
                  label: 'Tasks',
                ),
              ),
              Expanded(
                child: _MetricItem(
                  icon: Icons.star_rounded,
                  iconColor: Color(0xFFFFA000),
                  value: _formatSteps(dashboard!.todaySteps),
                  label: 'Points',
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Daily Goal',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${dashboard!.dailyGoalPercent}%',
                style: const TextStyle(
                  color: Color(0xFF2F61D2),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: dashboard!.dailyGoalPercent.clamp(0, 100) / 100,
              minHeight: 12,
              backgroundColor: const Color(0xFFE8EEF8),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2F61D2)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _weeklyProgressCard() {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final raw = dashboard!.weeklyProgress;
    final values = raw.length >= 7
        ? raw.take(7).toList()
        : [...raw, ...List.filled(7 - raw.length, 0)];

    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Color(0xFF0F3D84)),
              SizedBox(width: 10),
              Text(
                'Weekly Progress',
                style: TextStyle(
                  color: Color(0xFF0F3D84),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final value = values[index].clamp(0, 100);
                final barHeight = 30 + (value * 0.78);

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: barHeight.toDouble(),
                          width: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCEBFF),
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          days[index],
                          maxLines: 1,
                          style: const TextStyle(
                            color: Color(0xFF6B7280),
                            fontSize: 11,
                            height: 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return _WhiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Access',
            style: TextStyle(
              color: Color(0xFF0F3D84),
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          _ActionRow(
            icon: Icons.calendar_month_rounded,
            title: 'Today\'s Plan',
            subtitle:
            '${dashboard!.completedTasksCount} of ${dashboard!.todayTasksCount} activities completed',
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyPlanScreen()),
              );
              loadDashboard();
            },
          ),
          _ActionRow(
            icon: Icons.edit_note_rounded,
            title: 'Daily Reflection',
            subtitle: 'Log how you feel today',
            onTap: () async {
              final refresh = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DailyReflectionScreen()),
              );

              if (refresh == true) {
                loadDashboard();
              }
            },
          ),
          _ActionRow(
            icon: Icons.history_rounded,
            title: 'Reflection History',
            subtitle: 'View your previous reflections',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReflectionHistoryScreen(),
                ),
              );
            },
          ),
          _ActionRow(
            icon: Icons.assignment_rounded,
            title: 'Assessments',
            subtitle: 'Complete program questionnaires',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AssessmentsScreen()),
              );
            },
          ),
          _ActionRow(
            icon: Icons.calendar_today_rounded,
            title: 'Calendar',
            subtitle: 'View all scheduled activities',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarScreen()),
              );
            },
          ),
          _ActionRow(
            icon: Icons.bar_chart_rounded,
            title: 'Statistics',
            subtitle: 'View detailed program statistics',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatisticsScreen()),
              );
            },
          ),
          _ActionRow(
            icon: Icons.menu_book_rounded,
            title: 'Wellness Library',
            subtitle: 'Articles, videos and audio guides',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WellnessLibraryScreen()),
              );
            },
          ),
          _ActionRow(
            icon: Icons.trending_up_rounded,
            title: 'Progress',
            subtitle: 'View your program progress',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProgressScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps <= 0) return '-';
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}K';
    return steps.toString();
  }
}

class ParticipantMoreScreen extends StatelessWidget {
  final int unreadMessages;
  final Future<void> Function()? onMessagesClosed;

  const ParticipantMoreScreen({
    super.key,
    this.unreadMessages = 0,
    this.onMessagesClosed,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _ParticipantGradient(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'More',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 28),
                _WhiteCard(
                  child: Column(
                    children: [
                      _ActionRow(
                        icon: Icons.assignment_rounded,
                        title: 'Assessments',
                        subtitle: 'Complete program questionnaires',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AssessmentsScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionRow(
                        icon: Icons.calendar_today_rounded,
                        title: 'Calendar',
                        subtitle: 'View all scheduled activities',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const CalendarScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionRow(
                        icon: Icons.bar_chart_rounded,
                        title: 'Statistics',
                        subtitle: 'View detailed program statistics',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StatisticsScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionRow(
                        icon: Icons.favorite_rounded,
                        title: 'Wearables',
                        subtitle: 'Sync health and wearable data',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const WearablesScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionRow(
                        icon: Icons.mail_rounded,
                        title: 'Messages',
                        subtitle: unreadMessages == 0
                            ? 'View messages from admins/coaches'
                            : '$unreadMessages unread message${unreadMessages == 1 ? '' : 's'}',
                        badge: unreadMessages,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MessagesScreen(),
                            ),
                          );

                          await onMessagesClosed?.call();
                        },
                      ),
                      _ActionRow(
                        icon: Icons.description_rounded,
                        title: 'Documents',
                        subtitle: 'Generate and view your personal PDF reports',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DocumentsScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionRow(
                        icon: Icons.person_rounded,
                        title: 'My Profile',
                        subtitle: 'View your participant profile',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ParticipantProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _ActionRow(
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        subtitle: 'Account and preferences',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ParticipantSettingsScreen(),
                            ),
                          );
                        },
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
}

class _ParticipantGradient extends StatelessWidget {
  final Widget child;

  const _ParticipantGradient({required this.child});

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
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CircularProgress extends StatelessWidget {
  final int percent;

  const _CircularProgress({required this.percent});

  @override
  Widget build(BuildContext context) {
    final safePercent = percent.clamp(0, 100);

    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 84,
            height: 84,
            child: CircularProgressIndicator(
              value: safePercent / 100,
              strokeWidth: 9,
              strokeCap: StrokeCap.round,
              backgroundColor: const Color(0xFFE8EEF8),
              valueColor: const AlwaysStoppedAnimation(Color(0xFF5A5CF6)),
            ),
          ),
          Container(
            width: 58,
            height: 58,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$safePercent%',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF0F3D84),
                  fontSize: 18,
                  height: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _MetricItem({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final displayValue = value.trim().isEmpty || value == '0' ? '-' : value;

    return Column(
      children: [
        Icon(icon, color: iconColor, size: 34),
        const SizedBox(height: 12),
        Text(
          displayValue,
          style: const TextStyle(
            color: Color(0xFF0F3D84),
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final int badge;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFE8F1FF),
        child: Icon(icon, color: const Color(0xFF2F61D2)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF0F3D84),
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge > 99 ? '99+' : badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          if (badge > 0) const SizedBox(width: 10),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _NavBadgeIcon extends StatelessWidget {
  final IconData icon;
  final int badge;

  const _NavBadgeIcon({
    required this.icon,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (badge > 0)
          Positioned(
            right: -8,
            top: -7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                badge > 99 ? '99+' : badge.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}