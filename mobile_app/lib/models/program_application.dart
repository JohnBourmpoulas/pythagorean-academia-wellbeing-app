class ProgramApplication {
  final int applicationId;
  final int userId;
  final int programId;
  final String fullName;
  final String email;
  final String? phone;
  final String title;
  final String shortTitle;
  final String status;
  final int? age;
  final String? profession;
  final String? goals;

  ProgramApplication({
    required this.applicationId,
    required this.userId,
    required this.programId,
    required this.fullName,
    required this.email,
    this.phone,
    required this.title,
    required this.shortTitle,
    required this.status,
    this.age,
    this.profession,
    this.goals,
  });

  factory ProgramApplication.fromJson(Map<String, dynamic> json) {
    return ProgramApplication(
      applicationId:
      int.tryParse((json['application_id'] ?? json['id']).toString()) ?? 0,
      userId: int.tryParse(json['user_id'].toString()) ?? 0,
      programId: int.tryParse(json['program_id'].toString()) ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      title: json['title']?.toString() ?? '',
      shortTitle: json['short_title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      age: json['age'] == null ? null : int.tryParse(json['age'].toString()),
      profession: json['profession']?.toString(),
      goals: json['goals']?.toString(),
    );
  }
}