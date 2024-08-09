import 'dart:async';
import 'dart:io';

import 'package:activator_app/src/core/models/activity.dart';
import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/format_date.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile_divider.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/features/communities/views/new_community_modal.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'community_details_view.dart';

class CommunitiesView extends StatefulWidget {
  const CommunitiesView({
    super.key,
  });

  @override
  State<CommunitiesView> createState() => _CommunitiesViewState();
}

class _CommunitiesViewState extends State<CommunitiesView> {
  Timer? endDateTimer; // timer to refresh the view when an activity ends
  DateTime? currentTimerEndDate;

  void _setTimer(DateTime endDate) {
    endDateTimer?.cancel();
    endDateTimer = Timer(endDate.difference(DateTime.now().toUtc()), () {
      if (mounted) {
        setState(() {});
      }
    });
    currentTimerEndDate = endDate;
  }

  void _openMaterialModal(BuildContext context) {
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
        return NewCommunityModal(bottomSheetContext: bottomSheetContext);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities'),
        actions: [
          if (Platform.isIOS)
            IconButton(
              icon: Icon(
                Icons.add_circle,
                size: 35,
                color: Theme.of(context).colorScheme.primary,
              ),
              highlightColor: Colors.transparent,
              onPressed: () => _openMaterialModal(context),
            ),
        ],
      ),
      floatingActionButton: Platform.isAndroid
          ? FloatingActionButton(
              onPressed: () => _openMaterialModal(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: SafeArea(
        child: Consumer<DatabaseProvider>(
          builder:
              (BuildContext context, DatabaseProvider value, Widget? child) {
            if (!value.isInitialized) {
              return const CustomProgressIndicator();
            } else if (value.communities.isEmpty && value.isInitialized) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Image(
                      image: AssetImage(
                        'assets/images/rocket.png',
                      ),
                      width: 150,
                      height: 150,
                    ),
                    const SizedBox(height: AppConstants.separatorSpacing),
                    const Text('Welcome to Activator!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 10),
                    Text(
                      'Create a community to get started',
                      style: TextStyle(
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Consumer<AuthProvider>(
                builder: (BuildContext context, AuthProvider authProvider,
                    Widget? child) {
                  // reset the timer endDate
                  currentTimerEndDate = null;
                  return ListView.builder(
                    // Providing a restorationId allows the ListView to restore the
                    // scroll position when a user leaves and returns to the app after it
                    // has been killed while running in the background.
                    restorationId: 'CommunityListView',
                    itemCount: value.communities.length,
                    itemBuilder: (BuildContext context, int index) {
                      final community = value.communities[index];
                      if (value.activities[community.id] == null ||
                          value.communityMembers[community.id] == null ||
                          value.activities[community.id]!.any((activity) =>
                              value.activityAttendances[activity.id] == null)) {
                        return ListTile(
                          leading: CircleAvatar(
                            child: Icon(
                              IconData(community.iconCode,
                                  fontFamily: 'MaterialIcons'),
                            ),
                          ),
                          title: Text(
                            community.name,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: const Text(
                            'Something went wrong. Please try again later.',
                            style: TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                          onTap: () {},
                        );
                      }
                      Activity? activeActivity;
                      Activity? lastActivity;
                      String lastActivityUser = '';
                      if (value.activities[community.id] != null) {
                        lastActivity = value.activities[community.id]!.last;
                        lastActivityUser = value
                                .profiles[value
                                    .activityAttendances[lastActivity.id]?[0]
                                    .userId]
                                ?.name ??
                            'Someone';
                        if (lastActivityUser ==
                            authProvider.user!.userMetadata?['display_name']) {
                          lastActivityUser = 'You';
                        }
                        if (community.type == ActivityType.solo) {
                          int activityIndex =
                              value.activities[community.id]!.indexWhere(
                            (act) =>
                                act.endDate.isAfter(DateTime.now().toUtc()) &&
                                act.type == ActivityType.solo &&
                                value.activityAttendances[act.id]!.indexWhere(
                                      (att) =>
                                          att.activityId == act.id &&
                                          att.userId == authProvider.user!.id,
                                    ) !=
                                    -1,
                          );

                          if (activityIndex != -1) {
                            activeActivity =
                                value.activities[community.id]![activityIndex];
                            DateTime endDate = value
                                .activities[community.id]![activityIndex]
                                .endDate;
                            if (currentTimerEndDate == null ||
                                (currentTimerEndDate != null &&
                                    currentTimerEndDate!.isAfter(endDate))) {
                              _setTimer(endDate);
                            }
                          }
                        } else if (community.type == ActivityType.multi) {
                          int activityIndex =
                              value.activities[community.id]!.indexWhere(
                            (act) =>
                                act.endDate.isAfter(
                                  DateTime.now().toUtc(),
                                ) &&
                                act.type == ActivityType.multi,
                          );
                          if (activityIndex != -1) {
                            activeActivity =
                                value.activities[community.id]![activityIndex];
                            DateTime endDate = value
                                .activities[community.id]![activityIndex]
                                .endDate;
                            if (currentTimerEndDate == null ||
                                (currentTimerEndDate != null &&
                                    currentTimerEndDate!.isAfter(endDate))) {
                              _setTimer(endDate);
                            }
                          }
                        }
                      }
                      return InkWell(
                        onTap: () {
                          context.push(
                            '${CommunityDetailsView.routeName}/${community.id}',
                          );
                        },
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                child: Icon(
                                  IconData(community.iconCode,
                                      fontFamily: 'MaterialIcons'),
                                ),
                              ),
                              title: Text(
                                community.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                lastActivity?.type == ActivityType.solo ||
                                        lastActivity?.type == ActivityType.multi
                                    ? '$lastActivityUser ${lastActivityUser == 'You' ? 'have' : 'has'} started a session'
                                    : lastActivity?.type ==
                                            ActivityType.createCommunity
                                        ? '$lastActivityUser ${lastActivityUser == 'You' ? 'have' : 'has'} created the community'
                                        : lastActivity?.type ==
                                                ActivityType.joinCommunity
                                            ? '$lastActivityUser ${lastActivityUser == 'You' ? 'have' : 'has'} joined the community'
                                            : lastActivity?.type ==
                                                    ActivityType.leaveCommunity
                                                ? '$lastActivityUser ${lastActivityUser == 'You' ? 'have' : 'has'} left the community'
                                                : lastActivity?.type ==
                                                        ActivityType
                                                            .updateCommunity
                                                    ? '$lastActivityUser ${lastActivityUser == 'You' ? 'have' : 'has'} updated the community settings'
                                                    : '',
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: SizedBox(
                                width: 100,
                                child: Stack(
                                  children: [
                                    // last session date in relation to the current date using formatDate function
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        formatDate(
                                          value.activities[community.id]!.last
                                              .startDate
                                              .toLocal(),
                                        ),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    // if session is active, show a red dot
                                    if (activeActivity != null)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Icon(
                                          Icons.brightness_1_rounded,
                                          size: 12.5,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const CustomListTileDivider(),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
