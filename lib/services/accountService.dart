import 'package:gcargo/models/faq.dart';
import 'package:gcargo/models/manual.dart';
import 'package:gcargo/models/tegaboutus.dart';
import 'package:gcargo/models/wallettrans.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;
import 'package:gcargo/utils/ApiExeption.dart';
import 'package:gcargo/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService {
  const AccountService();

  //เรียกดูข้อมูล FAQ
  static Future<List<Faq>> getFaqs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/get_faq');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => Faq.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //เรียกดูข้อมูล Manual
  static Future<List<Manual>> getManuals() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/get_manual');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => Manual.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //
  static Future<List<Manual>> getNews() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/get_news');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => Manual.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //เกี่ยวกับ
  static Future<Tegaboutus> getTegAboutUs() async {
    var headers = {'Content-Type': 'application/json'};
    final url = Uri.https(publicUrl, '/public/api/get_about_us');
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return Tegaboutus.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //เติมเงิน wallet
  static Future<WalletTrans> walletTrans({String? amount}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userID = prefs.getInt('userID');
    var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final url = Uri.https(publicUrl, '/public/api/wallet_trans');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "member_id": userID,
        "in_from": "wallet",
        "out_to": null,
        "reference_id": "",
        "detail": "เติมเงิน",
        "amount": amount,
        "type": "I",
      }),
    );
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return WalletTrans.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //ดูรายการ wallet ที่เติม
  static Future<List<WalletTrans>> getListWalletTrans() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userID = prefs.getInt('userID');
    var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final url = Uri.https(publicUrl, '/public/api/get_wallet_trans/$userID');
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => WalletTrans.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //ดูรายการคูปอง
  static Future<List<Map<String, dynamic>>> getCoupons() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/coupon_page');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "draw": 1,
        "order": [
          {"column": 0, "dir": "asc"},
        ],
        "start": 0,
        "length": 10,
        "search": {"value": "", "regex": false},
      }),
    );
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data']['data'] as List;
      return List<Map<String, dynamic>>.from(list);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }
}
