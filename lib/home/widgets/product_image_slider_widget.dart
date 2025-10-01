import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gcargo/controllers/product_detail_controller.dart';
import 'package:gcargo/utils/helpers.dart';
import 'package:get/get.dart';

class ProductImageSliderWidget extends StatefulWidget {
  final ProductDetailController productController;

  const ProductImageSliderWidget({super.key, required this.productController});

  @override
  State<ProductImageSliderWidget> createState() => _ProductImageSliderWidgetState();
}

class _ProductImageSliderWidgetState extends State<ProductImageSliderWidget> {
  final PageController _pageController = PageController();
  int selectedImage = 0;
  Timer? _timer;

  // Fallback images
  final List<String> fallbackImages = [
    'assets/images/No_Image.jpg',
    'assets/images/No_Image.jpg',
    'assets/images/No_Image.jpg',
    'assets/images/No_Image.jpg',
  ];

  String _lastSelectedKey = '';

  @override
  void initState() {
    super.initState();
    // ปิด auto slide - ให้เปลี่ยนแค่เมื่อกดเลือกสี/ไซส์หรือกดจุดด้านล่าง
    // _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients) {
        final allImages = widget.productController.allImages;
        final imagesToShow = allImages.isNotEmpty ? allImages : fallbackImages;

        if (imagesToShow.length > 1) {
          final nextPage = (selectedImage + 1) % imagesToShow.length;
          _pageController.animateToPage(nextPage, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      }
    });
  }

  void _stopAutoSlide() {
    _timer?.cancel();
  }

  void _restartAutoSlide() {
    _stopAutoSlide();
    _startAutoSlide();
  }

  Widget _buildSingleImage(String imageUrl, bool isUsingApiImages) {
    if (isUsingApiImages) {
      // Display API images
      final formattedUrl = formatImageUrl(imageUrl);
      return Image.network(
        formattedUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover, // ใช้ cover เพื่อให้รูปเต็มพื้นที่แต่คงอัตราส่วน
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade200,
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.grey.shade200,
            child: const Center(child: CircularProgressIndicator()),
          );
        },
      );
    } else {
      // Display fallback asset images
      return Image.asset(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover, // ใช้ cover เพื่อให้รูปเต็มพื้นที่แต่คงอัตราส่วน
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (widget.productController.isLoading.value) {
        return Container(
          height: 200,
          decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      // Get all images from API (prop_imgs)
      final allImages = widget.productController.allImages;
      final selectedKey = widget.productController.selectedOptionKey.value;

      // If no images from API, use fallback images
      final imagesToShow = allImages.isNotEmpty ? allImages : fallbackImages;
      final isUsingApiImages = allImages.isNotEmpty;

      // Jump to selected option image when option changes
      if (_lastSelectedKey != selectedKey && selectedKey.isNotEmpty) {
        _lastSelectedKey = selectedKey;

        // Find index of selected option image
        final optionImage = widget.productController.getImageForOption(selectedKey);
        print('🔍 Selected key: $selectedKey');
        print('🔍 Option image: $optionImage');
        print('🔍 All images: $imagesToShow');

        final targetIndex = imagesToShow.indexOf(optionImage);
        print('🔍 Target index: $targetIndex');

        if (targetIndex >= 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_pageController.hasClients && mounted) {
              print('🔍 Jumping to page: $targetIndex');
              _pageController.jumpToPage(targetIndex);
              setState(() {
                selectedImage = targetIndex;
              });
            }
          });
        } else {
          print('🔍 Image not found in list!');
        }
      }

      return Column(
        children: [
          // Image Slider with 1:1 aspect ratio
          AspectRatio(
            aspectRatio: 1.0, // 1:1 aspect ratio
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child:
                  imagesToShow.length == 1
                      ? _buildSingleImage(imagesToShow[0], isUsingApiImages)
                      : PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            selectedImage = index;
                          });
                        },
                        itemCount: imagesToShow.length,
                        itemBuilder: (context, index) {
                          final imageUrl = imagesToShow[index];
                          return _buildSingleImage(imageUrl, isUsingApiImages);
                        },
                      ),
            ),
          ),

          // Page Indicators
          if (imagesToShow.length > 1) ...[
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  imagesToShow.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(shape: BoxShape.circle, color: selectedImage == index ? Colors.black : Colors.grey.shade300),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }
}
