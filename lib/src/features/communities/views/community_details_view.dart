import 'package:activator_app/src/features/communities/models/community.dart';
import 'package:flutter/material.dart';

/// Displays detailed information about a Community.
class CommunityDetailsView extends StatelessWidget {
  const CommunityDetailsView({
    super.key,
    required this.community,
  });

  static const routeName = '/sample_item';

  final Community community;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(community.name),
      ),
      body: Center(
        child: Text('This is the ${community.name} community.'),
      ),
    );
  }
}
