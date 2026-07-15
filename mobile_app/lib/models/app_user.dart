class AppUser {
  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: int.parse(json['id'].toString()),
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: json['role']?.toString() ?? 'interested',
    );
  }
}