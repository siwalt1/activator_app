import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_list_tile.dart';
import 'package:activator_app/src/features/profile/views/profile_theme_view.dart';
import 'package:activator_app/src/features/profile/widgets/profile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(
                left: AppConstants.paddingSpacing,
                right: AppConstants.paddingSpacing,
                bottom: AppConstants.paddingSpacing,
                top: 0),
            child: ListView(
              children: <Widget>[
                const SizedBox(height: AppConstants.paddingSpacing),
                const ProfileWidget(),
                const SizedBox(height: AppConstants.separatorSpacing * 2),
                CustomListTile(
                  text: "Theme Mode",
                  onPressed: () => context.push(ProfileThemeView.routeName),
                  marginBottom: AppConstants.listTileSpacing,
                ),
                CustomListTile(
                  text: 'Notifications',
                  onPressed: () => print('onPressed'),
                  marginBottom: AppConstants.listTileSpacing,
                ),
                const SizedBox(height: AppConstants.separatorSpacing),
                CustomListTile(
                  text: "Share activator",
                  onPressed: () => Share.share(
                      'Check out the activator app at https://open.activator-app.walter-wm.de/'),
                  marginBottom: AppConstants.listTileSpacing,
                ),
                CustomListTile(
                  text: "Contact us",
                  onPressed: () => launchUrl(
                    Uri(
                      scheme: 'mailto',
                      path: 'info@activator-app.walter-wm.de',
                    ),
                  ),
                  marginBottom: AppConstants.listTileSpacing,
                ),
                CustomListTile(
                  text: "Privacy",
                  onPressed: () => print('onPressed'),
                  marginBottom: AppConstants.listTileSpacing,
                ),
                CustomListTile(
                  text: "About",
                  onPressed: () => print('onPressed'),
                  marginBottom: AppConstants.listTileSpacing,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
