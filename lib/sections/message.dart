import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:green_theme/sections/message.bubble.dart';

class Messages extends StatelessWidget {
  const Messages({required this.section});
  final String section;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final User? user = authSnapshot.data;

        if (user == null) {
          return const Center(
            child: Text('No user signed in'),
          );
        }

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(section)
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            final chatDocs = snapshot.data!.docs;

            return ListView.builder(
              reverse: true,
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  userid: chatDocs[index]['userId'].toString(),
                  texts: chatDocs[index]['text'].toString(),
                  isMe: chatDocs[index]['userId'] == user.uid,
                );
              },
            );
          },
        );
      },
    );
  }
}