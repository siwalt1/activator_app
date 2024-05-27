import 'package:flutter/material.dart';

/// A placeholder class that represents an entity or model.
class Community {
  const Community({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  final int id;
  final String name;
  final IconData icon;
  final String description;
}
