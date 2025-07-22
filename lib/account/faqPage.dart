import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gcargo/controllers/account_controller.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  late final AccountController accountController;
  final Map<int, bool> expandedItems = {};

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('คำถามที่พบบ่อย', style: TextStyle(color: Colors.black)),
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
          return const Center(child: Text('ไม่มีคำถามที่พบบ่อย', style: TextStyle(fontSize: 16, color: Colors.grey)));
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
                              Text(faq.question ?? 'ไม่มีคำถาม', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('แสดงเพิ่มเติม', style: TextStyle(color: Colors.grey)),
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
                                Text(faq.question ?? 'ไม่มีคำถาม', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Text(faq.answer ?? 'ไม่มีคำตอบ', style: const TextStyle(fontSize: 14)),
                                const SizedBox(height: 12),
                                Center(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        expandedItems[index] = false;
                                      });
                                    },
                                    child: const Text('แสดงน้อยลง', style: TextStyle(color: Colors.grey)),
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
    );
  }
}
