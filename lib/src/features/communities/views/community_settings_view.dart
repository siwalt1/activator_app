import 'package:activator_app/src/core/models/activity.dart';
import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/models/community_member.dart';
import 'package:activator_app/src/core/models/profile.dart';
import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/format_duration.dart';
import 'package:activator_app/src/core/widgets/custom_bottom_sheet_body.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile_divider.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:activator_app/src/core/widgets/platform_alert_dialog.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:activator_app/src/features/communities/views/edit_community_view.dart';
import 'package:activator_app/src/features/communities/widgets/info_boxes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  List<CommunityMember>? communityMemberships;
  List<Profile>? profiles;
  List<Activity>? activities;
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
              return const PlatformAlertDialog(
                title: 'Something went wrong',
                content: Text('Try again later.'),
                showCancel: false,
                confirmText: 'Close',
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
        return PlatformAlertDialog(
          title: '${isLastMember ? 'Delete' : 'Leave'} Community',
          content: Text(
              'Are you sure you want to ${isLastMember ? 'delete' : 'leave'} this community?'),
          onConfirm: leaveCommunityAction,
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
                          return PlatformAlertDialog(
                            title: 'Reset Link',
                            content: const Text(
                                'Are you sure you want to reset the invitation link? This will make the current link invalid.'),
                            onConfirm: () async {
                              final dbProvider = Provider.of<DatabaseProvider>(
                                  context,
                                  listen: false);
                              String? updatedToken = await dbProvider
                                  .resetInvitationToken(widget.communityId);
                              setState(() {
                                token = updatedToken ?? token;
                              });
                            },
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: AppConstants.separatorSpacing * 2),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openUserModal(
      String userId, String userName, DateTime dateJoined, bool isOwnProfile) {
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
                    if (!isOwnProfile)
                      Column(
                        children: [
                          const SizedBox(height: AppConstants.separatorSpacing),
                          CustomButton(
                            text: 'Remove from Community',
                            color: Theme.of(context).colorScheme.primary,
                            textColor: Theme.of(context).colorScheme.onPrimary,
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (buildContext) {
                                  return PlatformAlertDialog(
                                    title: 'Remove from Community',
                                    content: const Text(
                                        'Are you sure you want to remove this user from the community?'),
                                    onConfirm: () async {
                                      final dbProvider =
                                          Provider.of<DatabaseProvider>(context,
                                              listen: false);
                                      await dbProvider.leaveCommunity(
                                          widget.communityId,
                                          userId: userId);
                                      if (!context.mounted) return;
                                      Navigator.of(context).pop();
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: AppConstants.separatorSpacing * 2),
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
        (com) => com.id == widget.communityId,
      );
      communityMemberships = dbProvider.communityMembers[widget.communityId];
      profiles = dbProvider.profiles.values
          .where((profile) =>
              communityMemberships
                  ?.any((membership) => membership.userId == profile.id) ??
              false)
          .toList();
      profiles?.sort((a, b) => a.name.compareTo(b.name));
      activities = dbProvider.activities[widget.communityId];
    } catch (e) {
      community = null;
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          CupertinoButton(
            onPressed: () => context
                .push('${EditCommunityView.routeName}/${widget.communityId}'),
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
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      clipBehavior: Clip.none,
                      child: Column(
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
                          const SizedBox(height: AppConstants.separatorSpacing),
                          InfoBoxes(
                            items: [
                              IconLabelPair(
                                icon: Icon(community?.type == ActivityType.solo
                                    ? Icons.person
                                    : Icons.people),
                                label: community?.type == ActivityType.solo
                                    ? 'single'
                                    : 'multi',
                              ),
                              IconLabelPair(
                                icon: const Icon(Icons.timelapse),
                                label:
                                    formatDuration(community!.activityDuration),
                              ),
                              IconLabelPair(
                                icon: Icon(community!.notificationType ==
                                        NotificationType.off
                                    ? Icons.notifications_off_outlined
                                    : Icons.notifications_on_outlined),
                                label: community!.notificationType ==
                                        NotificationType.off
                                    ? 'off'
                                    : community!.notificationType ==
                                            NotificationType
                                                .activityCreationNoJoin
                                        ? 'activity started'
                                        : 'on',
                              ),
                            ],
                          ),
                          const SizedBox(
                              height: AppConstants.separatorSpacing * 1.5),
                          if (community?.description?.isNotEmpty ?? false)
                            Column(
                              children: [
                                CustomTextFormField(
                                  initialValue: community!.description!,
                                  label: 'Description',
                                  maxLines: null,
                                  readOnly: true,
                                ),
                                const SizedBox(
                                    height: AppConstants.separatorSpacing),
                              ],
                            ),
                          Material(
                            color:
                                Theme.of(context).colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius),
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
                                    profiles?.length ?? 0,
                                    (index) {
                                      final Profile profile = profiles![index];
                                      final CommunityMember membership =
                                          communityMemberships!.firstWhere(
                                              (membership) =>
                                                  membership.userId ==
                                                  profile.id);
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
                                                profile.id,
                                                profile.name,
                                                membership.createdAt,
                                                membership.userId ==
                                                    authProvider.user!.id,
                                              );
                                            },
                                            child: ListTile(
                                              leading: CircleAvatar(
                                                child: Text(profile.name[0]),
                                              ),
                                              title: Text(profile.name),
                                            ),
                                          ),
                                          index != profiles!.length - 1
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
                            backgroundColor:
                                Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ),
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
