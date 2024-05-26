import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:activator_app/src/features/profile/views/profile_theme_view.dart';
import 'package:activator_app/src/features/profile/widgets/profile_widget.dart';
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
          padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
          child: ListView(
            children: <Widget>[
              const ProfileWidget(),
              const SizedBox(height: 40),
              CustomListTile(
                text: "Privacy",
                onPressed: () => print('onPressed'),
              ),
              CustomListTile(
                text: "Theme Mode",
                onPressed: () => Navigator.of(context)
                    .restorablePushNamed(ProfileThemeView.routeName),
              ),
              const SizedBox(height: 20),
              CustomListTile(
                  text: "Share activator", onPressed: () => print('onPressed')),
              CustomListTile(
                  text: "Contact us", onPressed: () => print('onPressed')),
              CustomListTile(
                  text: "About", onPressed: () => print('onPressed')),
              const SizedBox(height: 20),
              CustomListTile(
                text: "Logout",
                onPressed: () => print('onPressed'),
                textColor: Theme.of(context).colorScheme.error,
                marginBottom: 0,
                showArrow: false,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
