import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/provider/connectivity_notifier.dart';
import 'package:activator_app/src/core/provider/db_provider.dart';
import 'package:activator_app/src/core/services/supabase_service.dart';
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
import 'package:activator_app/src/features/communities/views/edit_community_view.dart';
import 'package:activator_app/src/features/communities/views/invitation_view.dart';
import 'package:activator_app/src/features/initial/views/not_found_view.dart';
import 'package:activator_app/src/features/profile/views/change_email_view.dart';
import 'package:activator_app/src/features/profile/views/change_name_view.dart';
import 'package:activator_app/src/features/profile/views/change_password_view.dart';
import 'package:activator_app/src/features/profile/views/change_profile_view.dart';
import 'package:activator_app/src/features/profile/views/profile_theme_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/core/controllers/settings_controller.dart';
import 'src/core/services/settings_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: AppConstants.SUPABASE_URL,
    anonKey: AppConstants.SUPABASE_ANON_KEY,
  );

  // Set up the SettingsController
  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  // supabase service
  final supabaseService = SupabaseService();

  // Connectivity notifier
  final connectivityNotifier = ConnectivityNotifier();

  // Check user session
  final authProvider = AuthProvider(supabaseService);
  await authProvider.checkSession();

  final GoRouter router = GoRouter(
    errorBuilder: (context, state) => const NotFoundView(),
    initialLocation: authProvider.isAuthenticated
        ? HomePageView.routeName
        : WelcomeView.routeName,
    routes: [
      GoRoute(
        path: '/invite/:invitationToken',
        pageBuilder: (context, state) {
          final String? invitationToken =
              state.pathParameters['invitationToken'];
          return SlidePageTransition(
            direction: SlideDirection.bottomToTop,
            child: InvitationView(invitationToken: invitationToken),
          );
        },
      ),
      GoRoute(
        path: HomePageView.routeName,
        pageBuilder: (context, state) => PlatformTransitionPage(
          child: HomePageView(key: HomePageView.globalKey),
          isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
        ),
      ),
      GoRoute(
        path: WelcomeView.routeName,
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
        path: '${EditCommunityView.routeName}/:communityId',
        pageBuilder: (context, state) => PlatformTransitionPage(
          child: EditCommunityView(
            communityId: state.pathParameters['communityId']!,
          ),
          isCupertino: Theme.of(context).platform == TargetPlatform.iOS,
        ),
      ),
    ],
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<SupabaseService>(
          create: (_) => supabaseService,
          lazy: false,
        ),
        ChangeNotifierProvider(
          create: (_) => connectivityNotifier,
        ),
        ChangeNotifierProvider(
          create: (context) => authProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => DatabaseProvider(
            Provider.of<SupabaseService>(context, listen: false),
            Provider.of<AuthProvider>(context, listen: false),
            Provider.of<ConnectivityNotifier>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => settingsController,
        ),
      ],
      child: MyApp(router: router),
    ),
  );
}
