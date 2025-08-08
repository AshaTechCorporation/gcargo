import 'package:flutter/material.dart';

Future<void> showQrDialog(
  BuildContext context, {
  String handle = '@gcargo',
  String? avatarUrl, // ถ้ามีรูปโปรไฟล์ ให้ส่ง URL มา
  String? avatarAsset, // หรือส่ง asset โปรไฟล์ก็ได้
  VoidCallback? onDownload, // callback เวลากด "ดาวน์โหลด"
}) async {
  const lineGreen = Color(0xFF06C755);

  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (_) {
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: Stack(
          children: [
            // ปุ่มปิดมุมขวาบน
            Positioned(top: 8, right: 8, child: IconButton(icon: const Icon(Icons.close, size: 24), onPressed: () => Navigator.of(context).pop())),

            // เนื้อหา
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // QR + โปรไฟล์ซ้อนกลาง
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset('assets/images/qrcode.png', width: 220, height: 220, fit: BoxFit.cover),
                      ),
                      if (avatarUrl != null || avatarAsset != null)
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [BoxShadow(blurRadius: 8, color: Colors.black12)],
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: avatarAsset != null ? AssetImage(avatarAsset) as ImageProvider : NetworkImage(avatarUrl!),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // @handle สีเขียว
                  Text(handle, style: const TextStyle(color: lineGreen, fontSize: 20, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 16),

                  // ปุ่ม "ดาวน์โหลด"
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: Color(0xFFE5E5E5)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        backgroundColor: Colors.white,
                      ),
                      onPressed: onDownload,
                      child: const Text('ดาวน์โหลด', style: TextStyle(fontSize: 16, color: Colors.black)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
