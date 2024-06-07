import 'package:activator_app/src/core/provider/appwrite_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/slide_direction.dart';
import 'package:activator_app/src/core/widgets/custom_input_field.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/slide_route.dart';
import 'package:activator_app/src/features/auth/views/welcome_view.dart';
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
  bool _isLoading = false;

  Future<void> _logoutAndNavigate() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      setState(() {
        _isLoading = true;
      });
      await authProvider.logoutUser();
      if (!mounted) return; // Check if the widget is still mounted
      Navigator.pushReplacement(
        context,
        SlideRoute(
          page: const WelcomeView(),
          direction: SlideDirection.leftToRight,
        ),
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
                  onPressed: _logoutAndNavigate,
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
            if(_isLoading) const CustomProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
