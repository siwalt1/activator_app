import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.label,
    this.initialValue = '',
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.focusNode,
    this.readOnly = false,
  });

  final String? label;
  final String initialValue;
  final int? maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: controller?.text ?? initialValue,
      validator: validator,
      builder: (FormFieldState<String> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: label,
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none,
                ),
                controller:
                    controller ?? TextEditingController(text: initialValue),
                maxLines: maxLines,
                maxLength: maxLength,
                keyboardType: keyboardType,
                obscureText: obscureText,
                readOnly: readOnly,
                focusNode: focusNode,
                onChanged: (value) {
                  state.didChange(value);
                },
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 2.5, left: 10.0, bottom: 4),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12.0,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
