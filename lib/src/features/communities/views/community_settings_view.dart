import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile_divider.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CommunitySettingsView extends StatefulWidget {
  const CommunitySettingsView({
    Key? key,
    required this.teamId,
  }) : super(key: key);

  static const routeName = '/community_settings';

  final String teamId;

  @override
  State<CommunitySettingsView> createState() => _CommunitySettingsViewState();
}

class _CommunitySettingsViewState extends State<CommunitySettingsView> {
  Team? team;
  List<Membership>? teamMembers;
  bool isNavigated = false; // Track if navigation has already happened

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
          Navigator.of(context).pop();
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          // Add a 'edit' button to the app bar with the text 'Edit' - no icon button - when clicked it does not show a border around the button
          TextButton(
            onPressed: () {
              print('Edit button clicked');
            },
            child: const Text('Edit'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingSpacing),
          child: ListView(
            children: <Widget>[
              Center(
                child: CircleAvatar(
                  radius: 50,
                  child: Icon(
                    IconData(team!.prefs.data['iconCode'],
                        fontFamily: 'MaterialIcons'),
                    size: 75,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.separatorSpacing / 2),
              Center(
                child: Text(
                  team?.name ?? 'Loading...',
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              Center(
                child: Text(
                  '${teamMembers?.length ?? 0} ${teamMembers?.length == 1 ? 'Member' : 'Members'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.separatorSpacing),
              CustomTextFormField(
                initialValue: team?.prefs.data['description'],
                label: 'Description',
                maxLines: null,
                readOnly: true,
              ),
              const SizedBox(height: AppConstants.separatorSpacing),
              Material(
                color: Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Column(
                    children: [
                      InkWell(
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                        onTap: () => print('Add Members tapped'),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.transparent,
                            child: Icon(
                              Icons.add_link_outlined,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                          title: const Text('Invite to community via link'),
                        ),
                      ),
                      const CustomListTileDivider(),
                      ...List.generate(
                        teamMembers!.length,
                        (index) {
                          final Membership member = teamMembers![index];
                          return Column(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(
                                    AppConstants.borderRadius),
                                onTap: () => print('${member.userName} tapped'),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text(member.userName[0]),
                                  ),
                                  title: Text(member.userName),
                                  subtitle: Text(member.userEmail),
                                ),
                              ),
                              index != teamMembers!.length - 1
                                  ? const CustomListTileDivider()
                                  : const SizedBox(),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
