class ActivityAttendance {
  const ActivityAttendance({
    required this.$id,
    required this.activityId,
    required this.userId,
    required this.joinOrder,
  });

  final String $id;
  final String activityId;
  final String userId;
  final int joinOrder;

  factory ActivityAttendance.fromMap(Map<String, dynamic> map) {
    return ActivityAttendance(
      $id: map['\$id'],
      activityId: map['activityId'],
      userId: map['userId'],
      joinOrder: map['joinOrder'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': $id,
      'activityId': activityId,
      'userId': userId,
      'joinOrder': joinOrder,
    };
  }
}