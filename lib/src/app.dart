import 'package:activator_app/src/core/provider/connectivity_notifier.dart';
import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/controllers/settings_controller.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.router,
  });

  final GoRouter router;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Provider.of<SettingsController>(context);
    final double topPadding = MediaQuery.of(context).padding.top;

    return Consumer2<SettingsController, ConnectivityNotifier>(
      builder: (BuildContext context, SettingsController value,
          ConnectivityNotifier connectivity, Widget? child) {
        if (connectivity.isConnected) {
          _controller.reverse();
        } else {
          _controller.forward();
        }

        return MaterialApp.router(
          routerDelegate: widget.router.routerDelegate,
          routeInformationParser: widget.router.routeInformationParser,
          routeInformationProvider: widget.router.routeInformationProvider,
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
          builder: (context, child) {
            return Scaffold(
              body: Stack(
                children: [
                  child!,
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Positioned(
                        top: -50 -
                            topPadding +
                            _animation.value * (topPadding + 50),
                        left: 0,
                        right: 0,
                        child: Container(
                          color: Theme.of(context).colorScheme.error,
                          child: SafeArea(
                            child: Container(
                              color: Theme.of(context).colorScheme.error,
                              padding: const EdgeInsets.all(12.0),
                              child: const Text(
                                'You are offline',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
