class Community {
  const Community({
    required this.id,
    required this.name,
    this.description,
    required this.iconCode,
    required this.type,
    required this.invitationToken,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.membersCount,
  });

  final String id;
  final String name;
  final String? description;
  final int iconCode;
  final String type;
  final String invitationToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final int? membersCount;

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconCode: map['icon_code'],
      type: map['type'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      createdBy: map['created_by'],
      invitationToken: map['invitation_token'],
      membersCount: map['members_count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code': iconCode,
      'type': type,
      'invitation_token': invitationToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
    };
  }
}
