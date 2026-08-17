import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showQrDialog(
  BuildContext context, {
  required String line,
  required String phone,
}) async {
  const lineGreen = Color(0xFF06C755);
  final normalizedLine = line.trim();
  final normalizedPhone = phone.trim();
  final lineUrl = _buildLineUrl(normalizedLine);

  Future<void> callStaff() async {
    final callablePhone = normalizedPhone.replaceAll(RegExp(r'[^0-9+]'), '');
    if (callablePhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่พบเบอร์โทรศัพท์เจ้าหน้าที่')),
      );
      return;
    }

    try {
      final launched = await launchUrl(Uri(scheme: 'tel', path: callablePhone));
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อุปกรณ์นี้ไม่สามารถโทรออกได้')),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ไม่สามารถเปิดแอปโทรศัพท์ได้')),
        );
      }
    }
  }

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
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, size: 24),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),

            // เนื้อหา
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (lineUrl != null)
                    QrImageView(
                      data: lineUrl,
                      version: QrVersions.auto,
                      size: 220,
                      backgroundColor: Colors.white,
                    )
                  else
                    const SizedBox(
                      width: 220,
                      height: 220,
                      child: Center(
                        child: Text(
                          'ไม่พบข้อมูล Line',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),

                  Text(
                    normalizedLine,
                    style: const TextStyle(
                      color: lineGreen,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (normalizedPhone.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      normalizedPhone,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: const Color(0xFF012849),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: normalizedPhone.isEmpty ? null : callStaff,
                      icon: const Icon(Icons.phone),
                      label: const Text(
                        'โทรหาเจ้าหน้าที่',
                        style: TextStyle(fontSize: 16),
                      ),
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

String? _buildLineUrl(String line) {
  if (line.isEmpty) return null;

  final uri = Uri.tryParse(line);
  if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
    return uri.toString();
  }

  return 'https://line.me/R/ti/p/${Uri.encodeComponent(line)}';
}
