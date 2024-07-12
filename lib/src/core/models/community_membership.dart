class CommunityMembership {
  const CommunityMembership({
    required this.$id,
    required this.userId,
    required this.createdAt,
  });

  final String $id;
  final String userId;
  final DateTime createdAt;

  factory CommunityMembership.fromMap(Map<String, dynamic> map) {
    return CommunityMembership(
      $id: map['\$id'],
      userId: map['userId'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': $id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
