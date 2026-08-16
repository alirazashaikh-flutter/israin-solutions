class User {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final bool twoFactorEnabled;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.twoFactorEnabled = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'customer',
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'twoFactorEnabled': twoFactorEnabled,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
