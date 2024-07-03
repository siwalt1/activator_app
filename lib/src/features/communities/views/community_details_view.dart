import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays detailed information about a Community.
class CommunityDetailsView extends StatelessWidget {
  const CommunityDetailsView({
    super.key,
    required this.communityId,
  });

  static const routeName = '/sample_item';

  final String communityId;

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: true);
    final Community community = dbProvider.communities.firstWhere(
      (comm) => comm.id == communityId,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              child: Icon(
                  IconData(community.iconCode, fontFamily: 'MaterialIcons')),
            ),
            const SizedBox(width: 10),
            // display the name and description of the community
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(community.name),
                Text(community.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
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
