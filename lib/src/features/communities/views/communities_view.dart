import 'dart:io';

import 'package:flutter/material.dart';

import '../models/community.dart';
import 'community_details_view.dart';

class CommunitiesView extends StatelessWidget {
  const CommunitiesView({
    super.key,
    this.items = const [
      Community(id: 1, name: 'Gardening', icon: Icons.grass, description: 'Landscaping and gardening enthusiasts'),
      Community(id: 2, name: 'Gym', icon: Icons.fitness_center, description: 'Worlds best gym community'),
      Community(id: 3, name: 'Running', icon: Icons.directions_run, description: 'Lörracher Runners Club'),
      Community(id: 4, name: 'Cycling', icon: Icons.directions_bike, description: 'Penzberger Radler Club'),
      Community(id: 5, name: 'Gaming', icon: Icons.videogame_asset, description: 'Gamers unite!'),
    ],
  });

  final List<Community> items;

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
              onPressed: () {
                print('Add new community');
              },
            ),
        ],
      ),
      floatingActionButton: Platform.isAndroid
          ? FloatingActionButton(
              onPressed: () {
                print('Add new community');
              },
              child: const Icon(Icons.add),
            )
          : null,
      body: ListView.builder(
        // Providing a restorationId allows the ListView to restore the
        // scroll position when a user leaves and returns to the app after it
        // has been killed while running in the background.
        restorationId: 'CommunityListView',
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final item = items[index];

          return ListTile(
              title: Text(item.name),
              leading: CircleAvatar(
                child: Icon(item.icon),
              ),
              onTap: () {
                // Navigate to the details page. If the user leaves and returns to
                // the app after it has been killed while running in the
                // background, the navigation stack is restored.
                // Navigator.restorablePushNamed(
                //   context,
                //   CommunityDetailsView.routeName,
                // );
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CommunityDetailsView(
                      community: item,
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
