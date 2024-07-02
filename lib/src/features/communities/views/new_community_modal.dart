import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:activator_app/src/features/communities/widgets/activity_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';

class NewCommunityModal extends StatefulWidget {
  const NewCommunityModal({
    super.key,
  });

  @override
  State<NewCommunityModal> createState() => _NewCommunityModalState();
}

class _NewCommunityModalState extends State<NewCommunityModal> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  ActivityType _selectedActivityType = ActivityType.solo;
  IconData? _selectedIcon;

  _pickIcon() async {
    IconData? icon = await showIconPicker(
      context,
      iconPackModes: [IconPack.roundedMaterial],
    );

    if (icon != null) _selectedIcon = icon;
    setState(() {});
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      // submit formpers
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
              const SizedBox(height: AppConstants.separatorSpacing),
              Flexible(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Material(
                                color: Theme.of(context)
                                    .colorScheme
                                    .surfaceContainer,
                                borderRadius: BorderRadius.circular(100),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(100),
                                  onTap: _pickIcon,
                                  child: Container(
                                      width: 80,
                                      height: 80,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12.5, horizontal: 8),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .dividerColor
                                              .withOpacity(0.05),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        _selectedIcon ?? Icons.add,
                                        size: 40,
                                      )),
                                ),
                              ),
                            ),
                            const SizedBox(
                                height: AppConstants.separatorSpacing),
                            const Text(
                              'Type of activities',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                                height: AppConstants.separatorSpacing / 2),
                            Container(
                              width: double.infinity,
                              child: ActivityTypeSelector(
                                selectedActivityType: _selectedActivityType,
                                onActivityTypeSelected: (type) {
                                  setState(() {
                                    _selectedActivityType = type;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(
                                height: AppConstants.separatorSpacing),
                            CustomTextFormField(
                              label: 'Community name',
                              initialValue: '',
                              controller: _nameController,
                            ),
                            const SizedBox(
                                height: AppConstants.separatorSpacing),
                            CustomTextFormField(
                              label: 'Community description',
                              initialValue: '',
                              maxLines: 2,
                              keyboardType: TextInputType.multiline,
                              controller: _descriptionController,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.separatorSpacing),
                        CustomButton(
                          text: 'Create community',
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          color: Theme.of(context).colorScheme.primary,
                          textColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: AppConstants.separatorSpacing),
                      ],
                    ),
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
    );
  }
}
