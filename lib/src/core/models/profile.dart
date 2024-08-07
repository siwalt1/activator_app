class Profile {
  const Profile({
    required this.id,
    required this.updatedAt,
    required this.name,
  });

  final String id;
  final String updatedAt;
  final String name;

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'],
      updatedAt: map['updated_at'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'updated_at': updatedAt,
      'name': name,
    };
  }
}
