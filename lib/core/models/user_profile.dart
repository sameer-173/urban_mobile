class UserProfile {
  final String id;
  final String username;
  final String name;
  final String role;
  final List<String> roles;
  final String tenantId;
  final List<String> assignedModules;

  UserProfile({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    required this.roles,
    required this.tenantId,
    required this.assignedModules,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      name: json['name'] ?? json['username'] ?? '',
      role: json['role'] ?? 'Officer',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tenantId: json['tenantId'] ?? 'GWMC',
      assignedModules: (json['assignedModules'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
