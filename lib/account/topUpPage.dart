import 'package:flutter/material.dart';
import 'package:gcargo/account/qrpayPage.dart';
import 'package:intl/intl.dart';

class TopUpPage extends StatefulWidget {
  TopUpPage({super.key, required this.type, required this.walletBalance});
  final String type;
  final String walletBalance;

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  String amount = '';

  void _onKeyPress(String key) {
    setState(() {
      if (key == '←') {
        if (amount.isNotEmpty) {
          amount = amount.substring(0, amount.length - 1);
        }
      } else {
        amount += key;
      }
    });
  }

  void _clearAmount() {
    setState(() {
      amount = '';
    });
  }

  // ฟอแมทตัวเลขให้มีคอมม่า
  String _formatAmount(double value) {
    final formatter = NumberFormat('#,##0.00');
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.type == 'I' ? Text('เติมเงิน', style: TextStyle(color: Colors.black)) : Text('ถอนเงิน', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 🔹 ช่องกรอกยอดเงิน
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.type == 'I'
                    ? Text('ยอดเงินที่ต้องการเติมเงิน', style: TextStyle(fontSize: 14))
                    : Text('ยอดเงินที่ต้องการถอน', style: TextStyle(fontSize: 14)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          amount.isEmpty ? 'กรอกยอดเงินบาท' : amount,
                          style: TextStyle(fontSize: 16, color: amount.isEmpty ? Colors.grey : Colors.black),
                        ),
                      ),
                      if (amount.isNotEmpty) GestureDetector(onTap: _clearAmount, child: const Icon(Icons.clear, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // 🔢 Keypad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              children: [
                for (var row in [
                  ['1', '2', '3'],
                  ['4', '5', '6'],
                  ['7', '8', '9'],
                  ['000', '0', '←'],
                ])
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children:
                          row.map((key) {
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _onKeyPress(key),
                                child: Center(child: Text(key, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w500))),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
              ],
            ),
          ),

          // 🔘 ปุ่มชำระเงิน
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002D72),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed:
                    amount.isEmpty
                        ? null
                        : () {
                          // ตรวจสอบกรณีถอนเงิน
                          if (widget.type == 'O') {
                            final double enteredAmount = double.tryParse(amount) ?? 0.0;
                            final double currentBalance = double.tryParse(widget.walletBalance) ?? 0.0;

                            if (enteredAmount > currentBalance) {
                              // แจ้งเตือนว่ายอดถอนมากกว่ายอดเงินคงเหลือ
                              showDialog(
                                context: context,
                                builder:
                                    (context) => AlertDialog(
                                      title: const Text('ไม่สามารถถอนเงินได้'),
                                      content: Text(
                                        'ยอดเงินที่ต้องการถอน (${_formatAmount(enteredAmount)} บาท) มากกว่ายอดเงินคงเหลือ (${_formatAmount(currentBalance)} บาท)',
                                      ),
                                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('ตกลง'))],
                                    ),
                              );
                              return;
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QrpayPage(totalPrice: double.parse(amount), type: widget.type)),
                          );
                        },
                child:
                    widget.type == 'I'
                        ? Text('ชำระเงิน', style: TextStyle(fontSize: 16, color: Colors.white))
                        : Text('ถอนเงิน', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
