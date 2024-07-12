class Activity {
  const Activity({
    required this.$id,
    required this.startDate,
    required this.endDate,
    required this.type,
  });

  final String $id;
  final DateTime startDate;
  final DateTime endDate;
  final String type;

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      $id: map['\$id'],
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '\$id': $id,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'type': type,
    };
  }
}
