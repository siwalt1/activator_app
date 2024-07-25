class Community{
  const Community({
    required this.$id,
    required this.name,
    required this.description,
    required this.iconCode,
    required this.type,
    required this.createdAt,
    required this.activityAttendanceCollectionId,
    required this.activityCollectionId,
    required this.communityMembershipCollectionId,
    required this.invitationToken,
  });

  final String $id;
  final String name;
  final String description;
  final int iconCode;
  final String type;
  final DateTime createdAt;
  final String activityAttendanceCollectionId;
  final String activityCollectionId;
  final String communityMembershipCollectionId;
  final String invitationToken;

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      $id: map['\$id'],
      name: map['name'],
      description: map['description'],
      iconCode: map['iconCode'],
      type: map['type'],
      createdAt: DateTime.parse(map['createdAt']),
      activityAttendanceCollectionId: map['activityAttendanceCollectionId'],
      activityCollectionId: map['activityCollectionId'],
      communityMembershipCollectionId: map['communityMembershipCollectionId'],
      invitationToken: map['invitationToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': $id,
      'name': name,
      'description': description,
      'iconCode': iconCode,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
      'activityAttendanceCollectionId': activityAttendanceCollectionId,
      'activityCollectionId': activityCollectionId,
      'communityMembershipCollectionId': communityMembershipCollectionId,
      'invitationToken': invitationToken,
    };
  }
}