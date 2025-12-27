import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_page.dart';

class ChatsPage extends StatelessWidget {
  const ChatsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Chats"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .orderBy('updatedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No chats yet",
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          final chats = snapshot.data!.docs;

          return ListView.separated(
            itemCount: chats.length,
            separatorBuilder: (_, __) => const Divider(
              color: Colors.white12,
            ),
            itemBuilder: (context, index) {
              final data =
              chats[index].data() as Map<String, dynamic>;

              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: Icon(Icons.chat, color: Colors.white),
                ),
                title: Text(
                  data['itemTitle'] ?? 'Item',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  data['lastMessage'] ?? 'Tap to chat',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        chatId: chats[index].id,
                        itemTitle: data['itemTitle'] ?? 'Chat',
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
