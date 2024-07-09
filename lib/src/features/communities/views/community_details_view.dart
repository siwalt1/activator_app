import 'dart:io';

import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/features/communities/views/community_settings_view.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/cupertino.dart';
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
  bool isTitleTapped = false;

  @override
  Widget build(BuildContext context) {
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
            ? GestureDetector(
                onTap: () {
                  Platform.isIOS
                      ? Navigator.of(context).push(
                          CupertinoPageRoute(
                            builder: (context) => CommunitySettingsView(
                              teamId: team!.$id,
                            ),
                          ),
                        )
                      : Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => CommunitySettingsView(
                              teamId: team!.$id,
                            ),
                          ),
                        );
                },
                onTapDown: (_) => setState(() => isTitleTapped = true),
                onTapUp: (_) => setState(() => isTitleTapped = false),
                onTapCancel: () => setState(() => isTitleTapped = false),
                child: Container(
                  color: Colors.transparent,
                  child: Row(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          IconData(team!.prefs.data['iconCode'],
                              fontFamily: 'MaterialIcons'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // display the name and number of members in the community
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team!.name,
                              style: TextStyle(
                                color: isTitleTapped
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withOpacity(0.75)
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            Text(
                              '${teamMembers!.length} member${teamMembers!.length > 1 ? 's' : ''}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isTitleTapped
                                    ? Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant
                                        .withOpacity(0.75)
                                    : Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
      body: (team != null && teamMembers != null)
          ? SafeArea(
              child: Container(),
            )
          : const CustomProgressIndicator(),
    );
  }
}
