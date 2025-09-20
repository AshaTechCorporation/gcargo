import 'package:flutter/material.dart';
import 'package:gcargo/account/promotionDetailPage.dart';
import 'package:gcargo/controllers/account_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';

class NewsPromotionPage extends StatefulWidget {
  const NewsPromotionPage({super.key});

  @override
  State<NewsPromotionPage> createState() => _NewsPromotionPageState();
}

class _NewsPromotionPageState extends State<NewsPromotionPage> {
  late final AccountController accountController;
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {'news_promotion': 'ข่าวสาร & โปรโมชั่น', 'try_again': 'ลองใหม่', 'no_news': 'ไม่มีข่าวสาร'},
      'en': {'news_promotion': 'News & Promotions', 'try_again': 'Try Again', 'no_news': 'No News'},
      'zh': {'news_promotion': '新闻与促销', 'try_again': '重试', 'no_news': '暂无新闻'},
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
    // Load News data
    accountController.getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(getTranslation('news_promotion'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          centerTitle: false,
          elevation: 0.5,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20), onPressed: () => Navigator.pop(context)),
        ),
        backgroundColor: Colors.white,
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
                  ElevatedButton(onPressed: () => accountController.refreshData(), child: Text(getTranslation('try_again'))),
                ],
              ),
            );
          }

          final news = accountController.news;
          if (news.isEmpty) {
            return Center(child: Text(getTranslation('no_news'), style: TextStyle(fontSize: 16, color: Colors.grey)));
          }

          return ListView.separated(
            padding: EdgeInsets.all(16),
            itemCount: news.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final newpromo = news[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PromotionDetailPage(newpromo: newpromo)));
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  padding: EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child:
                            newpromo.image != null && newpromo.image!.isNotEmpty
                                ? Image.network(
                                  newpromo.image!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: Icon(Icons.image_not_supported, color: Colors.grey),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 60,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                      child: Center(child: CircularProgressIndicator()),
                                    );
                                  },
                                )
                                : Container(width: 60, height: 60, color: Colors.grey.shade200, child: Icon(Icons.description, color: Colors.grey)),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(newpromo.name!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            SizedBox(height: 4),
                            Text(newpromo.description!, style: TextStyle(color: Colors.black54, fontSize: 13), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
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
