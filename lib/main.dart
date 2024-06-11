import 'package:chat_app/screens/auth_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: const AuthScreen(),
    theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green.shade200)),
  ));
}
