import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  final messageController = TextEditingController();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void sendMessage() async {
    final enteredMessage = messageController.text;

    print(enteredMessage);

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    FocusScope.of(context).unfocus();
    messageController.clear();

    var user = FirebaseAuth.instance.currentUser;

    final userInfo = await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .get();

    await FirebaseFirestore.instance.collection("chat").add({
      "text": enteredMessage,
      "createdAt": Timestamp.now(),
      "userId": user?.uid,
      "username": userInfo["username"],
      "userImage": userInfo["image_url"] ?? "",
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: TextField(
            controller: messageController,
            decoration: const InputDecoration(
              labelText: 'Send a message...',
            ),
            textCapitalization: TextCapitalization.sentences,
            autocorrect: true,
            enableSuggestions: true,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
          child: IconButton(
            icon: const Icon(Icons.send),
            onPressed: sendMessage,
          ),
        ),
      ],
    );
  }
}
