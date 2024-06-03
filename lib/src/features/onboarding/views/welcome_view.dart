import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/slide_direction.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/slide_route.dart';
import 'package:activator_app/src/features/onboarding/views/login_view.dart';
import 'package:activator_app/src/features/onboarding/views/signup_view.dart';
import 'package:flutter/material.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const Image(
            image: AssetImage('assets/images/welcome.png'),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: const Text('activator'),
                centerTitle: false,
                foregroundColor: AppConstants.darkTheme.colorScheme.onPrimary,
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Welcome to Activator',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppConstants
                                    .darkTheme.colorScheme.onPrimary,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'The best way to activate your life.',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppConstants.darkTheme.colorScheme.onPrimary,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            text: 'Log in',
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                SlideRoute(
                                  page: const LoginView(),
                                  direction: SlideDirection.bottomToTop,
                                ),
                              );
                            },
                            color: AppConstants.darkTheme.colorScheme.primary,
                            textColor: AppConstants.darkTheme.colorScheme.onPrimary,
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: 'Sign up',
                            onPressed: () {
                              Navigator.pushReplacement(
                                context,
                                SlideRoute(
                                  page: const SignupView(),
                                  direction: SlideDirection.topToBottom,
                                ),
                              );
                            },
                            color: AppConstants.darkTheme.colorScheme.surfaceContainer,
                            textColor: AppConstants.darkTheme.colorScheme.onPrimary,
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
