import 'package:activator_app/src/core/utils/constants.dart';
import 'package:flutter/material.dart';

import 'package:activator_app/src/core/controllers/settings_controller.dart';

class ProfileThemeView extends StatefulWidget {
  const ProfileThemeView({super.key, required this.controller});

  static const routeName = '/profile-theme';

  final SettingsController controller;

  @override
  State<ProfileThemeView> createState() => _ProfileThemeViewState();
}

class _ProfileThemeViewState extends State<ProfileThemeView> {
  final List<String> items = [
    'System Theme',
    'Light Theme',
    'Dark Theme'
  ]; // List of options
  final List<ThemeMode> themeModes = [
    ThemeMode.system,
    ThemeMode.light,
    ThemeMode.dark
  ]; // List of theme modes

  late int
      _selectedIndex; // Variable to store the index of the selected theme mode

  @override
  void initState() {
    super.initState();
    _selectedIndex = themeModes.indexOf(
        widget.controller.themeMode); // Get the index of the current theme mode
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Mode'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
              left: AppConstants.paddingSpacing,
              right: AppConstants.paddingSpacing,
              bottom: AppConstants.paddingSpacing,
              top: 0),
          child: ListView(
            children: <Widget>[
              const SizedBox(height: AppConstants.paddingSpacing),
              ...List.generate(items.length, (index) => _buildListItem(index)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Container(
      margin: EdgeInsets.only(
        bottom: index != items.length - 1 ? AppConstants.listTileSpacing : 0,
      ),
      child: Ink(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow, // Shadow color
              spreadRadius: 0.1, // Spread radius
              blurRadius: 0.2, // Blur radius
            ),
          ],
        ),
        child: ListTile(
          tileColor: Theme.of(context).colorScheme.surfaceContainer,
          selectedTileColor: Theme.of(context).colorScheme.surfaceContainer,
          selectedColor: Theme.of(context).colorScheme.onSurface,
          selected: _selectedIndex == index,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          visualDensity: const VisualDensity(vertical: -3),
          title: Text(
            items[index],
          ),
          trailing: Visibility(
            visible: _selectedIndex == index,
            child: Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onTap: () {
            setState(() {
              _selectedIndex = index;
              widget.controller.updateThemeMode(themeModes[index]);
            });
          },
        ),
      ),
    );
  }
}
