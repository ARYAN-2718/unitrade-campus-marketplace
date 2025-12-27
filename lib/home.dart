import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_item.dart';
import 'item_detail.dart';
import 'chats_page.dart';
import 'lost_found_page.dart';

enum HomeSection { market, lostFound, donate }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeSection currentSection = HomeSection.market;
  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      // 🧭 APP BAR
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          "UniTrade",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatsPage()),
              );
            },
          ),
        ],
      ),

      // ➕ ADD ITEM (only for marketplace & donate)
      floatingActionButton: currentSection == HomeSection.lostFound
          ? null
          : FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add),
        label: Text(
          currentSection == HomeSection.donate
              ? "Donate Item"
              : "Add Item",
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddItemPage()),
          );
        },
      ),

      body: Column(
        children: [
          // 🔘 TOP SECTION SWITCH
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _sectionChip(HomeSection.market, "Buy & Sell"),
                const SizedBox(width: 8),
                _sectionChip(HomeSection.lostFound, "Lost & Found"),
                const SizedBox(width: 8),
                _sectionChip(HomeSection.donate, "Donate"),
              ],
            ),
          ),

          // 🔍 SEARCH BAR (NO ERRORS NOW)
          if (currentSection != HomeSection.lostFound)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  hintText: "Search items...",
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

          const SizedBox(height: 10),

          // 📦 CONTENT
          Expanded(child: _buildSection()),
        ],
      ),
    );
  }

  // 🔘 SECTION CHIP
  Widget _sectionChip(HomeSection section, String label) {
    final isSelected = currentSection == section;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.deepPurple,
      onSelected: (_) {
        setState(() {
          currentSection = section;
          searchQuery = "";
        });
      },
    );
  }

  // 📦 SECTION BUILDER
  Widget _buildSection() {
    switch (currentSection) {
      case HomeSection.market:
        return _itemsGrid(showOnlyFree: false);
      case HomeSection.donate:
        return _itemsGrid(showOnlyFree: true);
      case HomeSection.lostFound:
        return const LostFoundPage();
    }
  }

  // 🛒 ITEMS GRID (MARKET + DONATE)
  Widget _itemsGrid({required bool showOnlyFree}) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('items')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "No items found",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final items = snapshot.data!.docs
            .map((e) => e.data() as Map<String, dynamic>)
            .where((item) {
          final matchesSearch = (item['title'] ?? '')
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());

          final isFree = (item['price'] ?? '') == '0';

          return matchesSearch &&
              (showOnlyFree ? isFree : true);
        }).toList();

        if (items.isEmpty) {
          return const Center(
            child: Text(
              "No matching items",
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.68,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final data = items[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ItemDetailPage(
                      title: data['title'] ?? '',
                      price: data['price'] ?? '',
                      condition: data['condition'] ?? '',
                      description: data['description'] ?? '',
                      imageUrl: data['imageUrl'] ?? '',
                    ),
                  ),
                );
              },
              child: _itemCard(data),
            );
          },
        );
      },
    );
  }

  // 🟣 ITEM CARD
  Widget _itemCard(Map<String, dynamic> data) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius:
              const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                data['imageUrl'] ?? '',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  data['price'] == '0'
                      ? "FREE"
                      : "₹${data['price']}",
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
