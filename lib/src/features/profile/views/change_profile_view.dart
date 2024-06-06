import 'package:activator_app/src/core/provider/appwrite_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_input_field.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:activator_app/src/features/auth/views/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Displays input fields to change the user profile.
/// name and email fields are pre-filled with the current user's information.
/// The user can change the name and email fields and save the changes.
/// The user can also delete the account.
class ChangeProfileView extends StatelessWidget {
  const ChangeProfileView({
    super.key,
  });

  static const routeName = '/change-profile';

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(
              left: AppConstants.paddingSpacing,
              right: AppConstants.paddingSpacing,
              bottom: AppConstants.paddingSpacing,
              top: 0),
          children: <Widget>[
            const SizedBox(height: AppConstants.paddingSpacing),
            const CustomInputField(
              label: 'Full Name',
              initialValue: 'John Doe',
            ),
            const SizedBox(height: AppConstants.listTileSpacing),
            const CustomInputField(
              label: 'Email',
              initialValue: 'john.doe@example.com',
            ),
            const SizedBox(height: AppConstants.separatorSpacing),
            CustomListTile(
              text: 'Save Changes',
              onPressed: () => print('Save changes'),
              showArrow: false,
              textAlign: TextAlign.center,
              textColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: AppConstants.separatorSpacing * 2),
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
              onPressed: () => {
                authProvider.logoutUser(),
                Navigator.of(context).pushNamedAndRemoveUntil(
                  WelcomeView.routeName,
                  (route) => false,
                ),
              },
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
    );
  }
}
