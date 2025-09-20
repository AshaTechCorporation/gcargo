import 'package:flutter/material.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class AboutUsPage extends StatefulWidget {
  const AboutUsPage({super.key});

  @override
  State<AboutUsPage> createState() => _AboutUsPageState();
}

class _AboutUsPageState extends State<AboutUsPage> {
  final AccountController accountController = Get.put(AccountController());
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {'about_us': 'เกี่ยวกับเรา', 'no_about_info': 'ไม่มีข้อมูลเกี่ยวกับเรา'},
      'en': {'about_us': 'About Us', 'no_about_info': 'No About Information'},
      'zh': {'about_us': '关于我们', 'no_about_info': '暂无关于我们的信息'},
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    // เรียก API เมื่อเข้าหน้า
    WidgetsBinding.instance.addPostFrameCallback((_) {
      accountController.getTegAboutUs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslation('about_us'), style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        ),
        body: Obx(() {
          if (accountController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (accountController.hasError.value) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(accountController.errorMessage.value, style: TextStyle(fontSize: 16, color: Colors.grey), textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: () => accountController.getTegAboutUs(), child: Text('ลองใหม่')),
                ],
              ),
            );
          }

          final aboutUs = accountController.aboutUs.value;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // แสดงข้อมูลจาก API
                if (aboutUs != null) ...[
                  // Detail section
                  if (aboutUs.detail != null && aboutUs.detail!.isNotEmpty) ...[
                    _buildSection('รายละเอียด', aboutUs.detail),
                    const SizedBox(height: 20),
                  ],

                  // Title Box section
                  if (aboutUs.title_box != null && aboutUs.title_box!.isNotEmpty) ...[
                    _buildSection('หัวข้อ', aboutUs.title_box),
                    const SizedBox(height: 20),
                  ],

                  // Body Box section
                  if (aboutUs.body_box != null && aboutUs.body_box!.isNotEmpty) ...[
                    _buildSection('เนื้อหา', aboutUs.body_box),
                    const SizedBox(height: 20),
                  ],

                  // Footer Box section
                  if (aboutUs.footer_box != null && aboutUs.footer_box!.isNotEmpty) ...[
                    _buildSection('ท้ายเรื่อง', aboutUs.footer_box),
                    const SizedBox(height: 20),
                  ],

                  // Contact Information
                  _buildContactSection(aboutUs),
                ] else ...[
                  // แสดงข้อมูลเดิมถ้าไม่มีข้อมูลจาก API
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSection(String title, [String? content]) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(content ?? '', style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildContactSection(dynamic aboutUs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('ติดต่อเรา', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),

        // Contact Information Cards
        if (aboutUs.phone != null && aboutUs.phone!.isNotEmpty) ...[
          _buildContactCard(Icons.phone, 'โทรศัพท์', aboutUs.phone!),
          const SizedBox(height: 12),
        ],

        if (aboutUs.email != null && aboutUs.email!.isNotEmpty) ...[
          _buildContactCard(Icons.email, 'อีเมล', aboutUs.email!),
          const SizedBox(height: 12),
        ],

        if (aboutUs.line != null && aboutUs.line!.isNotEmpty) ...[_buildContactCard(Icons.chat, 'Line', aboutUs.line!), const SizedBox(height: 12)],

        if (aboutUs.wechat != null && aboutUs.wechat!.isNotEmpty) ...[
          _buildContactCard(Icons.chat_bubble, 'WeChat', aboutUs.wechat!),
          const SizedBox(height: 12),
        ],

        if (aboutUs.facebook != null && aboutUs.facebook!.isNotEmpty) ...[
          _buildContactCard(Icons.facebook, 'Facebook', aboutUs.facebook!),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildContactCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
