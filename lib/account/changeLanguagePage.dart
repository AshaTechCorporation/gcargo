import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gcargo/controllers/language_controller.dart';

class ChangeLanguagePage extends StatefulWidget {
  const ChangeLanguagePage({super.key});

  @override
  State<ChangeLanguagePage> createState() => _ChangeLanguagePageState();
}

class _ChangeLanguagePageState extends State<ChangeLanguagePage> {
  String selectedLang = 'ไทย';

  final List<Map<String, String>> languages = [
    {'name': 'ไทย', 'code': 'th'},
    {'name': 'จีน', 'code': 'zh'},
    {'name': 'อังกฤษ', 'code': 'en'},
  ];

  @override
  void initState() {
    super.initState();
    // ตั้งค่าภาษาปัจจุบัน
    final currentLocale = Get.locale?.languageCode ?? 'th';
    final currentLang = languages.firstWhere((lang) => lang['code'] == currentLocale, orElse: () => languages[0]);
    selectedLang = currentLang['name']!;
  }

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF002D65);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('เปลี่ยนภาษา'.tr, style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              itemCount: languages.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final lang = languages[index];
                final langName = lang['name']!;
                return ListTile(
                  title: Text(langName),
                  trailing: Radio<String>(
                    value: langName,
                    groupValue: selectedLang,
                    onChanged: (value) => setState(() => selectedLang = value!),
                    activeColor: themeColor,
                  ),
                  onTap: () => setState(() => selectedLang = langName),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: themeColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  // หาภาษาที่เลือก
                  final selectedLanguage = languages.firstWhere((lang) => lang['name'] == selectedLang);
                  final languageCode = selectedLanguage['code']!;

                  // เปลี่ยนภาษาผ่าน LanguageController
                  final languageController = Get.find<LanguageController>();
                  await languageController.changeLanguage(languageCode);

                  // แสดงข้อความสำเร็จ
                  Get.snackbar(
                    'สำเร็จ',
                    'เปลี่ยนภาษาเรียบร้อยแล้ว',
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: Duration(seconds: 2),
                  );

                  // กลับไปหน้าก่อนหน้า
                  Get.back();
                },
                child: Text('Common.confirm'.tr, style: const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
