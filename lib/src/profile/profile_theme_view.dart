import 'package:flutter/material.dart';

import 'package:activator_app/src/settings/settings_controller.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _buildListItem(index);
          },
        ),
      ),
    );
  }

  Widget _buildListItem(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        selected: _selectedIndex == index,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            width: 0.75,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        visualDensity: const VisualDensity(vertical: -3),
        title: Text(
          items[index],
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        trailing: Visibility(
          visible: _selectedIndex == index,
          child: const Icon(
            Icons.check,
            color: Colors.blue,
          ),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
            widget.controller.updateThemeMode(themeModes[index]);
          });
        },
      ),
    );
  }
}
