import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangeEmailView extends StatefulWidget {
  const ChangeEmailView({
    super.key,
  });

  static const routeName = '/change-email';

  @override
  State<ChangeEmailView> createState() => _ChangeEmailViewState();
}

class _ChangeEmailViewState extends State<ChangeEmailView> {
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FocusNode _focusNode = FocusNode();
  bool _isLoading = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      User user = authProvider.user!;
      emailController.text = user.email!;
      _initialized = true;
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .updateEmail(emailController.text);
        if (!mounted) return; // Check if the widget is still mounted
        Navigator.pop(context);
        // show snackbar to make the use check their email for verification
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Please check your email for verification',
            ),
          ),
        );
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
              valueListenable: emailController,
              builder: (context, value, child) {
                return CupertinoButton(
                  onPressed: emailController.text ==
                              Provider.of<AuthProvider>(context, listen: false)
                                  .user!
                                  .email ||
                          _isLoading
                      ? null
                      : _submit,
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
                            label: 'Email',
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!EmailValidator.validate(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            focusNode: _focusNode,
                          ),
                          const SizedBox(
                              height: AppConstants.separatorSpacing / 2),
                          Text(
                            'You will receive an email to verify your new email address.',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
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
