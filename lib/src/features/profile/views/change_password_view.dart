import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:activator_app/src/features/communities/views/community_details_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({
    super.key,
  });

  static const routeName = '/change-password';

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final newPwdController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    newPwdController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .updatePassword(newPwdController.text);
        if (!mounted) return; // Check if the widget is still mounted
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Change Name'),
          actions: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: newPwdController,
              builder: (context, value, child) {
                return CupertinoButton(
                  onPressed: !_isLoading && newPwdController.text.isNotEmpty
                      ? _submit
                      : null,
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
                    top: 0),
                child: ListView(
                  children: [
                    const SizedBox(height: AppConstants.paddingSpacing),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            label: 'New Password',
                            controller: newPwdController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            obscureText: true,
                            focusNode: _focusNode,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.go(HomePageView.routeName);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) {
                            HomePageView.setInitialTab();
                            if (context.mounted) {
                              context.push(
                                  '${CommunityDetailsView.routeName}/4246e0b8-2a50-44d0-a104-22b7ab94e7fd');
                            }
                          },
                        );
                      },
                      child: Text('click me'),
                    )
                  ],
                ),
              ),
            ),
            if (_isLoading) const CustomProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class MultipleTextEditingControllerListener extends ValueNotifier<bool> {
  final List<TextEditingController> controllers;

  MultipleTextEditingControllerListener({required this.controllers})
      : super(false) {
    for (var controller in controllers) {
      controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() {
    // Notify listeners if any of the text fields are not empty.
    value = controllers.every((controller) => controller.text.isNotEmpty);
  }

  @override
  void dispose() {
    for (var controller in controllers) {
      controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }
}
