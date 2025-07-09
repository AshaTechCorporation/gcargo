import 'package:flutter/material.dart';
import 'package:gcargo/account/userManualDetailPage.dart';

class UserManualPage extends StatelessWidget {
  const UserManualPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> manuals = List.generate(
      8,
      (_) => {'image': 'assets/images/imagenew14.png', 'title': 'คู่มือการใช้งาน', 'desc': 'คู่มือการใช้งาน คู่มือการใช้งาน คู่มือการใช้งาน ...'},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('คู่มือการใช้งาน', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: manuals.length,
        itemBuilder: (context, index) {
          final item = manuals[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => UserManualDetailPage()));
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    // 🔹 Image
                    ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(item['image']!, width: 60, height: 60, fit: BoxFit.cover)),
                    const SizedBox(width: 12),

                    // 🔹 Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            item['desc']!,
                            style: const TextStyle(fontSize: 13, color: Colors.black87),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
