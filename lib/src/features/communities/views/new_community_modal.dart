import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/enum_converter.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:activator_app/src/features/communities/widgets/activity_type_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:provider/provider.dart';

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
  bool _isLoading = false;
  ActivityType? _selectedActivityType;
  IconData? _selectedIcon;
  bool _isSubmitted = false;

  _pickIcon() async {
    IconData? icon = await showIconPicker(
      context,
      iconPackModes: [IconPack.roundedMaterial],
    );

    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });
    }
  }

  Future<void> _submit() async {
    setState(() {
      _isSubmitted = true;
    });
    if (_formKey.currentState!.validate() &&
        _selectedIcon != null &&
        _selectedActivityType != null) {
      setState(() {
        _isLoading = true;
      });
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      try {
        await dbProvider.createCommunity(
          _nameController.text,
          _descriptionController.text,
          _selectedIcon!.codePoint,
          EnumConverter.enumToString(_selectedActivityType!),
        );
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      } catch (e) {
        print(e.toString());
        setState(() {
          _isLoading = false;
        });
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Something went wrong'),
              content: const Text('Try again later.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      }
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
                                      borderRadius: BorderRadius.circular(100),
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
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_isSubmitted && _selectedIcon == null)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text(
                                    'Please select an icon',
                                    style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(
                                height: AppConstants.separatorSpacing),
                            Row(
                              children: [
                                const Text(
                                  'Type of activities',
                                  style: TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(
                                    width: AppConstants.listTileSpacing),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                        title: const Text('Activity types'),
                                        content: RichText(
                                          text: const TextSpan(
                                            text: '',
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: 'Solo',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text:
                                                    ': Activities that can be done alone, such as reading a book or going for a jog.\n\n',
                                              ),
                                              TextSpan(
                                                text: 'Multi',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text:
                                                    ': Activities that require more than one person, like playing a board game or participating in team sports.',
                                              ),
                                            ],
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(100),
                                  child: const Icon(
                                    Icons.help_outline,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                                height: AppConstants.separatorSpacing / 2),
                            SizedBox(
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
                            if (_isSubmitted && _selectedActivityType == null)
                              Padding(
                                padding:
                                    const EdgeInsets.only(top: 4.0, left: 10.0),
                                child: Text(
                                  'Please select an activity type',
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(
                                height: AppConstants.separatorSpacing),
                            CustomTextFormField(
                              label: 'Community name',
                              initialValue: '',
                              controller: _nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a name';
                                }
                                if (value.length > 30) {
                                  return 'Name must be less than 30 characters';
                                }
                                if (value.endsWith(' ')) {
                                  return 'Name should not end with spaces';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                                height: AppConstants.separatorSpacing),
                            CustomTextFormField(
                              label: 'Community description',
                              initialValue: '',
                              maxLines: 2,
                              keyboardType: TextInputType.multiline,
                              controller: _descriptionController,
                              validator: (value) {
                                if (value != null &&
                                    value.isNotEmpty &&
                                    value.length > 500) {
                                  return 'Description must be less than 500 characters';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.separatorSpacing),
                        CustomButton(
                          text: 'Create community',
                          onPressed: _submit,
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
        if (_isLoading) const CustomProgressIndicator()
      ],
    );
  }
}
