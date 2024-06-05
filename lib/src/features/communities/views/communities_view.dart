import 'dart:io';

import 'package:activator_app/src/core/utils/format_date.dart';
import 'package:activator_app/src/features/communities/views/new_community_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/community.dart';
import 'community_details_view.dart';

class CommunitiesView extends StatefulWidget {
  const CommunitiesView({
    super.key,
  });

  @override
  State<CommunitiesView> createState() => _CommunitiesViewState();
}

class _CommunitiesViewState extends State<CommunitiesView> {
  // final DatabaseService _databaseService = DatabaseService();
  late List<Community> _items;
  late MediaQueryData _mediaQueryData;

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      _updateMediaQueryData();
      _listenForOrientationChanges();
    });
  }

  void _updateMediaQueryData() {
    setState(() {
      _mediaQueryData = MediaQuery.of(context);
    });
  }

  void _listenForOrientationChanges() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]).then((_) {
      _updateMediaQueryData();
    });
  }

  void _openMaterialModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(12.0),
        ),
      ),
      elevation: 10,
      builder: (BuildContext bottomSheetContext) {
        return NewCommunityModal(mediaQueryData: _mediaQueryData);
      },
    );
  }


  Future<void> _loadData() async {
    // final communities = await _databaseService.getCommunities();
    // for (var community in communities) {
    //   final sessions = await _databaseService.getSessions(community.id);
    //   community.sessions.addAll(sessions);
    // }
    final communities = [
      Community(
        id: 1,
        name: 'Gardening',
        icon: Icons.grass,
        description: 'Landscaping and gardening enthusiasts',
        sessions: [
          CommunitySession(
            id: 101,
            startTime: DateTime(2024, 5, 1, 10, 0),
            endTime: DateTime(2024, 5, 1, 12, 0),
            community: 1,
            attendees: ['alice.schmidt@gmail.com'],
          ),
        ],
      ),
      Community(
        id: 2,
        name: 'Gym',
        icon: Icons.fitness_center,
        description: 'Worlds best gym community',
        sessions: [
          CommunitySession(
            id: 201,
            startTime: DateTime(2024, 5, 2, 8, 0),
            endTime: DateTime(2024, 5, 2, 10, 0),
            community: 2,
            attendees: ['charlie.boss@web.de'],
          ),
        ],
      ),
      Community(
        id: 3,
        name: 'Running',
        icon: Icons.directions_run,
        description: 'Lörracher Runners Club',
        sessions: [
          CommunitySession(
            id: 301,
            startTime: DateTime(2024, 5, 3, 7, 0),
            endTime: DateTime(2024, 5, 3, 9, 0),
            community: 3,
            attendees: ['eve.zweier@gmail.com', 'frank.fill@gmail.com'],
          ),
        ],
      ),
      Community(
        id: 4,
        name: 'Cycling',
        icon: Icons.directions_bike,
        description: 'Penzberger Radler Club',
        sessions: [
          CommunitySession(
            id: 401,
            startTime: DateTime(2024, 5, 28, 6, 0),
            endTime: DateTime(2024, 5, 28, 8, 0),
            community: 4,
            attendees: ['grace.holl@icloud.com', 'heidi.fisch@web.de'],
          ),
        ],
      ),
      Community(
        id: 5,
        name: 'Gaming',
        icon: Icons.videogame_asset,
        description: 'Gamers unite!',
        sessions: [
          CommunitySession(
            id: 501,
            startTime: DateTime(2024, 5, 5, 18, 0),
            endTime: DateTime(2024, 5, 5, 20, 0),
            community: 5,
            attendees: ['ivan.rob@t-online.de'],
          ),
          CommunitySession(
            id: 502,
            startTime: DateTime(2024, 5, 26, 18, 0),
            endTime: DateTime(2024, 5, 26, 20, 0),
            community: 5,
            attendees: ['ivan.rob@t-online.de'],
          ),
        ],
      ),
    ];

    setState(() {
      _items = communities;
      _items.sort((a, b) =>
          b.sessions!.last.endTime.compareTo(a.sessions!.last.endTime));
    });
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
        child: ListView.builder(
          // Providing a restorationId allows the ListView to restore the
          // scroll position when a user leaves and returns to the app after it
          // has been killed while running in the background.
          restorationId: 'CommunityListView',
          itemCount: _items.length,
          itemBuilder: (BuildContext context, int index) {
            final item = _items[index];

            return InkWell(
              onTap: () {
                routeBuilder(context) => CommunityDetailsView(
                      community: item,
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
                      child: Icon(item.icon),
                    ),
                    title: Text(item.name),
                    subtitle: Text(item.description),
                    trailing: SizedBox(
                      width: 100,
                      child: Stack(
                        children: [
                          // last session date in relation to the current date using formatDate function
                          Align(
                            alignment: Alignment.topRight,
                            child: Text(
                              formatDate(item.sessions!.last.endTime),
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              overflow: TextOverflow.ellipsis,
                              '${item.sessions?.length} session${item.sessions?.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    color: Theme.of(context).dividerColor.withOpacity(0.4),
                    thickness: 0.5,
                    indent: 72,
                    height: 0,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
