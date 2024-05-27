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
        title: Row(
          children: [
            CircleAvatar(
              child: Icon(community.icon),
            ),
            const SizedBox(width: 10),
            // display the name and description of the community
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(community.name),
                Text(
                  community.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  )
                ),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: Text(community.description),
      ),
    );
  }
}
