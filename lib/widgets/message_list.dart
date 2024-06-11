import 'package:chat_app/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("chat")
            .orderBy(
              "createdAt",
              descending: true,
            )
            .snapshots(),
        builder: (ctx, chatSnapshot) {
          if (chatSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final chatDocs = chatSnapshot.data?.docs;

          if (chatDocs == null || chatDocs.isEmpty) {
            return const Center(child: Text("No messages yet!"));
          }

          return ListView.builder(
              itemCount: chatDocs.length,
              reverse: true,
              itemBuilder: (ctx, index) {
                final chatMessage = chatDocs[index].data();
                final nextChatMessage = index + 1 < chatDocs.length
                    ? chatDocs[index + 1].data()
                    : null;

                final currentMessageUserId = chatMessage["userId"];
                final nextMessageUserId =
                    nextChatMessage != null ? nextChatMessage["userId"] : null;

                final nextUserIsSame =
                    nextMessageUserId == currentMessageUserId;

                if (nextUserIsSame) {
                  return MessageBubble.next(
                    message: chatMessage["text"],
                    isMe: currentMessageUserId == authenticatedUser!.uid,
                  );
                } else {
                  return MessageBubble.first(
                    userImage: chatMessage["userImage"],
                    username: chatMessage["username"],
                    message: chatMessage["text"],
                    isMe: currentMessageUserId == authenticatedUser!.uid,
                  );
                }
              });
        });
  }
}
