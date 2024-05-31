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
        backgroundColor: Theme.of(context).colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 0),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: 20),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
