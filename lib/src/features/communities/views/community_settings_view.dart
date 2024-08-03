import 'package:activator_app/src/core/models/activity.dart';
import 'package:activator_app/src/core/models/activity_attendance.dart';
import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/models/community_membership.dart';
import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_bottom_sheet_body.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile_divider.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share/share.dart';

class CommunitySettingsView extends StatefulWidget {
  const CommunitySettingsView({
    super.key,
    required this.communityId,
  });

  static const routeName = '/community-settings';

  final String communityId;

  @override
  State<CommunitySettingsView> createState() => _CommunitySettingsViewState();
}

class _CommunitySettingsViewState extends State<CommunitySettingsView> {
  Community? community;
  List<CommunityMembership>? communityMemberships;
  List<Activity>? activities;
  List<ActivityAttendance>? activityAttendances;
  bool isNavigated = false; // Track if navigation has already happened
  bool _isLoading = false;

  void _leaveCommunity(bool isLastMember) async {
    Future<void> leaveCommunityAction() async {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      try {
        setState(() {
          _isLoading = true;
        });
        await dbProvider.leaveCommunity(widget.communityId);
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Something went wrong'),
                content: const Text('Try again later.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Close'),
                  ),
                ],
              );
            },
          );
        }
      }
    }

    // show a dialog to confirm the action
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Leave Community'),
          content: Text(
              'Are you sure you want to ${isLastMember ? 'delete' : 'leave'} this community?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                leaveCommunityAction();
              },
              child: const Text('Leave'),
            ),
          ],
        );
      },
    );
  }

  void _openInvitationModal(String invitationToken, String communityName) {
    String token = invitationToken;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      useSafeArea: true,
      elevation: 10,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setState,
          ) {
            return CustomBottomSheetBody(
              title: "Invite via link",
              bottomSheetContext: bottomSheetContext,
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    child: Icon(
                      Icons.add_link_outlined,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: AppConstants.separatorSpacing),
                  const Text('Anyone with this link can join the community.'),
                  const SizedBox(height: AppConstants.separatorSpacing),
                  CustomTextFormField(
                    initialValue:
                        'https://open.activator-app.walter-wm.de/invite/$token',
                    readOnly: true,
                    label: null,
                  ),
                  const SizedBox(height: AppConstants.separatorSpacing),
                  CustomButton(
                    text: 'Share Link',
                    color: Theme.of(context).colorScheme.primary,
                    textColor: Theme.of(context).colorScheme.onPrimary,
                    onPressed: () {
                      Share.share(
                          'Join the community "$communityName" on the activator app at https://open.activator-app.walter-wm.de/invite/$token');
                    },
                  ),
                  const SizedBox(height: AppConstants.separatorSpacing),
                  CustomButton(
                    text: 'Reset Link',
                    color: Theme.of(context).colorScheme.surface,
                    textColor: Theme.of(context).colorScheme.onSurface,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Reset Link'),
                            content: const Text(
                              'Are you sure you want to reset the invitation link? This will make the current link invalid.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final dbProvider =
                                      Provider.of<DatabaseProvider>(context,
                                          listen: false);
                                  Navigator.of(context).pop();
                                  String? updatedToken = await dbProvider
                                      .resetInvitationToken(widget.communityId);
                                  setState(() {
                                    token = updatedToken ?? token;
                                  });
                                },
                                child: const Text('Reset'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openUserModal(String userName, DateTime dateJoined, bool isOwnProfile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.borderRadius),
        ),
      ),
      useSafeArea: true,
      elevation: 10,
      builder: (BuildContext bottomSheetContext) {
        return StatefulBuilder(
          builder: (
            BuildContext context,
            void Function(void Function()) setState,
          ) {
            return CustomBottomSheetBody(
              bottomSheetContext: bottomSheetContext,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      child: Text(userName[0],
                          style: const TextStyle(fontSize: 30)),
                    ),
                    const SizedBox(height: AppConstants.separatorSpacing),
                    Text(
                      '${userName}${isOwnProfile ? ' (You)' : ''}',
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: AppConstants.separatorSpacing),
                    // Show the date the user joined the community
                    Text(
                      'Member since ${dateJoined.toLocal().year}-${dateJoined.toLocal().month}-${dateJoined.toLocal().day}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppConstants.separatorSpacing),
                    if (!isOwnProfile)
                      CustomButton(
                        text: 'Remove from Community',
                        color: Theme.of(context).colorScheme.primary,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text('Remove from Community'),
                                content: const Text(
                                    'Are you sure you want to remove this user from the community?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      // remove user from community
                                    },
                                    child: const Text('Remove'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: true);
    try {
      community = dbProvider.communities.firstWhere(
        (com) => com.$id == widget.communityId,
      );
      communityMemberships =
          dbProvider.communityMemberships[widget.communityId];
      activities = dbProvider.activities[widget.communityId];
      activityAttendances = dbProvider.activityAttendances[widget.communityId];
    } catch (e) {
      community = null;
    }

    if ((community == null) && !isNavigated) {
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
      body: (community != null)
          ? Stack(
              children: [
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.paddingSpacing),
                    child: ListView(
                      children: <Widget>[
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            child: Icon(
                              IconData(community?.iconCode ?? 983915,
                                  fontFamily: 'MaterialIcons'),
                              size: 75,
                            ),
                          ),
                        ),
                        const SizedBox(
                            height: AppConstants.separatorSpacing / 2),
                        Center(
                          child: Text(
                            community?.name ?? 'Loading...',
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${communityMemberships?.length ?? 0} ${communityMemberships?.length == 1 ? 'Member' : 'Members'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (community!.description.isNotEmpty)
                          Column(
                            children: [
                              const SizedBox(
                                  height: AppConstants.separatorSpacing),
                              CustomTextFormField(
                                initialValue: community!.description,
                                label: 'Description',
                                maxLines: null,
                                readOnly: true,
                              ),
                            ],
                          ),
                        const SizedBox(height: AppConstants.separatorSpacing),
                        Material(
                          color: Theme.of(context).colorScheme.surfaceContainer,
                          borderRadius:
                              BorderRadius.circular(AppConstants.borderRadius),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  AppConstants.borderRadius),
                            ),
                            child: Column(
                              children: [
                                InkWell(
                                  borderRadius: BorderRadius.circular(
                                      AppConstants.borderRadius),
                                  onTap: () => _openInvitationModal(
                                    community!.invitationToken,
                                    community!.name,
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      child: Icon(
                                        Icons.add_link_outlined,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface,
                                      ),
                                    ),
                                    title: const Text(
                                        'Invite to community via link'),
                                  ),
                                ),
                                const CustomListTileDivider(),
                                ...List.generate(
                                  communityMemberships!.length,
                                  (index) {
                                    final CommunityMembership membership =
                                        communityMemberships![index];
                                    return Column(
                                      children: [
                                        InkWell(
                                          borderRadius: BorderRadius.circular(
                                              AppConstants.borderRadius),
                                          onTap: () {
                                            final AuthProvider authProvider =
                                                Provider.of<AuthProvider>(
                                                    context,
                                                    listen: false);
                                            _openUserModal(
                                              dbProvider
                                                  .userProfiles[
                                                      membership.userId]!
                                                  .name,
                                              membership.createdAt,
                                              membership.userId ==
                                                  authProvider.user!.id,
                                            );
                                          },
                                          child: ListTile(
                                            leading: CircleAvatar(
                                              child: Text(dbProvider
                                                  .userProfiles[
                                                      membership.userId]!
                                                  .name[0]),
                                            ),
                                            title: Text(dbProvider
                                                .userProfiles[
                                                    membership.userId]!
                                                .name),
                                          ),
                                        ),
                                        index !=
                                                communityMemberships!.length - 1
                                            ? const CustomListTileDivider()
                                            : const SizedBox(),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: AppConstants.separatorSpacing),
                        CustomListTile(
                          text: communityMemberships?.length == 1
                              ? 'Delete Community'
                              : 'Leave Community',
                          onPressed: () => _leaveCommunity(
                              communityMemberships?.length == 1),
                          showArrow: false,
                          textAlign: TextAlign.center,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_isLoading) const CustomProgressIndicator(),
              ],
            )
          : const CustomProgressIndicator(),
    );
  }
}
