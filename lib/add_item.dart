import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddItemPage extends StatefulWidget {
  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  File? image;

  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  String condition = "Gently Used";
  bool isDonation = false;
  bool isUploading = false;

  final picker = ImagePicker();

  // 📸 IMAGE SOURCE PICKER
  void chooseImageSource() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.white),
              title: const Text("Take Photo",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                await picker.pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => image = File(picked.path));
                }
              },
            ),
            ListTile(
              leading:
              const Icon(Icons.photo_library, color: Colors.white),
              title: const Text("Choose from Gallery",
                  style: TextStyle(color: Colors.white)),
              onTap: () async {
                Navigator.pop(context);
                final picked =
                await picker.pickImage(source: ImageSource.gallery);
                if (picked != null) {
                  setState(() => image = File(picked.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // 🚀 UPLOAD ITEM
  Future<void> uploadItem() async {
    if (image == null || titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please add image and title")),
      );
      return;
    }

    if (!isDonation && priceCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter price")),
      );
      return;
    }

    setState(() => isUploading = true);

    try {
      // 🔒 PLACEHOLDER IMAGE (NO STORAGE / BILLING)
      const imageUrl =
          "https://via.placeholder.com/400x600.png?text=UniTrade+Item";

      await FirebaseFirestore.instance.collection('items').add({
        'title': titleCtrl.text.trim(),
        'price': isDonation ? '0' : priceCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'condition': condition,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Item published successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Upload failed. Try again.")),
      );
    }

    setState(() => isUploading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("List an Item"),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 IMAGE
            const Text("Item Photo",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: chooseImageSource,
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: image == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add_a_photo,
                        size: 40, color: Colors.grey),
                    SizedBox(height: 10),
                    Text("Add photo",
                        style:
                        TextStyle(color: Colors.grey)),
                  ],
                )
                    : ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(image!,
                      fit: BoxFit.cover),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🏷 TITLE
            const Text("Title",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: titleCtrl,
              decoration: const InputDecoration(
                hintText: "e.g. Engineering Maths Book",
                filled: true,
              ),
            ),

            const SizedBox(height: 16),

            // 📝 DESCRIPTION
            const Text("Description",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                "Edition, defects, usage duration, etc.",
                filled: true,
              ),
            ),

            const SizedBox(height: 16),

            // 🎁 DONATION TOGGLE
            SwitchListTile(
              title: const Text("Donate this item (Free)"),
              subtitle: const Text(
                "Item will appear in Donation section",
                style: TextStyle(color: Colors.white54),
              ),
              value: isDonation,
              onChanged: (v) {
                setState(() {
                  isDonation = v;
                  if (isDonation) {
                    priceCtrl.text = "0";
                  } else {
                    priceCtrl.clear();
                  }
                });
              },
            ),

            const SizedBox(height: 8),

            // 💰 PRICE
            const Text("Price",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: priceCtrl,
              enabled: !isDonation,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: isDonation ? "Free Item" : "₹",
                filled: true,
              ),
            ),

            const SizedBox(height: 16),

            // 📦 CONDITION
            const Text("Condition",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: condition,
              items: const [
                "Brand New",
                "Like New",
                "Gently Used",
                "Used",
                "Heavily Used",
                "For Parts",
              ]
                  .map((c) =>
                  DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => condition = v!),
              decoration: const InputDecoration(filled: true),
            ),

            const SizedBox(height: 30),

            // 🚀 SUBMIT
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                ),
                onPressed: isUploading ? null : uploadItem,
                child: isUploading
                    ? const CircularProgressIndicator(
                    color: Colors.white)
                    : const Text(
                  "Publish Item",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
