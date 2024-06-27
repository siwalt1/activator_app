import 'package:activator_app/src/core/provider/appwrite_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/utils/slide_direction.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/core/widgets/slide_route.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:activator_app/src/features/auth/views/signup_view.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      try {
        await authProvider.loginUser(
          emailController.text,
          passwordController.text,
        );
        if (!mounted) return; // Check if the widget is still mounted
        Navigator.pushReplacement(
          context,
          SlideRoute(
            page: const HomePageView(),
            direction: SlideDirection.rightToLeft,
          ),
        );
      } catch (e) {
        // Handle login failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: $e')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

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
                foregroundColor: AppConstants.darkTheme.colorScheme.onSurface,
              ),
              Expanded(
                child: Align(
                  alignment: FractionalOffset.bottomCenter,
                  child: SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.only(
                        left: AppConstants.paddingSpacing,
                        right: AppConstants.paddingSpacing,
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        top: 0,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Text(
                                'Welcome back!',
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
                                'Log in to continue.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppConstants
                                      .darkTheme.colorScheme.onPrimary,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            const SizedBox(height: 30),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Email',
                                labelStyle: TextStyle(
                                    color: AppConstants
                                        .darkTheme.colorScheme.onPrimary),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppConstants
                                          .darkTheme.colorScheme.onPrimary),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppConstants
                                          .darkTheme.colorScheme.onPrimary),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              obscureText: false,
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!EmailValidator.validate(value)) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                              style: TextStyle(
                                color: AppConstants
                                    .darkTheme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              decoration: InputDecoration(
                                labelText: 'Password',
                                labelStyle: TextStyle(
                                    color: AppConstants
                                        .darkTheme.colorScheme.onPrimary),
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppConstants
                                          .darkTheme.colorScheme.onPrimary),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppConstants
                                          .darkTheme.colorScheme.onPrimary),
                                ),
                              ),
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: true,
                              controller: passwordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 8) {
                                  return 'Password must be at least 8 characters';
                                }
                                return null;
                              },
                              style: TextStyle(
                                color: AppConstants
                                    .darkTheme.colorScheme.onPrimary,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => print('Reset password'),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    color: AppConstants
                                        .darkTheme.colorScheme.onPrimary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 40),
                            CustomButton(
                              text: 'Log in',
                              onPressed: _login,
                              color: AppConstants.darkTheme.colorScheme.primary,
                              textColor:
                                  AppConstants.darkTheme.colorScheme.onPrimary,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppConstants
                                        .darkTheme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'or',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppConstants
                                        .darkTheme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    height: 1,
                                    color: AppConstants
                                        .darkTheme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            CustomButton(
                              text: 'Sign up',
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  SlideRoute(
                                    page: const SignupView(),
                                    direction: SlideDirection.leftToRight,
                                  ),
                                );
                              },
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
              ),
            ],
          ),
          if (_isLoading) const CustomProgressIndicator(),
        ],
      ),
    );
  }
}
