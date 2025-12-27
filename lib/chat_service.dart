import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ChatService {
  final _firestore = FirebaseFirestore.instance;

  // Always available demo user
  String get demoUserId => "demo_${Random().nextInt(999999)}";

  // Create chat but NEVER block UI
  Future<String> createChatSafely({
    required String itemId,
    required String itemTitle,
  }) async {
    try {
      final doc = await _firestore.collection('chats').add({
        'itemId': itemId,
        'itemTitle': itemTitle,
        'createdAt': Timestamp.now(),
      });
      return doc.id;
    } catch (e) {
      // fallback local chat
      return "local_${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  Stream<QuerySnapshot> getMessages(String chatId) {
    try {
      return _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp')
          .snapshots();
    } catch (_) {
      return const Stream.empty();
    }
  }

  Future<void> sendMessage(String chatId, String text) async {
    if (text.trim().isEmpty) return;

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'sender': demoUserId,
        'text': text,
        'timestamp': Timestamp.now(),
      });
    } catch (_) {
      // ignore for demo
    }
  }
}
