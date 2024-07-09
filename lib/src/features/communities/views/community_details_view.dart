import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays detailed information about a Community.
class CommunityDetailsView extends StatefulWidget {
  const CommunityDetailsView({
    super.key,
    required this.teamId,
  });

  static const routeName = '/sample_item';

  final String teamId;

  @override
  State<CommunityDetailsView> createState() => _CommunityDetailsViewState();
}

class _CommunityDetailsViewState extends State<CommunityDetailsView> {
  Team? team;
  List<Membership>? teamMembers;
  bool isNavigated = false; // Track if navigation has already happened

  @override
  Widget build(BuildContext context) {
    print('Building CommunityDetailsView');
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: true);
    try {
      team = dbProvider.teams.firstWhere(
        (team) => team.$id == widget.teamId,
      );
      teamMembers = dbProvider.teamMembers[widget.teamId];
    } catch (e) {
      team = null;
      teamMembers = null;
    }

    if ((team == null || teamMembers == null) && !isNavigated) {
      Future.microtask(() {
        if (!isNavigated) {
          isNavigated =
              true; // Set the flag to true to prevent further navigation
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You are no longer a member of the community'),
            ),
          );
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: (team != null && teamMembers != null)
            ? Row(
                children: [
                  CircleAvatar(
                    child: Icon(IconData(team!.prefs.data['iconCode'],
                        fontFamily: 'MaterialIcons')),
                  ),
                  const SizedBox(width: 10),
                  // display the name and description of the community
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(team!.name),
                        Text(
                          team!.prefs.data['description'],
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : null,
      ),
      body: (team != null && teamMembers != null)
          ? SafeArea(
              child: Column(
                children: [
                  Text(team!.prefs.data['description']),
                  // display a list of members in the community
                  Expanded(
                    child: ListView.builder(
                      itemCount: teamMembers!.length,
                      itemBuilder: (context, index) {
                        final Membership member = teamMembers![index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text(member.userName[0]),
                          ),
                          title: Text(member.userName),
                          subtitle: Text(member.userEmail),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : const CustomProgressIndicator(),
    );
  }
}
