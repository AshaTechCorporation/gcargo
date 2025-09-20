import 'package:flutter/material.dart';
import 'package:gcargo/account/addAddressPage.dart';
import 'package:gcargo/account/editAddressPage.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class AddressListPage extends StatefulWidget {
  const AddressListPage({super.key});

  @override
  State<AddressListPage> createState() => _AddressListPageState();
}

class _AddressListPageState extends State<AddressListPage> {
  late final AccountController accountController;
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'shipping_address': 'ที่อยู่จัดส่ง',
        'no_address': 'ไม่มีที่อยู่จัดส่ง',
        'add_address': 'เพิ่มที่อยู่',
        'edit': 'แก้ไข',
        'delete': 'ลบ',
        'set_default': 'ตั้งเป็นค่าเริ่มต้น',
        'confirm': 'ยืนยัน',
        'cancel': 'ยกเลิก',
        'delete_address': 'ลบที่อยู่',
        'delete_confirm': 'คุณต้องการลบที่อยู่นี้หรือไม่?',
        'success': 'สำเร็จ',
        'error': 'เกิดข้อผิดพลาด',
        'backup_phone': 'เบอร์สำรอง',
      },
      'en': {
        'shipping_address': 'Shipping Address',
        'no_address': 'No Shipping Address',
        'add_address': 'Add Address',
        'edit': 'Edit',
        'delete': 'Delete',
        'set_default': 'Set as Default',
        'confirm': 'Confirm',
        'cancel': 'Cancel',
        'delete_address': 'Delete Address',
        'delete_confirm': 'Do you want to delete this address?',
        'success': 'Success',
        'error': 'Error',
        'backup_phone': 'Backup Phone',
      },
      'zh': {
        'shipping_address': '收货地址',
        'no_address': '暂无收货地址',
        'add_address': '添加地址',
        'edit': '编辑',
        'delete': '删除',
        'set_default': '设为默认',
        'confirm': '确认',
        'cancel': '取消',
        'delete_address': '删除地址',
        'delete_confirm': '您要删除此地址吗？',
        'success': '成功',
        'error': '错误',
        'backup_phone': '备用电话',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    accountController = Get.put(AccountController());
    // เรียก API เมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      accountController.getUserById();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 0,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
              Text(getTranslation('shipping_address'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
            ],
          ),
        ),
        body: Column(
          children: [
            SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                final user = accountController.user.value;
                final addresses = user?.ship_address ?? [];

                if (accountController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (accountController.hasError.value) {
                  return Center(child: Text(accountController.errorMessage.value));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final item = addresses[index];
                    return Container(
                      margin: EdgeInsets.only(bottom: 16),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 🔹 Header row
                          Row(
                            children: [
                              Image.asset('assets/icons/VectorPerson.png', width: 32),
                              SizedBox(width: 8),
                              Expanded(child: Text(item.contact_name ?? 'ไม่มีชื่อ', style: TextStyle(fontWeight: FontWeight.bold))),
                              Text(item.contact_phone ?? 'ไม่มีเบอร์'),
                            ],
                          ),
                          SizedBox(height: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${item.address ?? ''}'),
                              Text('${item.sub_district ?? ''} ${item.district ?? ''} ${item.province ?? ''} ${item.postal_code ?? ''}'),
                              if (item.contact_phone2 != null && item.contact_phone2!.isNotEmpty)
                                Text('${getTranslation('backup_phone')}: ${item.contact_phone2}', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => EditAddressPage(address: item)),
                                  );

                                  // ถ้าแก้ไขสำเร็จ ให้โหลดข้อมูลใหม่
                                  if (result == true) {
                                    accountController.getUserById();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: kButtonColor,
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(getTranslation('edit'), style: TextStyle(color: Colors.white)),
                              ),
                              SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(getTranslation('delete')),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
            Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () async {
                    final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => AddAddressPage()));

                    // ถ้าเพิ่มที่อยู่สำเร็จ ให้โหลดข้อมูลใหม่
                    if (result == true) {
                      accountController.getUserById();
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(getTranslation('add_address'), style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
