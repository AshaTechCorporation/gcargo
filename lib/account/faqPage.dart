import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  late final AccountController accountController;
  late LanguageController languageController;
  final Map<int, bool> expandedItems = {};

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'faq': 'คำถามที่พบบ่อย',
        'no_faq': 'ไม่มีคำถามที่พบบ่อย',
        'no_question': 'ไม่มีคำถาม',
        'no_answer': 'ไม่มีคำตอบ',
        'show_more': 'แสดงเพิ่มเติม',
        'show_less': 'แสดงน้อยลง',
      },
      'en': {
        'faq': 'FAQ',
        'no_faq': 'No FAQ Available',
        'no_question': 'No Question',
        'no_answer': 'No Answer',
        'show_more': 'Show More',
        'show_less': 'Show Less',
      },
      'zh': {'faq': '常见问题', 'no_faq': '暂无常见问题', 'no_question': '无问题', 'no_answer': '无答案', 'show_more': '显示更多', 'show_less': '显示更少'},
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    // Initialize AccountController
    try {
      accountController = Get.find<AccountController>();
    } catch (e) {
      accountController = Get.put(AccountController());
    }
    // Load FAQ data
    accountController.getFaqs();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslation('faq'), style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
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
                  Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(accountController.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: () => accountController.refreshData(), child: const Text('ลองใหม่')),
                ],
              ),
            );
          }

          final faqs = accountController.faqs;
          if (faqs.isEmpty) {
            return Center(child: Text(getTranslation('no_faq'), style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children:
                  faqs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final faq = entry.value;
                    final isExpanded = expandedItems[index] ?? false;

                    return Column(
                      children: [
                        Card(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faq.question ?? getTranslation('no_question'),
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(getTranslation('show_more'), style: TextStyle(color: Colors.grey)),
                                    IconButton(
                                      icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                      onPressed: () {
                                        setState(() {
                                          expandedItems[index] = !isExpanded;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        if (isExpanded) ...[
                          const SizedBox(height: 12),
                          Card(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    faq.question ?? getTranslation('no_question'),
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(faq.answer ?? getTranslation('no_answer'), style: const TextStyle(fontSize: 14)),
                                  const SizedBox(height: 12),
                                  Center(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          expandedItems[index] = false;
                                        });
                                      },
                                      child: Text(getTranslation('show_less'), style: TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
            ),
          );
        }),
      ),
    );
  }
}
