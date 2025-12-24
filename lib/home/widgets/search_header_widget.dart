import 'package:flutter/material.dart';
import 'package:gcargo/controllers/language_controller.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SearchHeaderWidget extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback? onBagTap;
  final VoidCallback? onNotificationTap;
  final Function(XFile)? onImagePicked;
  final Function(String)? onFieldSubmitted;
  final int cartItemCount;

  const SearchHeaderWidget({
    super.key,
    required this.searchController,
    this.onBagTap,
    this.onNotificationTap,
    this.onImagePicked,
    this.onFieldSubmitted,
    this.cartItemCount = 0,
  });

  String getTranslation(String key) {
    final languageController = Get.find<LanguageController>();
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {
        'search_products': 'ค้นหาสินค้า',
        'select_from_gallery': 'เลือกจากแกลเลอรี่',
        'take_photo': 'ถ่ายรูป',
        'image_picker_title': 'เลือกรูปภาพ',
        'camera': 'กล้อง',
        'gallery': 'แกลเลอรี่',
      },
      'en': {
        'search_products': 'Search products',
        'select_from_gallery': 'Select from Gallery',
        'take_photo': 'Take Photo',
        'image_picker_title': 'Select Image',
        'camera': 'Camera',
        'gallery': 'Gallery',
      },
      'zh': {
        'search_products': '搜索商品',
        'select_from_gallery': '从相册选择',
        'take_photo': '拍照',
        'image_picker_title': '选择图片',
        'camera': '相机',
        'gallery': '相册',
      },
    };

    return translations[currentLang]?[key] ?? key;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: searchController,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: getTranslation('search_products'),
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(color: Colors.black),
                      onFieldSubmitted: onFieldSubmitted,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      showImagePickerBottomSheet(context: context, onImagePicked: onImagePicked);
                    },
                    child: Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600, size: 20),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onBagTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Image.asset('assets/icons/bag.png', height: 24, width: 24),
                if (cartItemCount > 0)
                  Positioned(
                    right: -8,
                    top: -8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartItemCount > 99 ? '99+' : cartItemCount.toString(),
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(onTap: onNotificationTap, child: Image.asset('assets/icons/notification.png', height: 24, width: 24)),
        ],
      ),
    );
  }
}

// Helper function สำหรับ image picker bottom sheet
void showImagePickerBottomSheet({required BuildContext context, Function(XFile)? onImagePicked}) {
  final languageController = Get.find<LanguageController>();

  String getTranslation(String key) {
    final currentLang = languageController.currentLanguage.value;

    final translations = {
      'th': {'select_from_gallery': 'เลือกจากแกลเลอรี่', 'take_photo': 'ถ่ายรูป'},
      'en': {'select_from_gallery': 'Select from Gallery', 'take_photo': 'Take Photo'},
      'zh': {'select_from_gallery': '从相册选择', 'take_photo': '拍照'},
    };

    return translations[currentLang]?[key] ?? key;
  }

  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Obx(
        () => SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(getTranslation('select_from_gallery')),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null && onImagePicked != null) {
                    onImagePicked(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: Text(getTranslation('take_photo')),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null && onImagePicked != null) {
                    onImagePicked(image);
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
