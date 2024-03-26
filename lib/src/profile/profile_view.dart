import 'package:activator_app/src/profile/profile_list_item.dart';
import 'package:activator_app/src/profile/profile_widget.dart';
import 'package:flutter/material.dart';

/// Displays the user profile information.
class ProfileView extends StatelessWidget {
  const ProfileView({
    super.key,
  });

  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: ListView(
            children: <Widget>[
              const ProfileWidget(),
              const SizedBox(height: 40),
              ProfileListItem(
                  text: "Change Password",
                  onPressed: () => print('onPressed'),
                  marginBottom: 4),
              ProfileListItem(
                text: "Logout",
                onPressed: () => print('onPressed'),
                marginBottom: 4,
              ),
              const SizedBox(height: 20),
              ProfileListItem(
                text: "Delete Account",
                onPressed: () => print('onPressed'),
                color: Colors.red,
                marginBottom: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
