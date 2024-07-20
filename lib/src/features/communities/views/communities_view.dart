import 'dart:async';
import 'dart:io';

import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/format_date.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile_divider.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/features/communities/views/new_community_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  void _openMaterialModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.0),
        ),
      ),
      useSafeArea: true,
      elevation: 10,
      builder: (BuildContext bottomSheetContext) {
        return FractionallySizedBox(
          heightFactor: 1,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(bottomSheetContext).viewInsets.bottom,
            ),
            child: const NewCommunityModal(),
          ),
        );
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
                  return ListView.builder(
                    // Providing a restorationId allows the ListView to restore the
                    // scroll position when a user leaves and returns to the app after it
                    // has been killed while running in the background.
                    restorationId: 'CommunityListView',
                    itemCount: value.communities.length,
                    itemBuilder: (BuildContext context, int index) {
                      final community = value.communities[index];
                      if (value.activities[community.$id] == null ||
                          value.communityMemberships[community.$id] == null ||
                          value.activityAttendances[community.$id] == null) {
                        return const CircularProgressIndicator();
                      }
                      bool isCommunityActive = false;
                      if (value.activities[community.$id] != null) {
                        if (community.type == 'solo') {
                          int activityIndex =
                              value.activities[community.$id]!.indexWhere(
                            (act) =>
                                act.endDate.isAfter(DateTime.now().toUtc()) &&
                                act.type == 'solo' &&
                                value.activityAttendances[community.$id]!
                                        .indexWhere(
                                      (att) =>
                                          att.activityId == act.$id &&
                                          att.userId == authProvider.user!.$id,
                                    ) !=
                                    -1,
                          );
                          if (activityIndex != -1) {
                            isCommunityActive = true;
                            // stop previous timer
                            endDateTimer?.cancel();
                            // set a new timer to refresh the view
                            endDateTimer = Timer(
                              value.activities[community.$id]![activityIndex]
                                  .endDate
                                  .difference(DateTime.now().toUtc()),
                              () {
                                setState(() {});
                              },
                            );
                          } else {
                            isCommunityActive = false;
                            endDateTimer?.cancel();
                          }
                        } else if (community.type == 'multi') {
                          int activityIndex =
                              value.activities[community.$id]!.indexWhere(
                            (act) =>
                                act.endDate.isAfter(
                                  DateTime.now().toUtc(),
                                ) &&
                                act.type == 'multi',
                          );
                          if (activityIndex != -1) {
                            isCommunityActive = true;
                            // stop previous timer
                            endDateTimer?.cancel();
                            // set a new timer to refresh the view
                            endDateTimer = Timer(
                              value.activities[community.$id]![activityIndex]
                                  .endDate
                                  .difference(DateTime.now().toUtc()),
                              () {
                                setState(() {});
                              },
                            );
                          } else {
                            isCommunityActive = false;
                            endDateTimer?.cancel();
                          }
                        }
                      }
                      return InkWell(
                        onTap: () {
                          routeBuilder(context) => CommunityDetailsView(
                                communityId: community.$id,
                              );

                          Navigator.of(context).push(
                            Platform.isIOS
                                ? CupertinoPageRoute(
                                    builder: routeBuilder,
                                  )
                                : MaterialPageRoute(
                                    builder: routeBuilder,
                                  ),
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
                                '${value.communityMemberships[community.$id]?.length} member${value.communityMemberships[community.$id]!.length > 1 ? 's' : ''} · ${community.type} activities',
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
                                          value.activities[community.$id]!.last
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
                                    if (isCommunityActive)
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
