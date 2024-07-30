import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/features/auth/views/login_view.dart';
import 'package:activator_app/src/features/auth/views/signup_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  static const routeName = '/welcome';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Image(
            image: AssetImage(
                MediaQuery.of(context).platformBrightness == Brightness.light
                    ? 'assets/images/space_bg_light.jpg'
                    : 'assets/images/space_bg.jpg'),
            fit: BoxFit.cover,
            height: double.infinity,
            width: double.infinity,
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                title: Row(
                  children: [
                    Image.asset(
                      'assets/images/rocket.png',
                      height: 30,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'activator',
                      style: TextStyle(),
                    ),
                  ],
                ),
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
                                color: AppConstants
                                    .darkTheme.colorScheme.onPrimary,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          const SizedBox(height: 30),
                          CustomButton(
                            text: 'Log in',
                            onPressed: () =>
                                context.replace(LoginView.routeName),
                            color: AppConstants.darkTheme.colorScheme.primary,
                            textColor:
                                AppConstants.darkTheme.colorScheme.onPrimary,
                          ),
                          const SizedBox(height: 10),
                          CustomButton(
                            text: 'Sign up',
                            onPressed: () =>
                                context.replace(SignupView.routeName),
                            color: AppConstants
                                .darkTheme.colorScheme.surfaceContainer,
                            textColor:
                                AppConstants.darkTheme.colorScheme.onPrimary,
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
