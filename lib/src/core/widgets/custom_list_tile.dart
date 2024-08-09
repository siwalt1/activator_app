import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomListTile extends StatelessWidget {
  const CustomListTile({
    super.key,
    required this.text,
    required this.onPressed,
    this.textColor,
    this.marginBottom = 0,
    this.showArrow = true,
    this.textAlign = TextAlign.start,
    this.backgroundColor,
    this.trailing,
  });

  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;
  final double marginBottom;
  final bool showArrow;
  final TextAlign textAlign;
  final Color? backgroundColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: marginBottom),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow, // Shadow color
              spreadRadius: 0.1, // Spread radius
              blurRadius: 0.2, // Blur radius
            ),
          ],
        ),
        child: ListTile(
          tileColor:
              backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          visualDensity: const VisualDensity(vertical: -3),
          title: Text(
            text,
            textAlign: textAlign,
            style: TextStyle(
              color: textColor ?? Theme.of(context).colorScheme.onSurface,
              fontSize: 16,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          onTap: onPressed,
          trailing: trailing ??
              (showArrow
                  ? Icon(
                      Icons.arrow_forward_ios,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 15,
                    )
                  : null),
        ),
      ),
    );
  }
}
