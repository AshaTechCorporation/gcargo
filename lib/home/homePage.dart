import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              const Text('A100', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black)),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Expanded(child: Text('ค้นหาสินค้า', style: TextStyle(color: Colors.grey))),
                      Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.delete_outline, color: Colors.black),
              const SizedBox(width: 12),
              const Icon(Icons.notifications_none, color: Colors.black),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Slide Image
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.asset('assets/images/slidpic.png')),
              ),
              const SizedBox(height: 16),

              // 🔹 Stack รูป + ช่องค้นหา + ข้อความ
              Stack(
                children: [
                  // 🔸 รูป
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset('assets/images/pichome.png', width: double.infinity, height: 140, fit: BoxFit.cover),
                    ),
                  ),

                  // 🔸 ช่องค้นหาแบบ overlay
                  Positioned(
                    left: 32,
                    right: 32,
                    top: 16,
                    child: Container(
                      height: 36,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                      child: Row(
                        children: [
                          const Expanded(child: Text('ค้นหาสินค้าจากคลัง', style: TextStyle(color: Colors.grey))),
                          Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 20),
                        ],
                      ),
                    ),
                  ),

                  // 🔸 ข้อความทับบนรูป (ใต้ช่องค้นหา)
                  Positioned(
                    left: 32,
                    top: 64,
                    child: Text(
                      'วางสิ่งที่ของคุณที่นี่',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: Offset(1, 1))],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Row(
                    children: [
                      // 🔹 ฝั่งซ้าย: กล่องรูปใหญ่เต็ม 50%
                      Expanded(child: Center(child: Image.asset('assets/images/ex1.png', fit: BoxFit.cover))),

                      // 🔸 เส้นแบ่งกลาง
                      Container(width: 1, height: 100, margin: const EdgeInsets.symmetric(horizontal: 12), color: Colors.grey.shade300),

                      // 🔹 ฝั่งขวา: การ์ดแต้มของขวัญ
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  // ข้อความ
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: const [
                                        Text('100', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFFFF9800))),
                                        SizedBox(height: 2),
                                        Text('แต้มของขวัญ', style: TextStyle(fontSize: 13, color: Colors.black87)),
                                      ],
                                    ),
                                  ),
                                  // รูปของขวัญด้านขวา
                                  Image.asset('assets/icons/gif.png', width: 30, height: 30),
                                ],
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text('นำไปแลกของรางวัล', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 เมนูบริการ
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildServiceItem('assets/icons/tran1.png', 'อัตราค่าขนส่ง'),
                    _buildServiceItem('assets/icons/monny.png', 'อัตราแลกเปลี่ยน'),
                    _buildServiceItem('assets/icons/cal1.png', 'คำนวณค่าบริการ'),
                    _buildServiceItem('assets/icons/box1.png', 'ตามพัสดุของฉัน'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 🔹 สินค้าแนะนำ
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('รายการสินค้าแนะนำ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.78, // ไม่ควรเกินนี้ ไม่งั้น desc ไม่พอ
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildProductCard('assets/images/unsplash0.png', 'เสื้อแขนสั้น', 'เสื้อแขนสั้นไว้ใส่ไปเดินเล่นลายกราฟิก สำหรับผู้ชาย', '฿10'),
                    _buildProductCard(
                      'assets/images/unsplash1.png',
                      'รองเท้าบาส',
                      'รองเท้าบาสไว้ใส่เล่นกีฬาบาสเก็ตบอลเหมะสำหรับพื้นไม้ปาเก้',
                      '฿100',
                    ),
                    _buildProductCard('assets/images/unsplash3.png', 'นาฬิกาข้อมือ', 'นาฬิกาแฟชั่น ดีไซน์ล้ำ ทันสมัย เท่ทุกมุมมอง', '฿999'),
                    _buildProductCard(
                      'assets/images/unsplash2.png',
                      'เสื้อคลุม',
                      'เสื้อฮู้ดฟรีไซน์มีหลายโทนสีสามารถใส่ได้ทั้งชาย และหญิง กันลม กันฝน ใส่เดินเที่ยวก็เท่',
                      '฿499',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceItem(String iconPath, String label) {
    return Column(
      children: [
        Image.asset(iconPath, width: 36, height: 36),
        const SizedBox(height: 6),
        SizedBox(width: 64, child: Text(label, style: const TextStyle(fontSize: 12), textAlign: TextAlign.center)),
      ],
    );
  }

  Widget _buildProductCard(String img, String title, String desc, String price) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                child: Image.asset(img, fit: BoxFit.cover, height: 130, width: double.infinity),
              ),
              const Positioned(top: 8, right: 8, child: Icon(Icons.favorite_border, color: Colors.grey)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),

                /// ✅ กล่องนี้ช่วยให้ desc เต็ม 2 บรรทัดแบบชัดเจน
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    minHeight: 32,
                    maxHeight: 32, // ประมาณ 2 บรรทัดพอดี fontSize 12
                  ),
                  child: Text(
                    desc,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.visible,
                    softWrap: true,
                  ),
                ),

                const SizedBox(height: 4),
                Text(price, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
