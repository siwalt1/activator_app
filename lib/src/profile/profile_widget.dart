import 'package:activator_app/src/profile/change_profile_view.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Ink(
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
        leading: CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
          child: const Icon(
            Icons.person,
            size: 50,
          ),
        ),
        title: const Text('John Doe', style: TextStyle(fontSize: 24)),
        subtitle: const Text('john.doe@example.com'),
        // onTap navigation to ChangeProfileView
        onTap: () => Navigator.of(context)
            .restorablePushNamed(ChangeProfileView.routeName),
      ),
    );
  }
}
