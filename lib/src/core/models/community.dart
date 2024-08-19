import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/enum_converter.dart';

class Community {
  Community({
    required this.id,
    required this.name,
    this.description,
    required this.iconCode,
    required this.type,
    required this.invitationToken,
    required this.createdAt,
    required this.updatedAt,
    required this.activityDuration,
    required this.notificationType,
    this.createdBy,
    this.membersCount,
  });

  final String id;
  final String name;
  final String? description;
  final int iconCode;
  final ActivityType type;
  String invitationToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int activityDuration;
  final NotificationType notificationType;
  final String? createdBy;
  final int? membersCount;

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      iconCode: map['icon_code'],
      type: EnumConverter.enumFromString(map['type'], ActivityType.values)
          as ActivityType,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      createdBy: map['created_by'],
      invitationToken: map['invitation_token'],
      activityDuration: map['activity_duration'],
      notificationType: EnumConverter.enumFromString(
              map['notification_type'], NotificationType.values)
          as NotificationType,
      membersCount: map['members_count'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_code': iconCode,
      'type': EnumConverter.enumToString(type),
      'invitation_token': invitationToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'activity_duration': activityDuration,
      'notification_type': EnumConverter.enumToString(notificationType),
    };
  }

  set newInvitationToken(String value) {
    invitationToken = value;
  }
}
