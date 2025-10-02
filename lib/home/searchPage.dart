import 'package:flutter/material.dart';
import 'package:gcargo/home/cartPage.dart';
import 'package:gcargo/home/notificationPage.dart';
import 'package:get/get.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:gcargo/home/productDetailPage.dart';
import 'package:gcargo/home/widgets/ProductCardFromAPI.dart';

class SearchPage extends StatefulWidget {
  // final List<Map<String, dynamic>> initialSearchResults;
  final List<dynamic> initialSearchResults;
  final String initialSearchQuery;
  final String type;

  const SearchPage({super.key, this.initialSearchResults = const [], this.initialSearchQuery = '', required this.type});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final HomeController homeController;
  late LanguageController languageController;
  // List<Map<String, dynamic>> currentSearchResults = [];
  List<dynamic> currentSearchResults = [];
  String currentSearchQuery = '';
  bool isSearching = false;
  List<String> searchHistory = [];

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'search': 'ค้นหา',
        'search_products': 'ค้นหาสินค้า',
        'search_hint': 'ค้นหาสินค้าที่ต้องการ...',
        'search_history': 'ประวัติการค้นหา',
        'clear_history': 'ล้างประวัติ',
        'no_search_history': 'ไม่มีประวัติการค้นหา',
        'searching': 'กำลังค้นหา...',
        'no_results': 'ไม่พบสินค้าที่ค้นหา',
        'try_different_keywords': 'ลองใช้คำค้นหาอื่น',
        'results_found': 'พบสินค้า',
        'items': 'รายการ',
        'error_occurred': 'เกิดข้อผิดพลาด',
        'try_again': 'ลองใหม่อีกครั้ง',
        'loading': 'กำลังโหลด...',
        'recent_searches': 'การค้นหาล่าสุด',
      },
      'en': {
        'search': 'Search',
        'search_products': 'Search Products',
        'search_hint': 'Search for products...',
        'search_history': 'Search History',
        'clear_history': 'Clear History',
        'no_search_history': 'No search history',
        'searching': 'Searching...',
        'no_results': 'No products found',
        'try_different_keywords': 'Try different keywords',
        'results_found': 'Found',
        'items': 'items',
        'error_occurred': 'An error occurred',
        'try_again': 'Try again',
        'loading': 'Loading...',
        'recent_searches': 'Recent Searches',
      },
      'zh': {
        'search': '搜索',
        'search_products': '搜索商品',
        'search_hint': '搜索商品...',
        'search_history': '搜索历史',
        'clear_history': '清除历史',
        'no_search_history': '无搜索历史',
        'searching': '搜索中...',
        'no_results': '未找到商品',
        'try_different_keywords': '尝试其他关键词',
        'results_found': '找到',
        'items': '项商品',
        'error_occurred': '发生错误',
        'try_again': '重试',
        'loading': '加载中...',
        'recent_searches': '最近搜索',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  void initState() {
    super.initState();
    languageController = Get.find<LanguageController>();

    // Initialize with passed data
    currentSearchResults = widget.initialSearchResults;
    currentSearchQuery = widget.initialSearchQuery;
    searchController.text = widget.initialSearchQuery;
    if (widget.initialSearchQuery.isNotEmpty) {
      searchHistory.add(widget.initialSearchQuery);
    }

    // Get HomeController
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }
  }

  // Method to save search query to history
  void _saveSearchToHistory(String query) {
    if (query.trim().isNotEmpty && !searchHistory.contains(query.trim())) {
      setState(() {
        searchHistory.insert(0, query.trim()); // Add to beginning
        // Keep only last 10 searches
        if (searchHistory.length > 10) {
          searchHistory = searchHistory.take(10).toList();
        }
      });
    }
  }

  // Method to clear search history
  void _clearSearchHistory() {
    setState(() {
      searchHistory.clear();
    });
  }

  // Method to handle search within SearchPage
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('search_hint'))));
      return;
    }

    // Save search query to history every time user searches
    _saveSearchToHistory(query);

    setState(() {
      isSearching = true;
    });

    try {
      // Call API to search
      await homeController.searchItemsFromAPI(query);

      if (mounted) {
        setState(() {
          isSearching = false;
        });

        // Check if we have results
        if (homeController.hasError.value) {
          // Show error message but don't clear current results
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(homeController.errorMessage.value)));
        } else if (homeController.searchItems.isEmpty) {
          // Show no results message but don't clear current results
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(getTranslation('no_results'))));
        } else {
          // Update current results with new search results
          setState(() {
            currentSearchResults = homeController.searchItems;
            currentSearchQuery = query;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isSearching = false;
        });

        // Show error message but don't clear current results
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${getTranslation('error_occurred')}: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Listen to translatedHomeTitles เพื่อให้ UI อัปเดตเมื่อแปลเสร็จ
      homeController.translatedHomeTitles.length;

      return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Top Row
                Row(
                  children: [
                    IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20)),
                    const Text("A100", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          TextFormField(
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            enabled: !isSearching,
                            onFieldSubmitted: (value) {
                              _performSearch(value);
                            },
                            decoration: InputDecoration(
                              hintText: getTranslation('search_hint'),
                              hintStyle: const TextStyle(fontSize: 14),
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (isSearching)
                                    const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                    )
                                  else
                                    IconButton(
                                      icon: const Icon(Icons.search),
                                      onPressed: () {
                                        _performSearch(searchController.text);
                                      },
                                    ),
                                ],
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
                      },
                      child: Image.asset('assets/icons/bag.png', height: 24, width: 24),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationPage()));
                      },
                      child: Image.asset('assets/icons/notification.png', height: 24, width: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 🔹 History
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(getTranslation('search_history'), style: TextStyle(fontWeight: FontWeight.bold)),
                    GestureDetector(onTap: _clearSearchHistory, child: Text(getTranslation('clear_history'), style: TextStyle(color: Colors.grey))),
                  ],
                ),
                const SizedBox(height: 8),

                // Display search history if available, otherwise show default tags
                if (searchHistory.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: searchHistory
                        .map(
                          (query) => GestureDetector(
                            onTap: () {
                              searchController.text = query;
                              _performSearch(query);
                            },
                            child: Chip(
                              label: Text(query),
                              backgroundColor: Colors.blue.shade50,
                              deleteIcon: const Icon(Icons.close, size: 16),
                              onDeleted: () {
                                setState(() {
                                  searchHistory.remove(query);
                                });
                              },
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ] else ...[
                  Text(getTranslation('no_search_history'), style: TextStyle(color: Colors.grey)),
                ],

                const SizedBox(height: 16),

                // Show search results or fallback content
                if (currentSearchResults.isNotEmpty) ...[
                  Text(
                    "${getTranslation('results_found')} \"$currentSearchQuery\" (${currentSearchResults.length} ${getTranslation('items')})",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: currentSearchResults.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.78,
                      ),
                      itemBuilder: (context, index) {
                        final item = currentSearchResults[index];
                        final originalTitle = item['title'] ?? 'ไม่มีชื่อสินค้า';
                        final translatedTitle = homeController.translatedHomeTitles[originalTitle];
                        return ProductCardFromAPI(
                          imageUrl: item['pic_url'] ?? '',
                          title: originalTitle,
                          seller: item['seller_nick'] ?? 'ไม่มีข้อมูลร้านค้า',
                          price: '¥${item['price'] ?? 0}',
                          detailUrl: item['detail_url'] ?? '',
                          translatedTitle: translatedTitle,
                          onTap: () {
                            final rawNumIid = item['num_iid'];
                            final String numIidStr = (rawNumIid is int || rawNumIid is String) ? rawNumIid.toString() : '0';
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ProductDetailPage(num_iid: numIidStr, name: searchController.text, type: widget.type),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Text(getTranslation('no_results'), style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(getTranslation('search_hint'), textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}
