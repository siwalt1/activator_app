import 'dart:io';

import 'package:activator_app/src/core/utils/format_duration.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:activator_app/src/core/widgets/platform_alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart'
    as dtp;

class ActivityDurationSelector extends StatefulWidget {
  const ActivityDurationSelector({
    super.key,
    required this.selectedActivityDuration,
    required this.onActivityDurationTypeSelected,
  });

  final int selectedActivityDuration;
  final ValueChanged<int> onActivityDurationTypeSelected;

  @override
  State<ActivityDurationSelector> createState() =>
      _ActivityDurationSelectorState();
}

class _ActivityDurationSelectorState extends State<ActivityDurationSelector> {
  void _showTimePicker() {
    if (Platform.isIOS) {
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
            child: CupertinoTimerPicker(
              mode: CupertinoTimerPickerMode.hm,
              initialTimerDuration: Duration(
                hours: widget.selectedActivityDuration ~/ 60,
                minutes: widget.selectedActivityDuration % 60,
              ),
              onTimerDurationChanged: (Duration newDuration) {
                widget.onActivityDurationTypeSelected(
                  newDuration.inMinutes,
                );
              },
            ),
          );
        },
      ).then((_) {
        FocusScope.of(context).requestFocus(FocusNode());
        if (widget.selectedActivityDuration < 5) {
          _showInvalidDurationDialog();
        }
      });
    } else {
      dtp.DatePicker.showTimePicker(
        context,
        showTitleActions: false,
        onChanged: (time) {
          widget.onActivityDurationTypeSelected(
            time.hour * 60 + time.minute,
          );
        },
        currentTime: DateTime(
          0,
          0,
          0,
          widget.selectedActivityDuration ~/ 60,
          widget.selectedActivityDuration % 60,
        ),
        locale: dtp.LocaleType.en,
        showSecondsColumn: false,
        theme: dtp.DatePickerTheme(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          itemStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 18,
          ),
          doneStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 16,
          ),
          cancelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
          ),
        ),
      ).then((_) {
        FocusScope.of(context).requestFocus(FocusNode());
        if (widget.selectedActivityDuration < 5) {
          _showInvalidDurationDialog();
        }
      });
    }
  }

  void _showInvalidDurationDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return PlatformAlertDialog(
          title: 'Invalid Duration',
          content: const Text(
              'Activity duration should be at least 5 minutes. Please select a valid duration.'),
          showCancel: false,
          onConfirm: () {
            _showTimePicker(); // Reopen the time picker
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomListTile(
      text: "Activity duration",
      onPressed: _showTimePicker,
      marginBottom: 0,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatDuration(widget.selectedActivityDuration),
            style: TextStyle(
                fontSize: 14, color: Theme.of(context).colorScheme.onSurface),
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
