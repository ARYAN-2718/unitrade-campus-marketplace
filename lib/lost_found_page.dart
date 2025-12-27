import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'chat_page.dart';

class LostFoundPage extends StatefulWidget {
  const LostFoundPage({super.key});

  @override
  State<LostFoundPage> createState() => _LostFoundPageState();
}

class _LostFoundPageState extends State<LostFoundPage> {
  String filter = "lost";
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Lost & Found"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔘 FILTER CHIPS
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _chip("lost", "Lost"),
                const SizedBox(width: 10),
                _chip("found", "Found"),
              ],
            ),
          ),

          // 📋 POSTS LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('lost_found')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                // ✅ HARD FILTER IN DART (FIX)
                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['type'] == filter;
                }).toList();

                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posts yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data =
                    docs[index].data() as Map<String, dynamic>;

                    final chatId =
                        "lf_${docs[index].id}"; // ✅ UNIQUE CHAT

                    return Card(
                      color: const Color(0xFF1E1E1E),
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: Image.network(
                          data['imageUrl'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image,
                              color: Colors.grey),
                        ),
                        title: Text(
                          data['title'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['description'],
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "📍 ${data['location']} • 🎨 ${data['color']}",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54),
                            ),
                            Text(
                              "📅 ${data['date']}",
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white54),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.chat,
                              color: Colors.deepPurple),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatPage(
                                  chatId: chatId,
                                  itemTitle: data['title'],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String value, String label) {
    return ChoiceChip(
      label: Text(label),
      selected: filter == value,
      selectedColor: Colors.deepPurple,
      onSelected: (_) => setState(() => filter = value),
    );
  }

  // ➕ ADD POST DIALOG
  void _showAddDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    String color = "Black";
    String type = "lost";
    DateTime date = DateTime.now();
    File? image;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) {
          return AlertDialog(
            title: const Text("Add Lost / Found"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () async {
                      final picked = await picker.pickImage(
                          source: ImageSource.gallery);
                      if (picked != null) {
                        setModal(() => image = File(picked.path));
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: image == null
                          ? const Icon(Icons.add_a_photo,
                          size: 40)
                          : Image.file(image!,
                          fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 10),

                  DropdownButtonFormField(
                    value: type,
                    items: const [
                      DropdownMenuItem(
                          value: "lost", child: Text("Lost")),
                      DropdownMenuItem(
                          value: "found", child: Text("Found")),
                    ],
                    onChanged: (v) => type = v!,
                  ),

                  TextField(
                    controller: titleCtrl,
                    decoration:
                    const InputDecoration(labelText: "Title"),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration:
                    const InputDecoration(labelText: "Description"),
                  ),
                  TextField(
                    controller: locationCtrl,
                    decoration: const InputDecoration(
                        labelText: "Last seen location"),
                  ),

                  DropdownButtonFormField(
                    value: color,
                    items: const [
                      "Black",
                      "Blue",
                      "Red",
                      "Green",
                      "White",
                      "Other"
                    ]
                        .map((c) => DropdownMenuItem(
                        value: c, child: Text(c)))
                        .toList(),
                    onChanged: (v) => color = v!,
                  ),

                  ListTile(
                    title: Text(
                        "Date: ${date.day}/${date.month}/${date.year}"),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setModal(() => date = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel")),
              ElevatedButton(
                child: const Text("Post"),
                onPressed: () async {
                  if (titleCtrl.text.trim().isEmpty) return;

                  await FirebaseFirestore.instance
                      .collection('lost_found')
                      .add({
                    'type': type,
                    'title': titleCtrl.text.trim(),
                    'description': descCtrl.text.trim(),
                    'location': locationCtrl.text.trim(),
                    'color': color,
                    'date':
                    "${date.day}/${date.month}/${date.year}",
                    'imageUrl':
                    "https://via.placeholder.com/400x400.png?text=Lost+Item",
                    'createdAt': Timestamp.now(),
                    'expiresAt': Timestamp.fromDate(
                      DateTime.now()
                          .add(const Duration(days: 7)),
                    ),
                  });

                  Navigator.pop(context);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
