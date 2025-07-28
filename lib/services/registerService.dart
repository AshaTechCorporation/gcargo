import 'dart:io';

import 'package:dio/dio.dart';
import 'package:gcargo/constants.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/utils/ApiExeption.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:shared_preferences/shared_preferences.dart';

class RegisterService {
  const RegisterService();

  static Future<User> register({
    required String member_type,
    String? fname,
    String? lname,
    String? phone,
    String? password,
    String? birth_date,
    String? gender,
    String? importer_code,
    String? referrer,
    String? comp_name,
    String? comp_tax,
    String? comp_phone,
    String? cargo_name,
    String? cargo_website,
    String? cargo_image,
    String? order_quantity_in_thai,
    String? live_address,
    String? live_province,
    String? live_district,
    String? live_sub_district,
    String? live_postal_code,
    String? address,
    String? province,
    String? district,
    String? sub_district,
    String? postal_code,
    String? email,
    double? latitude,
    double? longitude,
    int? transport_thai_master_id,
    String? ever_imported_from_china,
    String? order_quantity,
    String? frequent_importer,
    String? need_transport_type,
    String? additional_requests,
    String? image,
  }) async {
    // final SharedPreferences prefs = await SharedPreferences.getInstance();
    // final domain = prefs.getString('domain');
    var headers = {'Content-Type': 'application/json'};
    final url = Uri.https(publicUrl, '/public/api/member');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        'member_type': member_type,
        'fname': fname,
        'lname': lname,
        'phone': phone,
        'password': password,
        'birth_date': birth_date,
        'gender': gender,
        'importer_code': importer_code,
        'referrer': referrer,
        'comp_name': comp_name,
        'comp_tax': comp_tax,
        'comp_phone': comp_phone,
        'cargo_name': cargo_name,
        'cargo_website': cargo_website,
        'cargo_image': cargo_image,
        'order_quantity_in_thai': order_quantity_in_thai,
        'live_address': live_address,
        'live_province': live_province,
        'live_district': live_district,
        'live_sub_district': live_sub_district,
        'live_postal_code': live_postal_code,
        'address': address,
        'province': province,
        'district': district,
        'sub_district': sub_district,
        'postal_code': postal_code,
        "email": email,
        'latitude': latitude,
        'longitude': longitude,
        'transport_thai_master_id': transport_thai_master_id,
        'ever_imported_from_china': ever_imported_from_china,
        'order_quantity': order_quantity,
        'frequent_importer': frequent_importer,
        'need_transport_type': need_transport_type,
        'additional_requests': additional_requests,
        'image': image,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = convert.jsonDecode(response.body);
      return User.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  static Future registerImporter({
    String? comp_name,
    String? comp_tax,
    bool? registered,
    String? address,
    String? province,
    String? district,
    String? sub_district,
    String? postal_code,
    String? authorized_person,
    String? authorized_person_phone,
    String? authorized_person_email,
    String? id_card_picture,
    String? certificate_book_file,
    String? tax_book_file,
    String? logo_file,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    var headers = {'Content-Type': 'application/json'};
    final url = Uri.https(publicUrl, '/public/api/register_importer');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "member_id": userID,
        'comp_name': comp_name,
        'comp_tax': comp_tax,
        'registered': registered,
        'address': address,
        'province': province,
        'district': district,
        'sub_district': sub_district,
        'postal_code': postal_code,
        'authorized_person': authorized_person,
        'authorized_person_phone': authorized_person_phone,
        'authorized_person_email': authorized_person_email,
        'id_card_picture': id_card_picture,
        'certificate_book_file': certificate_book_file,
        'tax_book_file': tax_book_file,
        'logo_file': logo_file,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  static Future addImage({File? file, required String path}) async {
    const apiUrl = '$baseUrl/public/api/upload_images';
    // final token = prefs.getString('token');
    final headers = {
      // 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
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
    // final token = prefs.getString('token');
    final headers = {
      // 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
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
