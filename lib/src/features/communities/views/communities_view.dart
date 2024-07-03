import 'dart:io';

import 'package:activator_app/src/core/provider/db_provider.dart';
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
            return ListView.builder(
              // Providing a restorationId allows the ListView to restore the
              // scroll position when a user leaves and returns to the app after it
              // has been killed while running in the background.
              restorationId: 'CommunityListView',
              itemCount: value.communities.length,
              itemBuilder: (BuildContext context, int index) {
                final item = value.communities[index];

                return InkWell(
                  onTap: () {
                    routeBuilder(context) => CommunityDetailsView(
                          communityId: item.id,
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
                          child: Icon(IconData(item.iconCode,
                              fontFamily: 'MaterialIcons')),
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
                                  // formatDate(item.sessions!.last.endTime),
                                  'last session date',
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
                                  // '${item.sessions?.length} session${item.sessions?.length == 1 ? '' : 's'}',
                                  'session count',
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
            );
          },
        ),
      ),
    );
  }
}
