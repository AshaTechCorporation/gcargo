import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/account/userManualDetailPage.dart';

class UserManualPage extends StatefulWidget {
  const UserManualPage({super.key});

  @override
  State<UserManualPage> createState() => _UserManualPageState();
}

class _UserManualPageState extends State<UserManualPage> {
  late final AccountController accountController;

  @override
  void initState() {
    super.initState();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('คู่มือการใช้งาน', style: TextStyle(color: Colors.black)),
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
          return Center(child: Text('ไม่มีคู่มือการใช้งาน', style: TextStyle(fontSize: 16, color: Colors.grey)));
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
                            Text(manual.name ?? 'ไม่มีชื่อคู่มือ', style: const TextStyle(fontWeight: FontWeight.bold)),
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
    );
  }
}
