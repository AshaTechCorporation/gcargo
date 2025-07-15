import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

Future<void> showImagePickerBottomSheet({required BuildContext context, required void Function(XFile image) onImagePicked}) async {
  final ImagePicker _picker = ImagePicker();

  showModalBottomSheet(
    context: context,
    builder:
        (_) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ถ่ายรูป'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    onImagePicked(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('เลือกรูปจากคลัง'),
                onTap: () async {
                  Navigator.pop(context);
                  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    onImagePicked(image);
                  }
                },
              ),
            ],
          ),
        ),
  );
}
