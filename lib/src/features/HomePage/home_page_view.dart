import 'package:activator_app/src/features/communities/views/communities_view.dart';
import 'package:activator_app/src/features/profile/views/profile_view.dart';
import 'package:flutter/material.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  static const routeName = '/home';

  static final globalKey = GlobalKey<_HomePageViewState>();

  static void setInitialTab() {
    globalKey.currentState?.setInitialTab();
  }

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  int _selectedTab = 0;

  final List _pages = const [
    CommunitiesView(),
    ProfileView(),
  ];

  _changeTab(int index) {
    setState(() {
      _selectedTab = index;
    });
  }

  setInitialTab() {
    setState(() {
      _selectedTab = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedTab],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(height: 0.2, thickness: 0.2),
            BottomNavigationBar(
              currentIndex: _selectedTab,
              onTap: (index) => _changeTab(index),
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Theme.of(context).colorScheme.onSurface,
              elevation: 10,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.groups),
                  label: 'Communities',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
