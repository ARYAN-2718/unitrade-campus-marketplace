import 'package:flutter/material.dart';
import 'safe_zones_map.dart';
import 'chat_page.dart';
import 'chat_service.dart';

class ItemDetailPage extends StatelessWidget {
  final String title;
  final String price;
  final String condition;
  final String description;
  final String imageUrl;

  const ItemDetailPage({
    super.key,
    required this.title,
    required this.price,
    required this.condition,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Item Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 IMAGE SECTION
            Container(
              height: 320,
              width: double.infinity,
              color: Colors.black,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Center(
                    child: Icon(Icons.image, size: 80, color: Colors.grey),
                  );
                },
              ),
            ),

            // 📦 CONTENT SECTION
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TITLE
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  // PRICE + CONDITION
                  Row(
                    children: [
                      Text(
                        "₹$price",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.greenAccent,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          condition,
                          style: const TextStyle(
                            color: Colors.deepPurpleAccent,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // DESCRIPTION
                  const Text(
                    "Description",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description.isEmpty
                        ? "No description provided."
                        : description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // SELLER INFO
                  const Text(
                    "Seller",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Campus Student",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Verified via institute email",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🗺 SAFE ZONES MAP
                  SafeZonesMap(),

                  const SizedBox(height: 40),

                  // 💬 CHAT BUTTON — NEVER FAILS
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text(
                        "Request / Chat with Seller",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: () {
                        // 1️⃣ OPEN CHAT IMMEDIATELY (NO BLOCKING)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPage(
                              chatId: "temp_chat",
                              itemTitle: title,
                            ),
                          ),
                        );

                        // 2️⃣ CREATE CHAT IN BACKGROUND (BEST EFFORT)
                        ChatService().createChatSafely(
                          itemId: title,
                          itemTitle: title,

                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
