import 'package:activator_app/src/core/provider/auth_provider.dart';
import 'package:activator_app/src/features/profile/views/change_profile_view.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:appwrite/models.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;

    if (user == null) return Container();

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
        title: Text(
          user.name,
          style: const TextStyle(fontSize: 24),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          user.email,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const SizedBox(),
        onTap: () => context.push(ChangeProfileView.routeName),
      ),
    );
  }
}
