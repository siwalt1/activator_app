import 'package:flutter/material.dart';

class Community {
  const Community({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    this.sessions = const [],
  });

  final int id;
  final String name;
  final IconData icon;
  final String description;
  final List<CommunitySession>? sessions;
}

class CommunitySession {
  const CommunitySession({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.community,
    required this.attendees,
  });

  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final int community;
  final List<String> attendees;
}
