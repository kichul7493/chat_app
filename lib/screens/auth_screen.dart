import 'dart:io';

import 'package:chat_app/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLogin = true;
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  File? selectedImage;

  void changeMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void pickImage(File pickedImage) {
    selectedImage = pickedImage;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void submit() async {
      final isValid = formKey.currentState!.validate();
      if (!isValid) {
        return;
      }

      if (isLogin) {
        try {
          final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

          print(userCredential.user?.email);
        } on FirebaseAuthException catch (error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.message ?? 'An error occurred'),
          ));
        }
      } else {
        if (selectedImage == null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Please pick an image'),
          ));
          return;
        }

        try {
          final userCredential =
              await _firebaseAuth.createUserWithEmailAndPassword(
                  email: emailController.text,
                  password: passwordController.text);

          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_images')
              .child('${userCredential.user!.uid}.jpg');

          await storageRef.putFile(selectedImage!);
          final imageUrl = await storageRef.getDownloadURL();

          final database = FirebaseFirestore.instance;

          await database.collection('users').doc(userCredential.user!.uid).set({
            'username': usernameController.text,
            'email': emailController.text,
            'image_url': imageUrl,
          });
        } on FirebaseAuthException catch (error) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(error.message ?? 'An error occurred'),
          ));
        }
      }
    }

    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.chat, size: 100, color: Colors.white),
              const SizedBox(
                height: 48,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      if (!isLogin)
                        UserImagePicker(
                          onImagePick: pickImage,
                        ),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        autocorrect: false,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                        controller: emailController,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      if (!isLogin)
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty ||
                                value.length < 2) {
                              return 'Username must be at least 2 characters long';
                            }
                            return null;
                          },
                          enableSuggestions: false,
                          controller: usernameController,
                        ),
                      if (!isLogin) const SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          labelStyle: TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                        obscureText: true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                        controller: passwordController,
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      ElevatedButton(
                          onPressed: submit,
                          child: Text(isLogin ? 'Login' : 'Sign Up')),
                      const SizedBox(
                        width: 16,
                      ),
                      TextButton(
                        onPressed: changeMode,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isLogin
                            ? "Create new account"
                            : "I already have an account"),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
