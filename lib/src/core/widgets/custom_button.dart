import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.alignment = Alignment.center,
    this.color,
    this.textColor,
    this.fitTextWidth = false,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback onPressed;
  final Alignment alignment;
  final Color? color;
  final Color? textColor;
  final bool fitTextWidth;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    Widget mainBtn = MaterialButton(
      onPressed: onPressed,
      color: color ?? Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      elevation: 0,
      highlightElevation: 0,
      height: 56.0,
      visualDensity: const VisualDensity(vertical: -3),
      padding: EdgeInsets.zero,
      child: Align(
        alignment: alignment,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: isLoading ? Colors.transparent : textColor,
              ),
            ),
            if (isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.0,
                ),
              ),
          ],
        ),
      ),
    );

    return fitTextWidth
        ? IntrinsicWidth(
            child: mainBtn,
          )
        : SizedBox(
            width: double.infinity,
            child: mainBtn,
          );
  }
}
