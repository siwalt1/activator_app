import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:activator_app/src/core/widgets/custom_button.dart';
import 'package:activator_app/src/core/widgets/custom_progress_indicator.dart';
import 'package:activator_app/src/features/HomePage/home_page_view.dart';
import 'package:activator_app/src/features/auth/views/login_view.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class SignupView extends StatefulWidget {
  const SignupView({
    super.key,
  });

  static const routeName = '/signup';

  @override
  State<SignupView> createState() => _SignupViewState();
}

class _SignupViewState extends State<SignupView> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false; // Track sign-up status

  Future<void> _signup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        await authProvider.registerUser(
          emailController.text,
          passwordController.text,
          nameController.text,
        );
        if (!mounted) return; // Check if the widget is still mounted
        context.replace(HomePageView.routeName);
      } catch (e) {
        // Show an error message if registration fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
        print('Registration failed: $e');
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
                                'Welcome!',
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
                                'Sign up to get started.',
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
                                labelText: 'Full Name',
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
                              keyboardType: TextInputType.name,
                              obscureText: false,
                              controller: nameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your full name';
                                }
                                if (value != value.trimRight()) {
                                  return 'Name should not end with spaces';
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
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              style: TextStyle(
                                color: AppConstants
                                    .darkTheme.colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(height: 70),
                            CustomButton(
                              text: 'Sign up',
                              onPressed: _signup,
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
                              text: 'Log in',
                              onPressed: () =>
                                  context.replace(LoginView.routeName),
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
