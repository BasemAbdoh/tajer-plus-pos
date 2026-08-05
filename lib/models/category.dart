class Category {
  final int? id;
  final String name;
  final String? icon;
  final DateTime createdAt;

  Category({
    this.id,
    required this.name,
    this.icon,
    required this.createdAt,
  });

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      icon: map['icon'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
