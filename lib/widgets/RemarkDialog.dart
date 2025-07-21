import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart'; // ถ้ามีค่าสี kButtonColor ใช้จากตรงนี้

class RemarkDialog extends StatefulWidget {
  final String initialText;
  final Function(String) onSave;

  const RemarkDialog({super.key, required this.initialText, required this.onSave});

  @override
  State<RemarkDialog> createState() => _RemarkDialogState();
}

class _RemarkDialogState extends State<RemarkDialog> {
  final int maxLength = 200;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 ปิด
            Row(children: [const Spacer(), GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.close, size: 24))]),
            const SizedBox(height: 8),

            // 🔹 หัวข้อ
            const Align(alignment: Alignment.centerLeft, child: Text('หมายเหตุ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
            const SizedBox(height: 8),

            // 🔹 กล่องป้อนข้อความ
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _controller,
                    maxLines: null,
                    maxLength: maxLength,
                    decoration: const InputDecoration.collapsed(hintText: 'หมายเหตุ'),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text('${_controller.text.length}/$maxLength', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 ปุ่มบันทึก
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  widget.onSave(_controller.text.trim());
                  Navigator.pop(context);
                },
                child: const Text('บันทึก', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
