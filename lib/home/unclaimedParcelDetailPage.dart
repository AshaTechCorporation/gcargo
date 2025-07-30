import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/home/confirmOwnershipPage.dart';

class UnclaimedParcelDetailPage extends StatelessWidget {
  const UnclaimedParcelDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final String trackingNumber = 'YT7518613489991';
    final String receivedDate = '2024-08-13 15:59:17';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        title: Text('เลขขนส่งจีน  $trackingNumber', style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 วันที่ถึง
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('วันที่ได้รับยืนยัน', style: TextStyle(fontSize: 14)),
                    Text(receivedDate, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 24),

                // 🔹 หัวข้อรูปภาพ
                const Text('รูปภาพพัสดุ', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),

                // 🔹 รูปภาพ 2 รูป
                Row(
                  children: [
                    _buildImagePreview('assets/images/image11.png'),
                    const SizedBox(width: 12),
                    _buildImagePreview('assets/images/image14.png'),
                  ],
                ),

                const SizedBox(height: 24),
                const Divider(height: 1, color: Colors.grey),
              ],
            ),
          ),
          const Spacer(),

          // 🔹 ปุ่มด้านล่าง
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor, // kButtonColor
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  // TODO: handle confirmation
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ConfirmOwnershipPage()));
                },
                child: Text('ยืนยันความเป็นเจ้าของ', style: TextStyle(fontSize: 20, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(String assetPath) {
    return ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.asset(assetPath, width: 64, height: 64, fit: BoxFit.cover));
  }
}
