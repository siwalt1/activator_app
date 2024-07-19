class ActivityAttendance {
  const ActivityAttendance({
    required this.$id,
    required this.activityId,
    required this.userId,
    required this.joinOrder,
    this.active = true,
  });

  final String $id;
  final String activityId;
  final String userId;
  final int joinOrder;
  final bool active;

  factory ActivityAttendance.fromMap(Map<String, dynamic> map) {
    return ActivityAttendance(
      $id: map['\$id'],
      activityId: map['activityId'],
      userId: map['userId'],
      joinOrder: map['joinOrder'],
      active: map['active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': $id,
      'activityId': activityId,
      'userId': userId,
      'joinOrder': joinOrder,
      'active': active,
    };
  }
}