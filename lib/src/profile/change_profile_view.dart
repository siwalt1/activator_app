import 'package:flutter/material.dart';

/// Displays input fields to change the user profile.
/// name and email fields are pre-filled with the current user's information.
/// The user can change the name and email fields and save the changes.
/// The user can also delete the account.
class ChangeProfileView extends StatelessWidget {
  const ChangeProfileView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/change-profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const SizedBox(height: 20),
          const _ProfileInputField(label: 'Name', initialValue: 'John Doe'),
          const SizedBox(height: 20),
          const _ProfileInputField(
            label: 'Email',
            initialValue: 'john.doe@example.com',
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => print('Save changes'),
            child: const Text('Save Changes'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => print('Delete account'),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(Colors.red),
            ),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget{
  const _ProfileInputField({
    required this.label,
    required this.initialValue,
  });

  final label;
  final initialValue;

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      controller: TextEditingController(text: initialValue),
    );
  }
}
