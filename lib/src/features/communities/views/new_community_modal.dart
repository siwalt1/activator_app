import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_input_field.dart';
import 'package:flutter/material.dart';

class NewCommunityModal extends StatelessWidget {
  const NewCommunityModal({
    super.key,
    required this.mediaQueryData,
  });

  final MediaQueryData mediaQueryData;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: mediaQueryData.size.height - mediaQueryData.padding.top,
        width: double.infinity,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text(
                    'Create a new community',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: AppConstants.separatorSpacing),
                          const CustomInputField(
                            label: 'Community name',
                            initialValue: '',
                          ),
                          const SizedBox(height: AppConstants.separatorSpacing),
                          const CustomInputField(
                            label: 'Community description',
                            initialValue: '',
                            maxLines: 3,
                            keyboardType: TextInputType.multiline,
                          ),
                          const SizedBox(height: AppConstants.separatorSpacing),
                          CustomButton(
                            text: 'Create community',
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: AppConstants.paddingSpacing / 2,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
