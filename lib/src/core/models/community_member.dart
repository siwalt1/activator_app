class CommunityMember {
  const CommunityMember({
    required this.userId,
    required this.communityId,
    required this.createdAt,
  });

  final String userId;
  final String communityId;
  final DateTime createdAt;

  factory CommunityMember.fromMap(Map<String, dynamic> map) {
    return CommunityMember(
      userId: map['user_id'],
      communityId: map['community_id'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'community_id': communityId,
      'created_at': createdAt,
    };
  }
}
