class Program {
  final int id;
  final String title;
  final String shortTitle;
  final String description;
  final int durationWeeks;
  final int? maxParticipants;
  final String status;

  Program({
    required this.id,
    required this.title,
    required this.shortTitle,
    required this.description,
    required this.durationWeeks,
    this.maxParticipants,
    required this.status,
  });

  factory Program.fromJson(Map<String, dynamic> json) {
    return Program(
      id: int.tryParse((json['id'] ?? json['program_id']).toString()) ?? 0,
      title: json['title']?.toString() ?? '',
      shortTitle: json['short_title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      durationWeeks: int.tryParse(json['duration_weeks'].toString()) ?? 0,
      maxParticipants: json['max_participants'] == null
          ? null
          : int.tryParse(json['max_participants'].toString()),
      status: json['status']?.toString() ?? 'active',
    );
  }
}