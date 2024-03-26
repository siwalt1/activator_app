import 'package:flutter/material.dart';

class ProfileListItem extends StatelessWidget {
  const ProfileListItem({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.marginBottom = 0,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final double marginBottom;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: ListTile(
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: color?.withOpacity(0.35) ?? Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  width: 0.75,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              visualDensity: const VisualDensity(vertical: -3),
              title: Text(
                text,
                textAlign: TextAlign.start,
                style: TextStyle(
                  color: color ?? Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                ),
              ),
              onTap: onPressed,
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: color?.withOpacity(0.75) ?? Theme.of(context).colorScheme.secondary.withOpacity(0.6),
              ),
            ),
    );
  }
}