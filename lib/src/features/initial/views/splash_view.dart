import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:activator_app/src/features/auth/views/welcome_view.dart';
import 'package:activator_app/src/features/communities/views/invitation_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key, this.invitationToken});

  final String? invitationToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future:
            Provider.of<AuthProvider>(context, listen: false).checkSession(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashWidget();
          } else {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) {
                if (Provider.of<AuthProvider>(context, listen: false)
                    .isAuthenticated) {
                  if (invitationToken != null) {
                    context.go(
                      '${InvitationView.routeName}/$invitationToken',
                    );
                  } else {
                    context.go(HomePageView.routeName);
                  }
                } else {
                  context.go(WelcomeView.routeName);
                }
              },
            );
            return const SplashWidget();
          }
        },
      ),
    );
  }
}

class SplashWidget extends StatelessWidget {
  const SplashWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
        ),
        const Center(
          child: Image(
            image: AssetImage(
              'assets/images/rocket.png',
            ),
            width: 150,
            height: 150,
          ),
        )
      ],
    );
  }
}
