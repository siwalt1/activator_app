class ActivityAttendance {
  const ActivityAttendance({
    required this.activityId,
    required this.userId,
    required this.createdAt,
    this.isActive = true,
  });

  final String activityId;
  final String userId;
  final DateTime createdAt;
  final bool isActive;

  factory ActivityAttendance.fromMap(Map<String, dynamic> map) {
    return ActivityAttendance(
      activityId: map['activity_id'],
      userId: map['user_id'],
      createdAt: DateTime.parse(map['created_at']),
      isActive: map['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'activity_id': activityId,
      'user_id': userId,
      'created_at': createdAt,
      'is_active': isActive,
    };
  }
}
