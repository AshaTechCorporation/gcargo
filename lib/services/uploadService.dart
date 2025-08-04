import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gcargo/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UoloadService {
  static uploadImage(XFile file) async {
    var formData = FormData.fromMap({'image': await MultipartFile.fromFile(file.path, filename: file.name), 'path': 'images/asset/'});

    final res = await Dio().post(
      'https://g-cargo.dev-asha9.com/public/api/upload_images',
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data; boundary=<calculated when request is sent>'}),
    );

    if (res.statusCode == 200 || res.statusCode == 201) {
      return res.data['data'];
    } else {
      throw Exception('อัพโหดลไฟล์ล้มเหลว');
    }
  }

  static Future addImage({File? file, required String path}) async {
    const apiUrl = '$baseUrl/public/api/upload_images';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    var formData = FormData.fromMap({'image': await MultipartFile.fromFile(file!.path), 'path': path});
    final response = await Dio().post(apiUrl, data: formData, options: Options(headers: headers));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'];
      return data;
    } else {
      throw Exception('อัพโหดลไฟล์ล้มเหลว');
    }
  }

  static Future addFile({File? file, required String path}) async {
    const apiUrl = '$baseUrl/public/api/upload_file';
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    var formData = FormData.fromMap({'file': await MultipartFile.fromFile(file!.path), 'path': path});
    final response = await Dio().post(apiUrl, data: formData, options: Options(headers: headers));

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['path'];
      return data;
    } else {
      throw Exception('อัพโหดลไฟล์ล้มเหลว');
    }
  }
}

class UploadResponse {
  UploadResponse({
    required this.fieldname,
    required this.originalname,
    required this.encoding,
    required this.mimetype,
    required this.destination,
    required this.filename,
    required this.path,
    required this.size,
    required this.id,
    required this.photo_test,
    required this.photo_test_url,
  });
  late final String fieldname;
  late final String originalname;
  late final String encoding;
  late final String mimetype;
  late final String destination;
  late final String filename;
  late final String path;
  late final int size;
  late final int id;
  late final String photo_test;
  late final String photo_test_url;

  UploadResponse.fromJson(Map<String, dynamic> json) {
    fieldname = json['fieldname'];
    originalname = json['originalname'];
    encoding = json['encoding'];
    mimetype = json['mimetype'];
    destination = json['destination'];
    filename = json['filename'];
    path = json['path'];
    size = json['size'];
    id = json['id'];
    photo_test = json['photo_test'];
    photo_test_url = json['photo_test_url'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['fieldname'] = fieldname;
    data['originalname'] = originalname;
    data['encoding'] = encoding;
    data['mimetype'] = mimetype;
    data['destination'] = destination;
    data['filename'] = filename;
    data['path'] = path;
    data['size'] = size;
    data['id'] = id;
    data['photo_test'] = photo_test;
    data['photo_test_url'] = photo_test_url;
    return data;
  }
}
