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
          padding: const EdgeInsets.all(16.0),
          child: const Column(
            children: <Widget>[
              ProfileWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
