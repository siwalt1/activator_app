import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomInputField extends StatelessWidget {
  const CustomInputField({
    super.key,
    required this.label,
    required this.initialValue,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final String initialValue;
  final int maxLines;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            spreadRadius: 0.1,
            blurRadius: 0.2,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
        ),
        controller: TextEditingController(text: initialValue),
        maxLines: maxLines, // Allow multiple lines
        keyboardType: keyboardType, // Enable multiline input
        // textAlignVertical: TextAlignVertical.top, // Align text to top
      ),
    );
  }
}
