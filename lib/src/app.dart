import 'package:activator_app/src/features/profile/views/change_profile_view.dart';
import 'package:activator_app/src/features/profile/views/profile_theme_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/controllers/settings_controller.dart';
import 'features/HomePage/home_page_view.dart';

const Color primaryRed = Color(0xFFC62828);
const Color secondaryRed = Color(0xFFFFCDD2);
const Color errorRed = Color(0xFFD32F2F);

final ThemeData lightTheme = ThemeData(
  primarySwatch: Colors.red,
  colorScheme: ColorScheme(
    primary: primaryRed,
    secondary: secondaryRed,
    surface: Colors.grey.shade100,
    surfaceContainer: Colors.white,
    error: errorRed,
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.grey.shade900,
    onError: Colors.white,
    onSurfaceVariant: Colors.grey.shade600,
    shadow: Colors.grey.withOpacity(0.3),
    brightness: Brightness.light,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade100,
    scrolledUnderElevation: 0,
  ),
);
final ThemeData darkTheme = ThemeData(
  primarySwatch: Colors.red,
  colorScheme: ColorScheme(
    primary: primaryRed,
    secondary: secondaryRed,
    surface: Colors.grey.shade900,
    surfaceContainer: Colors.grey.shade800,
    error: errorRed,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onSurface: Colors.white,
    onError: Colors.black,
    onSurfaceVariant: Colors.grey.shade400,
    shadow: Colors.black.withOpacity(0.3),
    brightness: Brightness.dark,
  ),
  dividerColor: Colors.grey.shade600,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.grey.shade900,
    scrolledUnderElevation: 0,
  ),
);

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
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
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            routeBuilder(BuildContext context) {
              switch (routeSettings.name) {
                case ChangeProfileView.routeName:
                  return const ChangeProfileView();
                case ProfileThemeView.routeName:
                  return ProfileThemeView(controller: settingsController);
                default:
                  return const HomePageView();
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
        );
      },
    );
  }
}
