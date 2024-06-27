import 'dart:io';

import 'package:activator_app/src/core/provider/appwrite_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/slide_direction.dart';
import 'package:activator_app/src/features/profile/views/change_email_view.dart';
import 'package:activator_app/src/features/profile/views/change_name_view.dart';
import 'package:activator_app/src/core/widgets/custom_text_form_field.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/slide_route.dart';
import 'package:activator_app/src/features/auth/views/welcome_view.dart';
import 'package:appwrite/models.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays input fields to change the user profile.
/// name and email fields are pre-filled with the current user's information.
/// The user can change the name and email fields and save the changes.
/// The user can also delete the account.
class ChangeProfileView extends StatefulWidget {
  const ChangeProfileView({
    super.key,
  });

  static const routeName = '/change-profile';

  @override
  State<ChangeProfileView> createState() => _ChangeProfileViewState();
}

class _ChangeProfileViewState extends State<ChangeProfileView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _logoutAndNavigate(AuthProvider authProvider) async {
    try {
      setState(() {
        _isLoading = true;
      });
      await authProvider.logoutUser();
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.pushAndRemoveUntil(
        context,
        SlideRoute(
          page: const WelcomeView(),
          direction: SlideDirection.leftToRight,
        ),
        (Route<dynamic> route) => false, // Remove all previous routes
      );
    } catch (e) {
      if (!mounted) return; // Check if the widget is still mounted
      // Handle the offline scenario or other errors
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Logout failed. Please check your internet connection and try again.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: true);
    final User? user = authProvider.user;

    if (user == null) return Container();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Profile'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.only(
                  left: AppConstants.paddingSpacing,
                  right: AppConstants.paddingSpacing,
                  bottom: AppConstants.paddingSpacing,
                  top: 0),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      const SizedBox(height: AppConstants.paddingSpacing),
                      CustomListTile(
                        text: user.name,
                        showArrow: true,
                        onPressed: () {
                          Widget changeNameView = const ChangeNameView();
                          Navigator.of(context).push(
                            Platform.isIOS
                                ? CupertinoPageRoute(
                                    builder: (context) => changeNameView,
                                  )
                                : MaterialPageRoute(
                                    builder: (context) => changeNameView,
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: AppConstants.listTileSpacing),
                      CustomListTile(
                        text: user.email,
                        showArrow: true,
                        onPressed: () {
                          Widget changeNameView = const ChangeEmailView();
                          Navigator.of(context).push(
                            Platform.isIOS
                                ? CupertinoPageRoute(
                                    builder: (context) => changeNameView,
                                  )
                                : MaterialPageRoute(
                                    builder: (context) => changeNameView,
                                  ),
                          );
                        },
                      ),
                      const SizedBox(height: AppConstants.separatorSpacing),
                      CustomListTile(
                        text: 'Change Password',
                        onPressed: () => print('Change password'),
                        showArrow: false,
                        textAlign: TextAlign.center,
                        textColor: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: AppConstants.listTileSpacing),
                      CustomListTile(
                        text: 'Logout',
                        onPressed: () => _logoutAndNavigate(authProvider),
                        showArrow: false,
                        textAlign: TextAlign.center,
                        textColor: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(height: AppConstants.separatorSpacing),
                      CustomListTile(
                        text: 'Delete Account',
                        onPressed: () => print('Delete account'),
                        showArrow: false,
                        textAlign: TextAlign.center,
                        textColor: Theme.of(context).colorScheme.onPrimary,
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_isLoading) const CustomProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
