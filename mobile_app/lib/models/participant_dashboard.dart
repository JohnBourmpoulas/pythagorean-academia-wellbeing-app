class ParticipantDashboard {
  final int participantProfileId;
  final int userId;
  final int programId;

  final String fullName;
  final String email;
  final String phone;
  final String? profilePhoto;

  final String programName;
  final String programDescription;

  final int currentWeek;
  final int totalWeeks;
  final int completionPercent;
  final int wellnessScore;
  final int dailyGoalPercent;

  final int todaySteps;
  final double sleepHours;
  final int heartRate;

  final int todayTasksCount;
  final int completedTasksCount;

  final List<int> weeklyProgress;

  final String? storageFolder;
  final String? joinedAt;
  final String? startDate;

  ParticipantDashboard({
    required this.participantProfileId,
    required this.userId,
    required this.programId,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.profilePhoto,
    required this.programName,
    required this.programDescription,
    required this.currentWeek,
    required this.totalWeeks,
    required this.completionPercent,
    required this.wellnessScore,
    required this.dailyGoalPercent,
    required this.todaySteps,
    required this.sleepHours,
    required this.heartRate,
    required this.todayTasksCount,
    required this.completedTasksCount,
    required this.weeklyProgress,
    required this.storageFolder,
    required this.joinedAt,
    required this.startDate,
  });

  factory ParticipantDashboard.fromJson(Map<String, dynamic> json) {
    return ParticipantDashboard(
      participantProfileId: _toInt(json['participant_profile_id']),
      userId: _toInt(json['user_id']),
      programId: _toInt(json['program_id']),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      profilePhoto: json['profile_photo']?.toString(),
      programName: json['program_name']?.toString() ?? '',
      programDescription: json['program_description']?.toString() ?? '',
      currentWeek: _toInt(json['current_week']),
      totalWeeks: _toInt(json['total_weeks']),
      completionPercent: _toInt(json['completion_percent']),
      wellnessScore: _toInt(json['wellness_score']),
      dailyGoalPercent: _toInt(json['daily_goal_percent']),
      todaySteps: _toInt(json['today_steps']),
      sleepHours: _toDouble(json['sleep_hours']),
      heartRate: _toInt(json['heart_rate']),
      todayTasksCount: _toInt(json['today_tasks_count']),
      completedTasksCount: _toInt(json['completed_tasks_count']),
      weeklyProgress: (json['weekly_progress'] as List?)
          ?.map((e) => _toInt(e))
          .toList() ??
          [],
      storageFolder: json['storage_folder']?.toString(),
      joinedAt: json['joined_at']?.toString(),
      startDate: json['start_date']?.toString(),
    );
  }

  static int _toInt(dynamic value) {
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }
}