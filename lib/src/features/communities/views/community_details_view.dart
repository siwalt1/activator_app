import 'dart:async';

import 'package:activator_app/src/core/controllers/settings_controller.dart';
import 'package:activator_app/src/core/models/activity.dart';
import 'package:activator_app/src/core/models/activity_attendance.dart';
import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/models/community_membership.dart';
import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/features/communities/views/community_settings_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays detailed information about a Community.
class CommunityDetailsView extends StatefulWidget {
  const CommunityDetailsView({
    super.key,
    required this.communityId,
  });

  static const routeName = '/community-details';

  final String communityId;

  @override
  State<CommunityDetailsView> createState() => _CommunityDetailsViewState();
}

class _CommunityDetailsViewState extends State<CommunityDetailsView>
    with SingleTickerProviderStateMixin {
  Community? community;
  List<CommunityMembership>? communityMemberships;
  List<Activity>? activities;
  List<ActivityAttendance>? activityAttendances;
  bool isNavigated = false; // Track if navigation has already happened
  bool isActivityStatusChecked = false;
  bool isTitleTapped = false;
  bool _isJoinBtnLoading = false;
  late bool _isRocketClicked = false;
  Activity? _currentActivity;
  List<ActivityAttendance>? _currentActivityAttendances;
  List<ActivityAttendance>? _currentActiveActivityAttendances;
  bool isUserParticipating = false;
  Timer? endDateTimer;

  late AnimationController _rocketController;
  late Animation<double> _rocketAnimation;

  @override
  void initState() {
    super.initState();
    _rocketController = AnimationController(
      duration: const Duration(seconds: 2, milliseconds: 30),
      vsync: this,
    );

    _rocketAnimation = CurvedAnimation(
      parent: _rocketController,
      curve: Curves.easeInOutCubic,
    );

    _rocketController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _rocketController.dispose();
    super.dispose();
  }

  _createActivity(BuildContext context, bool isNew) async {
    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      await dbProvider.createActivity(community!.$id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isNew ? 'Error creating activity' : 'Error joining activity',
          ),
        ),
      );
      if (isNew) _rocketController.reverse();
    }
  }

  _leaveActivity(BuildContext context) async {
    try {
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      await dbProvider.leaveActivity(community!.$id, _currentActivity!.$id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error leaving activity'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      community = dbProvider.communities.firstWhere(
        (com) => com.$id == widget.communityId,
      );
      communityMemberships =
          dbProvider.communityMemberships[widget.communityId];
      activities = dbProvider.activities[widget.communityId];
      activityAttendances = dbProvider.activityAttendances[widget.communityId];
      Activity? previousActivity = _currentActivity;
      if (activities!.isNotEmpty) {
        if (community!.type == 'multi') {
          int activityIndex = activities!
              .indexWhere((act) => act.endDate.isAfter(DateTime.now().toUtc()));
          if (activityIndex != -1) {
            _currentActivity = activities![activityIndex];
          } else {
            _currentActivity = null;
          }
        } else if (community!.type == 'solo') {
          int activityIndex = activities!.indexWhere((act) =>
              act.endDate.isAfter(DateTime.now().toUtc()) &&
              activityAttendances!.indexWhere(
                    (att) =>
                        att.activityId == act.$id &&
                        att.userId == authProvider.user!.$id,
                  ) !=
                  -1);
          if (activityIndex != -1) {
            _currentActivity = activities![activityIndex];
          } else {
            _currentActivity = null;
          }
        }
        _currentActivityAttendances = activityAttendances!
            .where((att) => att.activityId == _currentActivity?.$id)
            .toList();
        _currentActiveActivityAttendances =
            _currentActivityAttendances!.where((att) => att.active).toList();

        if (_currentActivity != null) {
          // stop previous activity timer
          if (endDateTimer != null) {
            endDateTimer!.cancel();
          }
          // set timer to stop the activity after the end date
          endDateTimer = Timer(
            _currentActivity!.endDate.difference(DateTime.now().toUtc()),
            () {
              _isRocketClicked = false;
              _rocketController.reverse();
              _currentActivity = null;
              _currentActivityAttendances = null;
            },
          );
        }

        // check if the user is participating in the activity
        if (_currentActivity != null) {
          isUserParticipating = _currentActiveActivityAttendances!.indexWhere(
                (att) => att.userId == authProvider.user!.$id,
              ) !=
              -1;
        }
      } else {
        _currentActivity = null;
        _currentActivityAttendances = null;
        _currentActiveActivityAttendances = null;
      }

      // if an activity has just started, animate the rocket to the top
      if (previousActivity == null &&
          _currentActivity != null &&
          isActivityStatusChecked) {
        _isRocketClicked = true;
        _rocketController.forward();
      }

      // if an activity was just stopped, animate the rocket to the bottom
      else if (previousActivity != null &&
          _currentActivity == null &&
          isActivityStatusChecked) {
        _isRocketClicked = false;
        _rocketController.reverse();
      }

      // if no activity is currently running, set the rocket to the bottom
      else if (!isActivityStatusChecked && _currentActivity == null) {
        _rocketController.value = 0.0;
        _isRocketClicked = false;
      }

      // if activity is currently running, set the rocket to the top
      else if (!isActivityStatusChecked && _currentActivity != null) {
        _rocketController.value = 1.0;
        _isRocketClicked = true;
      }
      isActivityStatusChecked = true;
    } catch (e) {
      community = null;
    }

    double rocketWidth = MediaQuery.of(context).size.width / 1.25 >
            MediaQuery.of(context).size.height / 1.25
        ? MediaQuery.of(context).size.height / 1.25
        : MediaQuery.of(context).size.width / 1.25;

    if ((community == null) && !isNavigated) {
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
        title: (community != null)
            ? GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(
                    CommunitySettingsView.routeName,
                    arguments: {'communityId': community!.$id},
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
                          IconData(community!.iconCode,
                              fontFamily: 'MaterialIcons'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              community!.name,
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
                              '${communityMemberships!.length} member${communityMemberships!.length > 1 ? 's' : ''}',
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
      body: (community != null)
          ? SafeArea(
              child: Stack(
                children: [
                  Positioned(
                    child: Consumer<SettingsController>(
                      builder: (BuildContext context, SettingsController value,
                          Widget? child) {
                        return Image.asset(
                          value.themeMode == ThemeMode.light ||
                                  value.themeMode == ThemeMode.system &&
                                      MediaQuery.of(context)
                                              .platformBrightness ==
                                          Brightness.light
                              ? 'assets/images/space_bg_light.jpg'
                              : 'assets/images/space_bg.jpg',
                          fit: BoxFit.fill,
                          height: MediaQuery.of(context).size.height,
                          width: MediaQuery.of(context).size.width,
                        );
                      },
                    ),
                  ),
                  Positioned(
                    bottom: _rocketAnimation.value *
                            (MediaQuery.of(context).size.height -
                                rocketWidth -
                                MediaQuery.of(context).padding.bottom -
                                MediaQuery.of(context).padding.top -
                                AppBar().preferredSize.height)
                        // rocket smoke height
                        -
                        rocketWidth / 8.1,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => {
                        _isRocketClicked = !_isRocketClicked,
                        if (_isRocketClicked)
                          {
                            _rocketController.forward(),
                            _createActivity(context, true),
                          }
                      },
                      child: Image.asset(
                        'assets/images/starting_rocket.png',
                        width: rocketWidth,
                        height: rocketWidth,
                      ),
                    ),
                  ),
                  if (_rocketAnimation.value == 0.0)
                    Positioned(
                      top: MediaQuery.of(context).size.height / 4,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Text(
                            'Start a session',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                    ),
                  if (_rocketAnimation.value == 1.0)
                    Positioned(
                      top: rocketWidth + rocketWidth / 8.1,
                      left: 20,
                      right: 20,
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height -
                            rocketWidth -
                            rocketWidth / 8.1 -
                            MediaQuery.of(context).padding.bottom -
                            MediaQuery.of(context).padding.top -
                            AppBar().preferredSize.height,
                        child: SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: MediaQuery.of(context).size.height -
                                  rocketWidth -
                                  rocketWidth / 8.1 -
                                  MediaQuery.of(context).padding.bottom -
                                  MediaQuery.of(context).padding.top -
                                  AppBar().preferredSize.height,
                            ),
                            child: Column(
                              // mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const SizedBox(
                                    height: AppConstants.separatorSpacing),
                                Text(
                                  'Session started',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                // set the activityAttendant with join number 0
                                if (_currentActivityAttendances != null &&
                                    _currentActivityAttendances!.isNotEmpty &&
                                    _currentActivity?.type == 'multi')
                                  Text(
                                    'by ${_currentActivityAttendances?.where((att) => att.joinOrder == 0).toList()[0].userId == authProvider.user?.$id ? 'You' : dbProvider.userProfiles[_currentActivityAttendances?.where((att) => att.joinOrder == 0).toList()[0].userId]?.name ?? 'Unknown'}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                  ),
                                if (_currentActivity?.type == 'multi')
                                  Column(
                                    children: [
                                      const SizedBox(
                                          height:
                                              AppConstants.separatorSpacing *
                                                  2),
                                      Text(
                                        'currently ${_currentActiveActivityAttendances!.length} attendee${_currentActiveActivityAttendances!.length > 1 ? 's' : ''}:',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimary,
                                        ),
                                      ),
                                      const SizedBox(
                                          height:
                                              AppConstants.separatorSpacing /
                                                  2),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width -
                                                AppConstants.paddingSpacing * 2,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: ConstrainedBox(
                                            constraints: BoxConstraints(
                                              minWidth: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  AppConstants.paddingSpacing *
                                                      2,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children:
                                                  _currentActiveActivityAttendances!
                                                      .map(
                                                        (membership) =>
                                                            Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                            right: _currentActivityAttendances!
                                                                        .indexOf(
                                                                            membership) !=
                                                                    _currentActivityAttendances!
                                                                            .length -
                                                                        1
                                                                ? 10
                                                                : 0,
                                                          ),
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .primary,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                    AppConstants
                                                                        .borderRadius),
                                                          ),
                                                          child: Text(
                                                            dbProvider
                                                                    .userProfiles[
                                                                        membership
                                                                            .userId]
                                                                    ?.name ??
                                                                'Unknown',
                                                            style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .onPrimary,
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                Column(
                                  children: [
                                    const SizedBox(
                                        height:
                                            AppConstants.separatorSpacing * 2),
                                    CustomButton(
                                      onPressed: () async => {
                                        setState(() {
                                          _isJoinBtnLoading = true;
                                        }),
                                        isUserParticipating
                                            ? await _leaveActivity(context)
                                            : await _createActivity(
                                                context, false),
                                        setState(() {
                                          _isJoinBtnLoading = false;
                                        }),
                                      },
                                      text: !isUserParticipating
                                          ? 'Join session'
                                          : _currentActivity?.type == 'multi' &&
                                                  _currentActiveActivityAttendances!
                                                          .length >
                                                      1
                                              ? 'Leave session'
                                              : 'End session',
                                      fitTextWidth: true,
                                      isLoading: _isJoinBtnLoading,
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height: AppConstants.separatorSpacing),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
          : const CustomProgressIndicator(),
    );
  }
}
