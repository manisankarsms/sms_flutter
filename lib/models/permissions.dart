class PermissionDefinition {
  final int id;
  final String key;
  final String description;

  PermissionDefinition({
    required this.id,
    required this.key,
    required this.description,
  });

  factory PermissionDefinition.fromJson(Map<String, dynamic> json) {
    return PermissionDefinition(
      id: json['id'],
      key: json['key'],
      description: json['description'] ?? json['key'],
    );
  }
}

class Staff {
  final String id;
  final String name;
  List<String> permissions;

  Staff({
    required this.id,
    required this.name,
    required this.permissions,
  });

  factory Staff.fromJson(Map<String, dynamic> json, List<String> allKeys) {
    final perms = List<String>.from(json['permissions'] ?? []);
    // If no permissions set, default to all
    final defaultPerms = perms.isEmpty ? allKeys : perms;
    return Staff(
      id: json['id'],
      name: json['name'],
      permissions: defaultPerms,
    );
  }
}