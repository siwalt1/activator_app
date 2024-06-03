import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.alignment = Alignment.center,
    this.color,
    this.textColor,
  });

  final String text;
  final VoidCallback onPressed;
  final Alignment alignment;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: MaterialButton(
        onPressed: onPressed,
        color: color ?? Theme.of(context).colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
        highlightElevation: 0,
        height: 42.0,
        child: Align(
          alignment: alignment,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
