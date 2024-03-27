import 'package:activator_app/src/profile/change_profile_view.dart';
import 'package:flutter/material.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: const CircleAvatar(
          radius: 50,
          backgroundColor: Colors.white,
          child: Icon(Icons.person, size: 50),
        ),
        title: Text('John Doe', style: TextStyle(fontSize: 24)),
        subtitle: Text('john.doe@example.com'),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.black,
        ),
        // onTap navigation to ChangeProfileView
        // onTap: () => Navigator.of(context).pushNamed('/change-profile'),
        onTap: () => Navigator.of(context).restorablePushNamed(ChangeProfileView.routeName), 
      )
    );
  }
}