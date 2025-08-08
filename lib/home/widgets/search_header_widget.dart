import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SearchHeaderWidget extends StatelessWidget {
  final TextEditingController searchController;
  final VoidCallback? onBagTap;
  final VoidCallback? onNotificationTap;
  final Function(XFile)? onImagePicked;

  const SearchHeaderWidget({
    super.key,
    required this.searchController,
    this.onBagTap,
    this.onNotificationTap,
    this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: 'ค้นหาสินค้า',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    showImagePickerBottomSheet(
                      context: context,
                      onImagePicked: onImagePicked,
                    );
                  },
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.grey.shade600,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onBagTap,
          child: Image.asset('assets/icons/bag.png', height: 24, width: 24),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: onNotificationTap,
          child: Image.asset('assets/icons/notification.png', height: 24, width: 24),
        ),
      ],
    );
  }
}

// Helper function สำหรับ image picker bottom sheet
void showImagePickerBottomSheet({
  required BuildContext context,
  Function(XFile)? onImagePicked,
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
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null && onImagePicked != null) {
                  onImagePicked!(image);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('ถ่ายรูป'),
              onTap: () async {
                Navigator.pop(context);
                final ImagePicker picker = ImagePicker();
                final XFile? image = await picker.pickImage(source: ImageSource.camera);
                if (image != null && onImagePicked != null) {
                  onImagePicked!(image);
                }
              },
            ),
          ],
        ),
      );
    },
  );
}
