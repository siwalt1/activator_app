import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/slide_direction.dart';
import 'package:activator_app/src/core/widgets/platform_transition_page.dart';
import 'package:activator_app/src/core/widgets/slide_route.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:activator_app/src/features/auth/views/login_view.dart';
import 'package:activator_app/src/features/auth/views/signup_view.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
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

    final GoRouter router = GoRouter(
      errorBuilder: (context, state) => const NotFoundView(),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: const SplashView(),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
        GoRoute(
          path: '/welcome',
          pageBuilder: (context, state) => SlidePageTransition(
            direction: SlideDirection.leftToRight,
            child: const WelcomeView(),
          ),
        ),
        GoRoute(
          path: LoginView.routeName,
          pageBuilder: (context, state) => SlidePageTransition(
            direction: SlideDirection.rightToLeft,
            child: const LoginView(),
          ),
        ),
        GoRoute(
          path: SignupView.routeName,
          pageBuilder: (context, state) => SlidePageTransition(
            direction: SlideDirection.leftToRight,
            child: const SignupView(),
          ),
        ),
        GoRoute(
          path: '${CommunitySettingsView.routeName}/:communityId',
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: CommunitySettingsView(
              communityId: state.pathParameters['communityId']!,
            ),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
        GoRoute(
          path: '${CommunityDetailsView.routeName}/:communityId',
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: CommunityDetailsView(
              communityId: state.pathParameters['communityId']!,
            ),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
        GoRoute(
          path: ChangeEmailView.routeName,
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: const ChangeEmailView(),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
        GoRoute(
          path: ChangePasswordView.routeName,
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: const ChangePasswordView(),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
        GoRoute(
          path: ChangeNameView.routeName,
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: const ChangeNameView(),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
        GoRoute(
          path: ChangeProfileView.routeName,
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: const ChangeProfileView(),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
        GoRoute(
          path: ProfileThemeView.routeName,
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: const ProfileThemeView(),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
        GoRoute(
          path: HomePageView.routeName,
          pageBuilder: (context, state) => PlatformTransitionPage(
            child: const HomePageView(),
            isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
          ),
        ),
      ],
    );

    return MaterialApp.router(
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
      ],
      theme: AppConstants.lightTheme,
      darkTheme: AppConstants.darkTheme,
      themeMode: settingsController.themeMode,
    );
  }
}
