import 'dart:io';

import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationTypeSelector extends StatelessWidget {
  const NotificationTypeSelector({
    super.key,
    required this.selectedNotificationType,
    required this.notificationTypeList,
    required this.onNotificationTypeSelected,
  });

  final NotificationType selectedNotificationType;
  final List<NotificationType> notificationTypeList;
  final ValueChanged<NotificationType> onNotificationTypeSelected;

  void _showNotificationPicker(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) {
        return Container(
          height: 216,
          padding: const EdgeInsets.only(top: 6.0),
          // The Bottom margin is provided to align the popup above the system navigation bar.
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: SafeArea(
            child: CupertinoPicker(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              squeeze: Platform.isIOS ? 1.45 : 1.2,
              useMagnifier: true,
              itemExtent: 32.0,
              onSelectedItemChanged: (int index) {
                final NotificationType selectedNotificationType =
                    notificationTypeList[index];
                onNotificationTypeSelected(selectedNotificationType);
              },
              scrollController: FixedExtentScrollController(
                initialItem: notificationTypeList.indexOf(
                  selectedNotificationType,
                ),
              ),
              children: notificationTypeList.map((NotificationType type) {
                return Center(child: Text(notificationTypeDescriptions[type]!));
              }).toList(),
            ),
          ),
        );
      },
    ).then((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      text: "Notifications",
      onPressed: () => _showNotificationPicker(context),
      marginBottom: AppConstants.listTileSpacing,
      showArrow: false,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            notificationTypeDescriptions[selectedNotificationType]!,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            size: 15,
          )
        ],
      ),
    );
  }
}
