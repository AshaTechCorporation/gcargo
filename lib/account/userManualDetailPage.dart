import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:gcargo/models/manual.dart';

class UserManualDetailPage extends StatelessWidget {
  final Manual? manual;

  const UserManualDetailPage({super.key, this.manual});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(manual?.name ?? 'คู่มือการใช้งาน', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
      ),
      body:
          manual == null
              ? Center(child: Text('ไม่มีข้อมูลคู่มือ', style: TextStyle(fontSize: 16, color: Colors.grey)))
              : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔹 รูปภาพขนาดใหญ่
                    if (manual!.image != null && manual!.image!.isNotEmpty) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          manual!.image!,
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

                    // 🔹 หัวข้อและรายละเอียด
                    Text(manual!.name ?? 'ไม่มีชื่อคู่มือ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),

                    if (manual?.description != null && manual!.description!.isNotEmpty) ...[
                      HtmlWidget(manual!.description!, textStyle: const TextStyle(fontSize: 14, height: 1.5)),
                      SizedBox(height: 20),
                    ],

                    // 🔹 Additional information if available
                    if (manual!.id != null) ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.grey),
                            SizedBox(width: 8),
                            Text('รหัสคู่มือ: ${manual!.id}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
    );
  }
}
