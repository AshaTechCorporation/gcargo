import 'package:flutter/material.dart';
import 'package:gcargo/models/manual.dart';

class PromotionDetailPage extends StatelessWidget {
  final Manual? newpromo;
  const PromotionDetailPage({super.key, this.newpromo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('ข่าวสาร & โปรโมชั่น', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: false,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: Colors.white,
      body:
          newpromo == null
              ? Center(child: Text('ไม่มีข้อมูลคู่มือ', style: TextStyle(fontSize: 16, color: Colors.grey)))
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // 🔹 รูปภาพขนาดใหญ่
                  if (newpromo!.image != null && newpromo!.image!.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        newpromo!.image!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 48),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: double.infinity,
                            height: 200,
                            color: Colors.grey.shade200,
                            child: const Center(child: CircularProgressIndicator()),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                  const SizedBox(height: 20),

                  Text('${newpromo?.name ?? '-'}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  Text('${newpromo?.description ?? '-'}', style: TextStyle(fontSize: 14, height: 1.6)),
                ],
              ),
    );
  }
}
