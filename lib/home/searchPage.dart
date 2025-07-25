import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/productDetailPage.dart';
import 'package:gcargo/home/widgets/ProductCardFromAPI.dart';
import 'package:gcargo/utils/helpers.dart';

class SearchPage extends StatefulWidget {
  final List<Map<String, dynamic>> initialSearchResults;
  final String initialSearchQuery;

  const SearchPage({super.key, this.initialSearchResults = const [], this.initialSearchQuery = ''});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();
  late final HomeController homeController;
  List<Map<String, dynamic>> currentSearchResults = [];
  String currentSearchQuery = '';
  bool isSearching = false;

  @override
  void initState() {
    super.initState();
    // Initialize with passed data
    currentSearchResults = widget.initialSearchResults;
    currentSearchQuery = widget.initialSearchQuery;
    searchController.text = widget.initialSearchQuery;

    // Get HomeController
    try {
      homeController = Get.find<HomeController>();
    } catch (e) {
      homeController = Get.put(HomeController());
    }
  }

  final List<String> searchTags = ['กระเป๋า', 'รองเท้าผ้าใบ', 'เสื้อฮู้ดฟรีไซส์'];

  // Method to handle search within SearchPage
  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('กรุณากรอกคำค้นหา')));
      return;
    }

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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ไม่พบสินค้าที่ค้นหา')));
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                            hintText: 'คำหาสินค้า',
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
                  Image.asset('assets/icons/bag.png', height: 24, width: 24),
                  const SizedBox(width: 12),
                  Image.asset('assets/icons/notification.png', height: 24, width: 24),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 History
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text("ประวัติการค้นหา", style: TextStyle(fontWeight: FontWeight.bold)),
                  Text("ลบประวัติการค้นหาทั้งหมด", style: TextStyle(color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 8, children: searchTags.map((tag) => Chip(label: Text(tag), backgroundColor: Colors.grey[200])).toList()),

              const SizedBox(height: 16),

              // Show search results or fallback content
              if (currentSearchResults.isNotEmpty) ...[
                Text(
                  "ผลการค้นหา \"$currentSearchQuery\" (${currentSearchResults.length} รายการ)",
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
                      return ProductCardFromAPI(
                        imageUrl: item['pic_url'] ?? '',
                        title: item['title'] ?? 'ไม่มีชื่อสินค้า',
                        seller: item['seller_nick'] ?? 'ไม่มีข้อมูลร้านค้า',
                        price: '¥${item['price'] ?? 0}',
                        detailUrl: item['detail_url'] ?? '',
                        onTap: () {
                          final rawNumIid = item['num_iid'];
                          final String numIidStr = (rawNumIid is int || rawNumIid is String) ? rawNumIid.toString() : '0';
                          Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailPage(num_iid: numIidStr)));
                        },
                      );
                    },
                  ),
                ),
              ] else ...[
                const Text("ยังไม่มีผลการค้นหา", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'กรอกคำค้นหาและกด Enter\nเพื่อค้นหาสินค้า',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
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
  }
}
