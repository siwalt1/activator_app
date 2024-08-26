import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlatformAlertDialog extends StatelessWidget {
  final String title;
  final Widget content;
  final String cancelText;
  final bool showCancel;
  final String confirmText;
  final VoidCallback? onConfirm;

  const PlatformAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.onConfirm,
    this.showCancel = true,
    this.cancelText = 'Cancel',
    this.confirmText = 'OK',
  });

  @override
  Widget build(BuildContext context) {
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      return CupertinoAlertDialog(
        title: Text(title),
        content: content,
        actions: [
          if (showCancel)
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(cancelText),
            ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.of(context).pop(true);
              if (onConfirm != null) {
                onConfirm!();
              }
            },
            child: Text(confirmText),
          ),
        ],
      );
    } else {
      return AlertDialog(
        title: Text(title),
        content: content,
        actions: [
          if (showCancel)
            CupertinoButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(cancelText),
            ),
          CupertinoButton(
            onPressed: () {
              Navigator.of(context).pop(true);
              if (onConfirm != null) {
                onConfirm!();
              }
            },
            child: Text(confirmText),
          ),
        ],
      );
    }
  }
}
