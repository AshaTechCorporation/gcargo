import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gcargo/controllers/home_controller.dart';
import 'package:gcargo/home/searchPage.dart';
import 'package:gcargo/services/homeService.dart';
import 'package:gcargo/services/uploadService.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SearchService {
  // ฟังก์ชั่นสำหรับค้นหาด้วยข้อความ
  static Future<void> handleTextSearch({
    required BuildContext context,
    required String query,
    required String selectedType,
  }) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกคำค้นหา')),
      );
      return;
    }

    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // เรียก API ผ่าน HomeController
      final homeController = Get.find<HomeController>();
      await homeController.searchItemsFromAPI(query);

      // ปิด loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // ตรวจสอบผลลัพธ์
      if (homeController.hasError.value) {
        // แสดงข้อผิดพลาด
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(homeController.errorMessage.value)),
          );
        }
      } else if (homeController.searchItems.isEmpty) {
        // ไม่พบผลลัพธ์
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่พบสินค้าที่ค้นหา')),
          );
        }
      } else {
        // ไปหน้า SearchPage พร้อมผลลัพธ์
        if (context.mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchPage(
                initialSearchResults: homeController.searchItems,
                initialSearchQuery: query,
                type: _convertTypeForApi(selectedType),
              ),
            ),
          );
        }
      }
    } catch (e) {
      // ปิด loading และแสดงข้อผิดพลาด
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
        );
      }
    }
  }

  // ฟังก์ชั่นสำหรับค้นหาด้วยรูปภาพ
  static Future<void> handleImageSearch({
    required BuildContext context,
    required XFile image,
    required String selectedType,
  }) async {
    // แสดง loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. อัปโหลดรูปภาพ
      File file = File(image.path);
      final imageUpload = await UoloadService.addImage(
        file: file,
        path: 'uploads/alipay/',
      );

      if (imageUpload != null) {
        // 2. ประมวลผลรูปภาพ
        final imgCode = await HomeService.uploadImage(
          imgcode: 'https://cargo-api.dev-asha9.com/$imageUpload',
        );

        if (imgCode != null && imgCode.isNotEmpty) {
          // 3. ค้นหาด้วยรูปภาพ
          final searchResults = await HomeService.getItemSearchImg(
            searchImg: imgCode,
            type: _convertTypeForApi(selectedType),
          );

          if (searchResults.isNotEmpty) {
            // ปิด loading
            if (context.mounted) {
              Navigator.pop(context);
            }

            // ไปหน้า SearchPage พร้อมผลลัพธ์
            if (context.mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchPage(
                    initialSearchResults: searchResults,
                    initialSearchQuery: 'ค้นหาด้วยรูปภาพ',
                    type: _convertTypeForApi(selectedType),
                  ),
                ),
              );
            }
          } else {
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('ไม่พบสินค้าจากรูปภาพที่ค้นหา')),
              );
            }
          }
        } else {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('ไม่สามารถประมวลผลรูปภาพได้')),
            );
          }
        }
      } else {
        if (context.mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('ไม่สามารถอัปโหลดรูปภาพได้')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')),
        );
      }
    }
  }

  // ฟังก์ชั่นสำหรับแสดง Image Picker Bottom Sheet
  static void showImagePickerBottomSheet({
    required BuildContext context,
    required String selectedType,
  }) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เลือกจากแกลเลอรี่'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.gallery,
                  );
                  if (image != null) {
                    await handleImageSearch(
                      context: context,
                      image: image,
                      selectedType: selectedType,
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('ถ่ายรูป'),
                onTap: () async {
                  Navigator.pop(context);
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(
                    source: ImageSource.camera,
                  );
                  if (image != null) {
                    await handleImageSearch(
                      context: context,
                      image: image,
                      selectedType: selectedType,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ฟังก์ชั่นสำหรับแปลง type สำหรับ API
  static String _convertTypeForApi(String selectedType) {
    return selectedType == 'shopgs1' ? 'taobao' : '1688';
  }
}
