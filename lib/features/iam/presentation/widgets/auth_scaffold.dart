import 'package:flutter/material.dart';

class AuthScaffold extends StatelessWidget {
  final Widget child;

  const AuthScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          color: Theme.of(
            context,
          ).colorScheme.surface, // This maps to our Theme.of(context).colorScheme.surface
          width: double.infinity,
          height: double.infinity,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 80,
              left: 24,
              right: 24,
              bottom: 24,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
