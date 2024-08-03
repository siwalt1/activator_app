import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChangeNameView extends StatefulWidget {
  const ChangeNameView({
    super.key,
  });

  static const routeName = '/change-name';

  @override
  State<ChangeNameView> createState() => _ChangeNameViewState();
}

class _ChangeNameViewState extends State<ChangeNameView> {
  final controller = TextEditingController();
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
    controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      User? user = authProvider.user;
      controller.text = user?.userMetadata?['display_name'];
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
            .updateName(controller.text);
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
              valueListenable: controller,
              builder: (context, value, child) {
                return CupertinoButton(
                  onPressed: controller.text ==
                              Provider.of<AuthProvider>(context, listen: false)
                                  .user?.userMetadata?['display_name'] ||
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  top: 0,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: CustomTextFormField(
                        label: 'Full Name',
                        controller: controller,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value != value.trimRight()) {
                            return 'Name should not end with spaces';
                          }
                          return null;
                        },
                        focusNode: _focusNode,
                      ),
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
