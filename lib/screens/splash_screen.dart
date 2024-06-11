import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: CircularProgressIndicator(),
        ));
  }
}
