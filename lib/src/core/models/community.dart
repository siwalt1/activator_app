class Community {
  const Community({
    required this.id,
    required this.name,
    required this.iconCode,
    required this.description,
    required this.type,
  });

  final String id;
  final String name;
  final int iconCode;
  final String description;
  final String type;

  factory Community.fromMap(Map<String, dynamic> map) {
    return Community(
      id: map['\$id'],
      name: map['name'],
      iconCode: map['iconCode'],
      description: map['description'],
      type: map['type'],
    );
  }
}

class CommunitySession {
  const CommunitySession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.community,
    required this.attendees,
  });

  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int community;
  final List<String> attendees;
}
