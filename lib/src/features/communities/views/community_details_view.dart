import 'dart:io';

import 'package:activator_app/src/core/controllers/settings_controller.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
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

class _CommunityDetailsViewState extends State<CommunityDetailsView>
    with SingleTickerProviderStateMixin {
  Team? team;
  List<Membership>? teamMembers;
  bool isNavigated = false; // Track if navigation has already happened
  bool isTitleTapped = false;
  late bool _isRocketClicked = false;

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

  @override
  Widget build(BuildContext context) {
    final dbProvider = Provider.of<DatabaseProvider>(context);

    try {
      team = dbProvider.teams.firstWhere(
        (team) => team.$id == widget.teamId,
      );
      teamMembers = dbProvider.teamMembers[widget.teamId];
    } catch (e) {
      team = null;
      teamMembers = null;
    }

    double rocketWidth;
    if (MediaQuery.of(context).size.width * 2 / 3 >
        MediaQuery.of(context).size.height / 2) {
      rocketWidth = MediaQuery.of(context).size.height / 2;
    } else {
      rocketWidth = MediaQuery.of(context).size.width * 2 / 3;
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
                                // rocket smoke height
                                MediaQuery.of(context).size.width *
                                    2 /
                                    3 *
                                    1.5 -
                                MediaQuery.of(context).padding.bottom -
                                MediaQuery.of(context).padding.top) -
                        35,
                    left: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isRocketClicked = !_isRocketClicked;
                        if (_isRocketClicked) {
                          _rocketController.forward();
                        } else {
                          _rocketController.reverse();
                        }
                      }),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/starting_rocket.png',
                            width: rocketWidth,
                            height: rocketWidth,
                          ),
                        ],
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
                      top: MediaQuery.of(context).size.height / 2,
                      left: 20,
                      right: 20,
                      child: Column(
                        children: [
                          Text(
                            'Session started',
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.left,
                          ),
                          Text(
                            'by Max Mustermann',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(
                              height: AppConstants.separatorSpacing * 2),
                          Text(
                            '${teamMembers!.length} attendee${teamMembers!.length > 1 ? 's' : ''}:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                          const SizedBox(
                              height: AppConstants.separatorSpacing / 2),
                          SizedBox(
                            width: MediaQuery.of(context).size.width -
                                AppConstants.paddingSpacing * 2,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minWidth: MediaQuery.of(context).size.width -
                                      AppConstants.paddingSpacing * 2,
                                ),
                                child: IntrinsicWidth(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: teamMembers!
                                        .map(
                                          (member) => Padding(
                                            padding: const EdgeInsets.only(
                                                right: 10),
                                            child: Container(
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppConstants
                                                            .borderRadius),
                                              ),
                                              child: Text(
                                                member.userName,
                                                style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                              height: AppConstants.separatorSpacing * 2),
                          CustomButton(
                            onPressed: () {
                              // Navigate to the session view
                            },
                            text: 'Join session',
                            fitTextWidth: true,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : const CustomProgressIndicator(),
    );
  }
}
