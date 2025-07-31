import 'package:flutter/material.dart';

class QrCodeDialog extends StatelessWidget {
  const QrCodeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔹 QR Image
                Image.asset('assets/images/qrcode.png', width: 200, height: 200),

                const SizedBox(height: 16),

                // 🔹 Label
                const Text('@gcargo', style: TextStyle(color: Color(0xFF00B900), fontSize: 20, fontWeight: FontWeight.bold)),

                const SizedBox(height: 16),

                // 🔹 Download Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: download QR function
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F5F5),
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('ดาวน์โหลด'),
                  ),
                ),
              ],
            ),

            // 🔹 Close Icon (X)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(onTap: () => Navigator.of(context).pop(), child: const Icon(Icons.close, color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
