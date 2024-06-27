import 'package:activator_app/src/core/provider/appwrite_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({
    super.key,
  });

  static const routeName = '/change_value';

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final oldPwdController = TextEditingController();
  final newPwdController = TextEditingController();
  final newPwdCheckController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  late MultipleTextEditingControllerListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = MultipleTextEditingControllerListener(
      controllers: [oldPwdController, newPwdController, newPwdCheckController],
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _listener.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .updatePassword(newPwdController.text, oldPwdController.text);
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
            ValueListenableBuilder<bool>(
              valueListenable: _listener,
              builder: (context, value, child) {
                return CupertinoButton(
                  onPressed: !_isLoading &&
                          oldPwdController.text.isNotEmpty &&
                          newPwdController.text.isNotEmpty &&
                          newPwdCheckController.text.isNotEmpty
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  top: 0,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: AppConstants.paddingSpacing),
                      CustomTextFormField(
                        label: 'Current Password',
                        controller: oldPwdController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                      const SizedBox(height: AppConstants.listTileSpacing),
                      CustomTextFormField(
                        label: 'New Password',
                        controller: newPwdController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                      const SizedBox(height: AppConstants.listTileSpacing),
                      CustomTextFormField(
                        label: 'Confirm Password',
                        controller: newPwdCheckController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != newPwdController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        obscureText: true,
                      ),
                    ],
                  ),
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
