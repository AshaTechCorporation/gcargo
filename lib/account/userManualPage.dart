import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/account/userManualDetailPage.dart';

class UserManualPage extends StatefulWidget {
  const UserManualPage({super.key});

  @override
  State<UserManualPage> createState() => _UserManualPageState();
}

class _UserManualPageState extends State<UserManualPage> {
  late final AccountController accountController;
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {'user_manual': 'คู่มือการใช้งาน', 'no_manual': 'ไม่มีคู่มือการใช้งาน', 'no_manual_title': 'ไม่มีชื่อคู่มือ'},
      'en': {'user_manual': 'User Manual', 'no_manual': 'No User Manual', 'no_manual_title': 'No Manual Title'},
      'zh': {'user_manual': '使用手册', 'no_manual': '暂无使用手册', 'no_manual_title': '无手册标题'},
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
    // Load Manual data
    accountController.getManuals();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(getTranslation('user_manual'), style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
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
                  SizedBox(height: 16),
                  Text(accountController.errorMessage.value, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: () => accountController.refreshData(), child: const Text('ลองใหม่')),
                ],
              ),
            );
          }

          final manuals = accountController.manuals;
          if (manuals.isEmpty) {
            return Center(child: Text(getTranslation('no_manual'), style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: manuals.length,
            itemBuilder: (context, index) {
              final manual = manuals[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => UserManualDetailPage(manual: manual)));
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // 🔹 Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              manual.image != null && manual.image!.isNotEmpty
                                  ? Image.network(
                                    manual.image!,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade200,
                                        child: const Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                  )
                                  : Container(
                                    width: 60,
                                    height: 60,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.description, color: Colors.grey),
                                  ),
                        ),
                        const SizedBox(width: 12),

                        // 🔹 Text
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(manual.name ?? getTranslation('no_manual_title'), style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (manual.description != null && manual.description!.isNotEmpty) ...[
                                // const SizedBox(height: 4),
                                // Text(
                                //   manual.description!,
                                //   style: const TextStyle(color: Colors.grey, fontSize: 12),
                                //   maxLines: 2,
                                //   overflow: TextOverflow.ellipsis,
                                // ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
