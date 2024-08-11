import 'package:activator_app/src/core/models/community.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/enum_converter.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:activator_app/src/features/communities/widgets/activity_duration_selector.dart';
import 'package:activator_app/src/features/communities/widgets/activity_type_selector.dart';
import 'package:activator_app/src/features/communities/widgets/notification_type_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconpicker/flutter_iconpicker.dart';
import 'package:provider/provider.dart';

class EditCommunityView extends StatefulWidget {
  const EditCommunityView({
    super.key,
    required this.communityId,
  });

  static const String routeName = '/edit_community';

  final String communityId;

  @override
  State<EditCommunityView> createState() => _EditCommunityViewState();
}

class _EditCommunityViewState extends State<EditCommunityView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;
  late ActivityType _selectedActivityType;
  late IconData _selectedIcon;
  late NotificationType _selectedNotificationType;
  late int _selectedActivityDuration;
  late Community _community;
  final ValueNotifier<bool> _controllerListener = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
    _community = dbProvider.communities.firstWhere(
      (element) => element.id == widget.communityId,
    );
    _nameController.text = _community.name;
    _descriptionController.text = _community.description ?? '';
    _selectedIcon = IconData(_community.iconCode, fontFamily: 'MaterialIcons');
    _selectedActivityType = _community.type;
    _selectedNotificationType = _community.notificationType;
    _selectedActivityDuration = _community.activityDuration;

    _nameController.addListener(_updateControllerListener);
    _descriptionController.addListener(_updateControllerListener);
  }

  _pickIcon() async {
    IconData? icon = await showIconPicker(
      context,
      iconPackModes: [IconPack.roundedMaterial],
    );

    if (icon != null) {
      setState(() {
        _selectedIcon = icon;
      });
      _updateControllerListener();
    }
  }

  Future<void> _submit() async {
    // update form state
    if (_formKey.currentState!.validate()) {
      // if the activity type has changed, ask the user to confirm
      if (_community.type != _selectedActivityType) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Change activity type?'),
              content: const Text(
                'Changing the activity type will stop all current activities. Are you sure you want to proceed?',
              ),
              actions: [
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                CupertinoButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Proceed'),
                ),
              ],
            );
          },
        );
        if (confirmed != true) {
          return;
        }
      }
      setState(() {
        _isLoading = true;
      });
      if (!mounted) return;
      final dbProvider = Provider.of<DatabaseProvider>(context, listen: false);
      try {
        await dbProvider.updateCommunity(
          _community.id,
          _nameController.text,
          _descriptionController.text,
          _selectedIcon.codePoint,
          EnumConverter.enumToString(_selectedActivityType),
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
                CupertinoButton(
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

  void _updateControllerListener() {
    _controllerListener.value =
        !(_community.iconCode == _selectedIcon.codePoint &&
                _community.type == _selectedActivityType &&
                _community.name == _nameController.text &&
                _community.description == _descriptionController.text &&
                _community.notificationType == _selectedNotificationType &&
                _community.activityDuration == _selectedActivityDuration) &&
            !_isLoading;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _controllerListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ValueListenableBuilder<bool>(
            valueListenable: _controllerListener,
            builder: (_, settingsHaveChangedAndIsNotLoading, child) {
              return CupertinoButton(
                onPressed: settingsHaveChangedAndIsNotLoading ? _submit : null,
                child: const Text('Done'),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                left: AppConstants.paddingSpacing,
                right: AppConstants.paddingSpacing,
                bottom: AppConstants.paddingSpacing,
                top: 0,
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Form(
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
                                      width: 100,
                                      height: 100,
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
                                        _selectedIcon,
                                        size: 40,
                                      ),
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
                                            text: TextSpan(
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface,
                                                fontSize: 14,
                                              ),
                                              children: const <TextSpan>[
                                                TextSpan(
                                                  text: 'Solo',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      ': Activities that are done alone, such as reading a book or meditating. These sessions are done separately and at different times.\n\n',
                                                ),
                                                TextSpan(
                                                  text: 'Real-time',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                TextSpan(
                                                  text:
                                                      ': Activities that require more than one person, like playing a board game or participating in team sports. These sessions are done in real-time.',
                                                ),
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            CupertinoButton(
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
                                      if (type == ActivityType.solo &&
                                          _selectedNotificationType ==
                                              NotificationType
                                                  .activityCreationNoJoin) {
                                        _selectedNotificationType =
                                            NotificationType.all;
                                      }
                                      _updateControllerListener();
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(
                                  height: AppConstants.separatorSpacing),
                              CustomTextFormField(
                                label: 'Community name',
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
                                label: 'Community description (optional)',
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
                              const SizedBox(
                                  height: AppConstants.separatorSpacing),
                              NotificationTypeSelector(
                                selectedNotificationType:
                                    _selectedNotificationType,
                                notificationTypeList: NotificationType.values
                                    .where((type) => !(_selectedActivityType ==
                                            ActivityType.solo &&
                                        type ==
                                            NotificationType
                                                .activityCreationNoJoin))
                                    .toList(),
                                onNotificationTypeSelected: (type) {
                                  setState(() {
                                    _selectedNotificationType = type;
                                  });
                                  _updateControllerListener();
                                },
                              ),
                              ActivityDurationSelector(
                                selectedActivityDuration:
                                    _selectedActivityDuration,
                                onActivityDurationTypeSelected: (duration) {
                                  setState(() {
                                    _selectedActivityDuration = duration;
                                  });
                                  _updateControllerListener();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.separatorSpacing),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading) const CustomProgressIndicator(),
        ],
      ),
    );
  }
}
