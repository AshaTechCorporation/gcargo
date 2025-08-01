import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/parcel/parcelDetailPage.dart';
import 'package:gcargo/parcel/shippingMethodPage.dart';
import 'package:intl/intl.dart';

class ParcelStatusPage extends StatefulWidget {
  const ParcelStatusPage({super.key});

  @override
  State<ParcelStatusPage> createState() => _ParcelStatusPageState();
}

class _ParcelStatusPageState extends State<ParcelStatusPage> {
  final List<String> statuses = ['ทั้งหมด', 'รอส่งไปโกดังจีน', 'ถึงโกดังจีน', 'ปิดตู้', 'ถึงโกดังไทย', 'กำลังตรวจสอบ', 'รอตัดส่ง', 'สำเร็จ'];
  TextEditingController _dateController = TextEditingController();

  // เพิ่ม state สำหรับ checkbox ของสถานะ "ถึงโกดังไทย"
  Set<String> selectedParcels = {};

  final Map<String, int> statusCounts = {
    'ทั้งหมด': 0,
    'รอส่งไปโกดังจีน': 1,
    'ถึงโกดังจีน': 1,
    'ปิดตู้': 1,
    'ถึงโกดังไทย': 3, // เพิ่มจำนวนเป็น 3
    'กำลังตรวจสอบ': 1,
    'รอตัดส่ง': 1,
    'สำเร็จ': 1,
  };

  int selectedStatusIndex = 0;
  bool isRequestTaxCertificate = false; // สำหรับ radio button ขอใบรับรองภาษี
  bool isSelectAll = true; // สำหรับ checkbox เลือกทั้งหมด

  @override
  void initState() {
    super.initState();
    _dateController.text = '01/01/2024 - 01/07/2025'; // ค่าเริ่มต้น
  }

  // Method สำหรับอัปเดต selection ของพัสดุทั้งหมดในสถานะ "ถึงโกดังไทย"
  void _updateAllParcelsSelection() {
    // รายการพัสดุทั้งหมดในสถานะ "ถึงโกดังไทย"
    final allThailandParcels = ['00044', '00051', '00052'];

    if (isSelectAll) {
      // เลือกทั้งหมด
      selectedParcels.addAll(allThailandParcels);
    } else {
      // ยกเลิกการเลือกทั้งหมด
      selectedParcels.removeAll(allThailandParcels);
    }
  }

  // Method สำหรับอัปเดตสถานะ "เลือกทั้งหมด" ตามการเลือกของแต่ละการ์ด
  void _updateSelectAllState() {
    final allThailandParcels = ['00044', '00051', '00052'];

    // ถ้าเลือกครบทุกตัว ให้ติ๊ก "เลือกทั้งหมด"
    // ถ้าไม่เลือกครบ ให้ยกเลิกการติ๊ก "เลือกทั้งหมด"
    isSelectAll = allThailandParcels.every((parcel) => selectedParcels.contains(parcel));
  }

  Widget _buildStatusChip(String label, int count, bool isActive, int index) {
    return GestureDetector(
      onTap: () => setState(() => selectedStatusIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF427D9D) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF427D9D)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isActive ? Colors.white : const Color(0xFF427D9D))),
            if (count > 0) ...[
              const SizedBox(width: 6),
              CircleAvatar(
                radius: 10,
                backgroundColor: isActive ? Colors.white : kCicleColor,
                child: Text(
                  '$count',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF427D9D) : Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildParcelCard({required String parcelNo, required String status, required bool showActionButton}) {
    return GestureDetector(
      onTap: () {
        // ไปหน้า parcel detail
        Navigator.push(context, MaterialPageRoute(builder: (_) => ParcelDetailPage(status: status)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: Color(0xFFE9F4FF), shape: BoxShape.circle),
                  child: Center(child: Image.asset('assets/icons/box.png', width: 18, height: 18)),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text('เลขขนส่งจีน $parcelNo', style: const TextStyle(fontWeight: FontWeight.bold))),
                //Text(status, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF427D9D))),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [const Text('เลขบิลสั่งซื้อ'), const Text('167304', style: TextStyle(fontWeight: FontWeight.bold))],
            ),

            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('เลขบิลหน้าโกดัง'),
                status == 'รอส่งไปโกดังจีน' ? SizedBox() : Text('000000', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
            // เพิ่ม checkbox เฉพาะสถานะ "ถึงโกดังไทย"
            Row(
              children: [
                if (status == 'ถึงโกดังไทย') ...[
                  Checkbox(
                    value: selectedParcels.contains(parcelNo),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedParcels.add(parcelNo);
                        } else {
                          selectedParcels.remove(parcelNo);
                        }
                        _updateSelectAllState();
                      });
                    },
                    activeColor: const Color(0xFF427D9D),
                  ),
                  const SizedBox(width: 8),
                  Text('8,516.00฿'),
                ],
              ],
            ),

            if (showActionButton) ...[
              const SizedBox(height: 8),
              const Text('เลขที่เอกสาร'),
              const Text('X2504290002', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('บริษัทขนส่งในไทย'),
              const Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('หมายเลขขนส่งในไทย'),
              const Text('-', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF427D9D)),
                      foregroundColor: const Color(0xFF427D9D),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('แจ้งพัสดุมีปัญหา'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDateGroup(String date, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [Text(date, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), ...cards, const SizedBox(height: 16)],
    );
  }

  // สร้างข้อมูลการ์ดตามสถานะ
  List<Widget> _getCardsForStatus(String status) {
    switch (status) {
      case 'ทั้งหมด':
        return [
          _buildDateGroup('02/07/2025', [
            _buildParcelCard(parcelNo: '00044', status: 'ถึงโกดังไทย', showActionButton: false),
            _buildParcelCard(parcelNo: '00051', status: 'ถึงโกดังไทย', showActionButton: false),
            _buildParcelCard(parcelNo: '00045', status: 'รอส่งไปโกดังจีน', showActionButton: false),
          ]),
          _buildDateGroup('01/07/2025', [
            _buildParcelCard(parcelNo: '00052', status: 'ถึงโกดังไทย', showActionButton: false),
            _buildParcelCard(parcelNo: '00046', status: 'สำเร็จ', showActionButton: true),
            _buildParcelCard(parcelNo: '00047', status: 'กำลังตรวจสอบ', showActionButton: false),
          ]),
        ];
      case 'รอส่งไปโกดังจีน':
        return [
          _buildDateGroup('02/07/2025', [_buildParcelCard(parcelNo: '00045', status: 'รอส่งไปโกดังจีน', showActionButton: false)]),
        ];
      case 'ถึงโกดังจีน':
        return [
          _buildDateGroup('01/07/2025', [_buildParcelCard(parcelNo: '00048', status: 'ถึงโกดังจีน', showActionButton: false)]),
        ];
      case 'ปิดถุง':
        return [
          _buildDateGroup('30/06/2025', [_buildParcelCard(parcelNo: '00049', status: 'ปิดถุง', showActionButton: false)]),
        ];
      case 'ถึงโกดังไทย':
        return [
          _buildDateGroup('02/07/2025', [
            _buildParcelCard(parcelNo: '00044', status: 'ถึงโกดังไทย', showActionButton: false),
            _buildParcelCard(parcelNo: '00051', status: 'ถึงโกดังไทย', showActionButton: false),
          ]),
          _buildDateGroup('01/07/2025', [_buildParcelCard(parcelNo: '00052', status: 'ถึงโกดังไทย', showActionButton: false)]),
        ];
      case 'กำลังตรวจสอบ':
        return [
          _buildDateGroup('01/07/2025', [_buildParcelCard(parcelNo: '00047', status: 'กำลังตรวจสอบ', showActionButton: false)]),
        ];
      case 'รอตัดส่ง':
        return [
          _buildDateGroup('29/06/2025', [_buildParcelCard(parcelNo: '00050', status: 'รอตัดส่ง', showActionButton: false)]),
        ];
      case 'สำเร็จ':
        return [
          _buildDateGroup('01/07/2025', [_buildParcelCard(parcelNo: '00046', status: 'สำเร็จ', showActionButton: true)]),
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          automaticallyImplyLeading: true,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('สถานะพัสดุ', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold)),
              SizedBox(width: 20),
              Expanded(
                child: TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  onTap: () async {
                    DateTimeRange? picked = await showDateRangePicker(
                      context: context,
                      firstDate: DateTime(2023),
                      lastDate: DateTime(2030),
                      initialDateRange: DateTimeRange(start: DateTime(2024, 1, 1), end: DateTime(2025, 7, 1)),
                    );
                    if (picked != null) {
                      String formatted = '${DateFormat('dd/MM/yyyy').format(picked.start)} - ${DateFormat('dd/MM/yyyy').format(picked.end)}';
                      setState(() {
                        _dateController.text = formatted;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Padding(padding: const EdgeInsets.all(12.0), child: Image.asset('assets/icons/calendar_icon.png', width: 18)),
                    hintText: 'เลือกช่วงวันที่',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),

          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 12),

            // 🔍 Search Box
            TextFormField(
              decoration: InputDecoration(
                hintText: 'ค้นหาเลขที่ออเดอร์/เลขขนส่งจีน',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 16),

            // 🔄 Scrollable Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: statuses.length,
                padding: const EdgeInsets.only(right: 4),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final label = statuses[index];
                  final count = statusCounts[label] ?? 0;
                  return _buildStatusChip(label, count, index == selectedStatusIndex, index);
                },
              ),
            ),
            const SizedBox(height: 24),

            // 📦 Parcel List
            Expanded(child: ListView(children: _getCardsForStatus(statuses[selectedStatusIndex]))),
          ],
        ),
      ),
      bottomNavigationBar: selectedStatusIndex == statuses.indexOf('ถึงโกดังไทย') ? _buildBottomPanel() : null,
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE0E0E0)))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎟 คูปองส่วนลด
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('คูปองส่วนลด', style: TextStyle(fontWeight: FontWeight.bold)),
              Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF999999)),
            ],
          ),
          const SizedBox(height: 12),

          // 🚚 ขนส่ง
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('ขนส่งไทย  รถเหมาบริษัท', style: TextStyle(fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () {
                  // ไปหน้าเลือกขนส่ง
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ShippingMethodPage()));
                },
                child: Row(
                  children: const [
                    Text('50฿', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF999999)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ⚠️ แจ้งเตือนภาษี
          GestureDetector(
            onTap: () {
              setState(() {
                isRequestTaxCertificate = !isRequestTaxCertificate;
              });
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF427D9D), width: 2),
                    color: isRequestTaxCertificate ? const Color(0xFF427D9D) : Colors.transparent,
                  ),
                  child: isRequestTaxCertificate ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ขอใบรับรองภาษีหัก ณ ที่จ่าย 1%', style: TextStyle(fontSize: 13)),
                      Text('หากต้องการหัก ณ ที่จ่าย กรุณายืนยันก่อนชำระเงิน', style: TextStyle(fontSize: 12, color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ☑️ Checkbox + ปุ่มเลือกทั้งหมด
          Row(
            children: [
              Checkbox(
                value: isSelectAll,
                onChanged: (val) {
                  setState(() {
                    isSelectAll = val ?? false;
                    _updateAllParcelsSelection();
                  });
                },
                activeColor: const Color(0xFF427D9D),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  setState(() {
                    isSelectAll = !isSelectAll;
                    _updateAllParcelsSelection();
                  });
                },
                child: const Text('เลือกทั้งหมด'),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 🛒 ปุ่มสินค้าทั้งหมด
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF002A5D),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${selectedParcels.length}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF002A5D)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('สินค้าทั้งหมด', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ],
                  ),
                  const Text('8,566.00฿', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
