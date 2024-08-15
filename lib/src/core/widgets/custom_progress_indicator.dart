import 'package:flutter/material.dart';

class CustomProgressIndicator extends StatelessWidget {
  const CustomProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(const Duration(seconds: 1)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: double.infinity,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          );
        } else {
          return Container(
            height: double.infinity,
            width: double.infinity,
            color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
