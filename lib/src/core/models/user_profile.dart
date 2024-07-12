class UserProfile {
  const UserProfile({
    required this.$id,
    required this.userId,
    required this.name,
  });

  final String $id;
  final String userId;
  final String name;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      $id: map['\$id'],
      userId: map['userId'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': $id,
      'userId': userId,
      'name': name,
    };
  }
}
