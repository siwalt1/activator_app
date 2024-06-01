import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Profile'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
          children: <Widget>[
            const SizedBox(height: 20),
            const _ProfileInputField(label: 'Full Name', initialValue: 'John Doe'),
            const SizedBox(height: AppConstants.listTileSpacing),
            const _ProfileInputField(
              label: 'Email',
              initialValue: 'john.doe@example.com',
            ),
            const SizedBox(height: 20),
            CustomListTile(
              text: 'Save Changes',
              onPressed: () => print('Save changes'),
              showArrow: false,
              textAlign: TextAlign.center,
              textColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 40),
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
              onPressed: () => print('Change profile picture'),
              showArrow: false,
              textAlign: TextAlign.center,
              textColor: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 20),
            CustomListTile(
              text: 'Delete Account',
              onPressed: () => print('Delete account'),
              showArrow: false,
              textAlign: TextAlign.center,
              textColor: Theme.of(context).colorScheme.onError,
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget {
   const _ProfileInputField({
    required this.label,
    required this.initialValue,
  });

  final String label;
  final String initialValue;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow,
            spreadRadius: 0.1,
            blurRadius: 0.2,
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          border: InputBorder.none,
        ),
        controller: TextEditingController(text: initialValue),
      ),
    );
  }
}
