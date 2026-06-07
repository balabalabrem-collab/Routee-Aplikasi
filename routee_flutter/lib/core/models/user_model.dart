class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String avatarUrl;
  final String role; // 'admin', 'karyawan', 'user'
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl = '',
    this.role = 'user',
    required this.createdAt,
  });
}
