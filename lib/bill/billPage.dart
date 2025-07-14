import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:gcargo/constants.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  String selectedFilter = 'ทั้งหมด';
  final List<String> filters = ['ทั้งหมด', 'รอชำระเงิน', 'สำเร็จ', 'ยกเลิก'];
  String selectedDateRange = '1/01/2024 - 01/07/2025';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  const Text('ค่าขนส่ง', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      // TODO: Add date range picker
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 18, color: kHintTextColor),
                          const SizedBox(width: 8),
                          Text(selectedDateRange, style: const TextStyle(color: kHintTextColor, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 🔹 Search box
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ค้นหาเลขที่เอกสาร',
                  hintStyle: const TextStyle(color: kHintTextColor),
                  prefixIcon: const Icon(Icons.search, color: kHintTextColor),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔹 Filter Chips
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 8,
                children:
                    filters.map((filter) {
                      final isSelected = selectedFilter == filter;
                      return ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },
                        labelStyle: TextStyle(color: isSelected ? Colors.white : kButtonColor, fontWeight: FontWeight.w500),
                        selectedColor: kButtonColor,
                        backgroundColor: kButtondiableColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      );
                    }).toList(),
              ),
            ),

            const SizedBox(height: 16),

            // 🔹 Bill List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  const Text('01/07/2025', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  _buildBillCard(documentNo: 'X2504290002', status: 'สำเร็จ', statusColor: Colors.green, totalAmount: '1,060.00'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillCard({required String documentNo, required String status, required Color statusColor, required String totalAmount}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Top Row: icon + doc no + status
          Row(
            children: [
              const Icon(Icons.insert_drive_file, color: kButtonColor),
              const SizedBox(width: 8),
              Expanded(child: Text('เลขที่เอกสาร $documentNo', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
              Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          // 🔹 Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('รวมค่าขนส่งจีนไทย', style: TextStyle(fontSize: 14, color: Colors.black54)),
              Text(totalAmount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}
