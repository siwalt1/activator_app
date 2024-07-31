import 'package:flutter/material.dart';

class InvitationView extends StatelessWidget {
  final String? invitationToken;

  const InvitationView({super.key, this.invitationToken});

  static const routeName = '/invitation';

  @override
  Widget build(BuildContext context) {
    // You can use the invitationToken to fetch details from the server
    // and display them on this screen.

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Community'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Invitation Token: $invitationToken',
              style: const TextStyle(fontSize: 24),
            ),
            // Additional UI for joining the community
          ],
        ),
      ),
    );
  }
}
