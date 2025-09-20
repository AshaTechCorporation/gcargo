import 'package:flutter/material.dart';
import 'package:gcargo/constants.dart'; // ✅ ต้องมี kButtonColor
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';

class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;
  late LanguageController languageController;

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'favorites': 'รายการโปรด',
        'no_favorites': 'ไม่มีรายการโปรด',
        'add_favorites_message': 'เพิ่มสินค้าที่คุณชื่นชอบเพื่อดูในภายหลัง',
        'remove': 'ลบ',
        'loading': 'กำลังโหลด...',
      },
      'en': {
        'favorites': 'Favorites',
        'no_favorites': 'No Favorites',
        'add_favorites_message': 'Add products you like to view later',
        'remove': 'Remove',
        'loading': 'Loading...',
      },
      'zh': {'favorites': '收藏夹', 'no_favorites': '暂无收藏', 'add_favorites_message': '添加您喜欢的产品以便稍后查看', 'remove': '删除', 'loading': '加载中...'},
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final box = await Hive.openBox('favorites');
      final favoriteItems = <Map<String, dynamic>>[];

      for (String key in box.keys) {
        if (key.endsWith('_favorite')) {
          final item = box.get(key);
          if (item is Map) {
            favoriteItems.add(Map<String, dynamic>.from(item));
          }
        }
      }

      setState(() {
        favorites = favoriteItems;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading favorites: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFavorite(String numIid) async {
    try {
      final box = await Hive.openBox('favorites');
      final favoriteKey = '${numIid}_favorite';
      await box.delete(favoriteKey);

      // รีโหลดข้อมูล
      await _loadFavorites();
    } catch (e) {
      print('Error removing favorite: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
          title: Text(getTranslation('favorites'), style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child:
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : favorites.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(getTranslation('no_favorites'), style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  )
                  : GridView.builder(
                    itemCount: favorites.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.74,
                    ),
                    itemBuilder: (context, index) {
                      final item = favorites[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 🔹 Image + heart
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                  child:
                                      item['pic_url'] != null && item['pic_url'].isNotEmpty
                                          ? Image.network(
                                            formatImageUrl(item['pic_url']),
                                            height: 120,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                height: 120,
                                                color: Colors.grey.shade200,
                                                child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                              );
                                            },
                                          )
                                          : Container(
                                            height: 120,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                          ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _removeFavorite(item['num_iid'] ?? ''),
                                    child: const Icon(Icons.favorite, color: kButtonColor, size: 20),
                                  ),
                                ),
                              ],
                            ),
                            // 🔹 Details
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['title'] ?? 'ไม่มีชื่อสินค้า',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item['brand'] ?? 'ไม่มีข้อมูลแบรนด์',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '฿${item['price']?.toString() ?? '0'}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
        ),
      ),
    );
  }
}
