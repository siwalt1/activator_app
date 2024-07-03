import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:activator_app/src/features/auth/views/welcome_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

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
                  Navigator.of(context)
                      .pushReplacementNamed(HomePageView.routeName);
                } else {
                  Navigator.of(context)
                      .pushReplacementNamed(WelcomeView.routeName);
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
    return Container(
      color: Colors.transparent,
      width: double.infinity,
      height: double.infinity,
    );
  }
}
