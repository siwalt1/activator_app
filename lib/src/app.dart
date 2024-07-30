import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:activator_app/src/features/auth/views/welcome_view.dart';
import 'package:activator_app/src/features/communities/views/community_details_view.dart';
import 'package:activator_app/src/features/communities/views/community_settings_view.dart';
import 'package:activator_app/src/features/initial/views/not_found_view.dart';
import 'package:activator_app/src/features/initial/views/splash_view.dart';
import 'package:activator_app/src/features/profile/views/change_email_view.dart';
import 'package:activator_app/src/features/profile/views/change_name_view.dart';
import 'package:activator_app/src/features/profile/views/change_password_view.dart';
import 'package:activator_app/src/features/profile/views/change_profile_view.dart';
import 'package:activator_app/src/features/profile/views/profile_theme_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/controllers/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);

    return MaterialApp(
      // Providing a restorationScopeId allows the Navigator built by the
      // MaterialApp to restore the navigation stack when a user leaves and
      // returns to the app after it has been killed while running in the
      // background.
      restorationScopeId: 'app',

      // Provide the generated AppLocalizations to the MaterialApp. This
      // allows descendant Widgets to display the correct translations
      // depending on the user's locale.
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English, no country code
      ],

      // Use AppLocalizations to configure the correct application title
      // depending on the user's locale.
      //
      // The appTitle is defined in .arb files found in the localization
      // directory.
      onGenerateTitle: (BuildContext context) =>
          AppLocalizations.of(context)!.appTitle,

      // Define a light and dark color theme. Then, read the user's
      // preferred ThemeMode (light, dark, or system default) from the
      // SettingsController to display the correct theme.
      theme: AppConstants.lightTheme,
      darkTheme: AppConstants.darkTheme,
      themeMode: settingsController.themeMode,

      // Define a function to handle named routes in order to support
      // Flutter web url navigation and deep linking.
      onGenerateRoute: (RouteSettings routeSettings) {
        Widget routeBuilder(BuildContext context) {
          final arguments = routeSettings.arguments as Map<String, dynamic>?;
          switch (routeSettings.name) {
            case WelcomeView.routeName:
              return const WelcomeView();
            case CommunitySettingsView.routeName:
              return CommunitySettingsView(
                communityId: arguments?['communityId'],
              );
            case CommunityDetailsView.routeName:
              return CommunityDetailsView(
                communityId: arguments?['communityId'],
              );
            case ChangeEmailView.routeName:
              return const ChangeEmailView();
            case ChangePasswordView.routeName:
              return const ChangePasswordView();
            case ChangeNameView.routeName:
              return const ChangeNameView();
            case ChangeProfileView.routeName:
              return const ChangeProfileView();
            case ProfileThemeView.routeName:
              return const ProfileThemeView();
            case HomePageView.routeName:
              return const HomePageView();
            default:
              return const NotFoundView();
          }
        }

        if (Theme.of(context).platform == TargetPlatform.iOS) {
          return CupertinoPageRoute<void>(
            settings: routeSettings,
            builder: routeBuilder,
          );
        } else {
          return MaterialPageRoute<void>(
            settings: routeSettings,
            builder: routeBuilder,
          );
        }
      },
      home: const SplashView(),
    );
  }
}
