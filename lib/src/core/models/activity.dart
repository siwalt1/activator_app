import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/enum_converter.dart';

class Activity {
  const Activity({
    required this.id,
    required this.communityId,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  final String id;
  final String communityId;
  final DateTime startDate;
  final DateTime endDate;
  final ActivityType type;

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map['id'],
      communityId: map['community_id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: DateTime.parse(map['end_date']),
      type: EnumConverter.enumFromString(map['type'], ActivityType.values)
          as ActivityType,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'community_id': communityId,
      'start_date': startDate,
      'end_date': endDate,
      'type': EnumConverter.enumToString(type),
    };
  }
}
