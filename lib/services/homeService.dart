import 'dart:io';

import 'package:gcargo/constants.dart';
import 'package:gcargo/models/imgbanner.dart';
import 'package:gcargo/models/orders/serviceTransporterById.dart';
import 'package:gcargo/models/payment.dart';
import 'package:gcargo/models/products.dart';
import 'package:gcargo/models/rateExchange.dart';
import 'package:gcargo/models/rateShip.dart';
import 'package:gcargo/models/transferFee.dart';
import 'package:gcargo/models/user.dart';
import 'package:gcargo/utils/ApiExeption.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:shared_preferences/shared_preferences.dart';

class HomeService {
  const HomeService();

  //เรียกดูข้อมูล Category
  // static Future<List<Categories>> getCategories({required String name}) async {
  //   final url = Uri.https('api.atphosting24.com', '/category/api.php', {"folder": '$name'});
  //   var headers = {'Content-Type': 'application/json'};
  //   final response = await http.get(
  //     headers: headers,
  //     url,
  //   );
  //   if (response.statusCode == 200) {
  //     final data = convert.jsonDecode(response.body);
  //     final list = data['categories'] as List;
  //     return list.map((e) => Categories.fromJson(e)).toList();
  //   } else {
  //     final data = convert.jsonDecode(response.body);
  //     throw ApiException(data['message']);
  //   }
  // }

  static Future getItemSearch({required String search, required String type, required int page}) async {
    final url = Uri.https('api.icom.la', '/$type/api/call.php', {
      "item_search": 'item_search',
      "lang": 'zh-CN',
      "q": '$search',
      "page": '$page',
      "api_key": 'tegcargo06062024',
      "is_promotion": '1',
    });

    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      try {
        final data = convert.jsonDecode(response.body);
        throw ApiException(data['message'] ?? 'เกิดข้อผิดพลาดจากเซิร์ฟเวอร์');
      } catch (_) {
        throw ApiException('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ (${response.statusCode})');
      }
    }
  }

  //ดูข้อมูลรายละเอียดสินค้า
  static Future getItemDetail({required String num_id, required String type}) async {
    final url = Uri.https('api.icom.la', '/$type/api/call.php', {
      "item_get": '',
      "lang": 'zh-CN',
      "num_iid": '$num_id',
      "api_key": 'tegcargo06062024',
      "is_promotion": '1',
    });
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url).timeout(const Duration(seconds: 30));
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      // return data['item'];
      //return ItemSearch.fromJson(data['item']);
      if (data is Map && data.containsKey('item') && data['item'] != null) {
        final item = data['item'];

        final isPropsListEmpty = item['props_list'] is List && (item['props_list'] as List).isEmpty;
        final isPropsNameEmpty = item['props_name'] is String && (item['props_name'] as String).trim().isEmpty;

        if (isPropsListEmpty && isPropsNameEmpty) {
          throw ApiException("ไม่พบข้อมูลรายละเอียดสินค้า (props_list & props_name ว่างเปล่า)");
        }

        return item;
      } else {
        // กรณีไม่มี item
        throw ApiException("ไม่พบข้อมูลสินค้า หรือ API ส่งข้อมูลผิดพลาด");
      }
    } else {
      // final data = convert.jsonDecode(response.body);
      // throw ApiException(data['message']);
      try {
        final data = convert.jsonDecode(response.body);
        throw ApiException(data['message'] ?? 'เกิดข้อผิดพลาดที่ไม่รู้จัก');
      } catch (e) {
        throw ApiException('ไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ได้ (${response.statusCode})');
      }
    }
  }

  //อัปโหลดรูป
  static Future uploadImage({required String imgcode}) async {
    //final url = Uri.https('kongcrdv.com', '/ima/index.php', {"imgcode": '${imgcode}', "key": 'tegcargo06062024'});
    final url = Uri.https('laonet.online', '/ima/index.php', {"imgcode": '${imgcode}', "key": 'tegcargo06062024'});
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      if (data['status'] == "success") {
        return data['items']['item']['name'];
      } else {
        throw ApiException(data['message']);
      }
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //ค้นหาสินค้าด้วยรูป
  static Future getItemSearchImg({required String searchImg, required String type}) async {
    // 1) percent‐encode แล้วสร้าง URI
    final encodedImg = Uri.encodeComponent(searchImg);
    final uri = Uri.parse("https://api.icom.la/$type/api/call.php?api_key=tegcargo06062024&item_search_img&imgid=$encodedImg&lang=zh-CN&page=1");
    // final uri = Uri.https('api.icom.la', '/$type/api/call.php', {
    //   'item_search_img': 'item_search_img',
    //   'lang': 'zh-CN',
    //   'imgid': encodedImg,
    //   'page': '1',
    //   'api_key': 'tegcargo06062024',
    // });

    final client =
        HttpClient()
          ..autoUncompress =
              false // ปิด gzip
          ..connectionTimeout = Duration(seconds: 30);

    try {
      final request = await client.getUrl(uri);
      // บังคับไม่รับ encoding อื่น
      request.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw ApiException('HTTP ${response.statusCode}');
      }

      final body = await response.transform(convert.utf8.decoder).join();
      final data = convert.jsonDecode(body);

      // ตรวจสอบโครงสร้าง JSON
      if (data is Map && data.containsKey('item') && data['item'] is Map && data['item']['items'] is Map && data['item']['items']['item'] is List) {
        return data['item']['items']['item'] as List<dynamic>;
      } else {
        throw ApiException('ไม่สามารถติดต่อเซิร์ฟเวอร์ได้ กรุณาลองใหม่อีกครั้ง');
      }
    } on SocketException catch (e) {
      throw ApiException('Network error: $e');
    } finally {
      client.close(force: true);
    }
  }

  // ดึงเรท
  static Future getExchageRate() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/get_exchage_rate_setting');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data['data'];
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //ดึงข้อมูล เรท เงินหยวน
  static Future<RateExchange> getServiceRate() async {
    final url = Uri.https(publicUrl, '/public/api/exchange-rate');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return RateExchange.fromJson(data);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //
  static Future<TransferFee> getServiceFee() async {
    final url = Uri.https(publicUrl, '/public/api/get_fee_setting');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return TransferFee.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  // get รูป banner
  static Future<List<ImgBanner>> getImgBanner() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/banner_page');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "draw": 1,
        "type": "mall",
        "columns": [],
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
      return list.map((e) => ImgBanner.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //
  static Future<User> getUserById() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    var headers = {
      // 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final url = Uri.https(publicUrl, '/public/api/member/$userID');
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return User.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //ดึงข้อมูลบริการเสริม
  static Future<List<ServiceTransporterById>> getExtraService() async {
    final url = Uri.https(publicUrl, '/public/api/get_add_on_services');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => ServiceTransporterById.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //สร้างออเดอร์
  static Future createOrder({
    String? date,
    double? total_price,
    String? shipping_type,
    String? payment_term,
    String? note,
    String? importer_code,
    int? member_address_id,
    List<Products>? products,
  }) async {
    final url = Uri.https(publicUrl, '/public/api/orders');
    var headers = {'Content-Type': 'application/json'};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        'date': date,
        'total_price': total_price,
        'member_id': userID.toString(),
        'member_address_id': member_address_id.toString(),
        'shipping_type': shipping_type,
        'payment_term': payment_term,
        'note': note,
        'track_ecommerce_no': '',
        "importer_code": importer_code,
        "bill_vat": "N",
        'products': products,
      }),
    );

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data['data'];
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  ///ข้อมูลอัตราค่าขนส่ง
  static Future<List<RateShip>> getRateShip({int? page = 0, int? length = 10, String? search}) async {
    final url = Uri.https(publicUrl, '/public/api/rate_page');
    var headers = {
      // 'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "draw": 1,
        "order": [
          {"column": 0, "dir": "asc"},
        ],
        "start": page,
        "length": length,
        "search": {"value": search, "regex": false},
      }),
    );
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data']['data'] as List;
      return list.map((e) => RateShip.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //บริการเติม อะลีเปย์
  static Future productPaymentAlipayService({
    required String transaction,
    required double amount,
    required double fee,
    required String phone,
    required String image_qr_code,
    required String image,
    required String image_url,
    required String image_slip,
    required String image_slip_url,
  }) async {
    final url = Uri.https(publicUrl, '/public/api/alipay_payment');
    var headers = {'Content-Type': 'application/json'};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "member_id": userID,
        "transaction": transaction,
        "amount": amount,
        "fee": fee,
        "phone": phone,
        "transfer_at": DateTime.now().toString(),
        "image_qr_code": image_qr_code,
        "image": image,
        "image_url": image_url,
        "image_slip": image_slip,
        "image_slip_url": image_slip_url,
      }),
    );

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data;
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  // get ข้อมูลการเติมเงิน
  static Future<List<Payment>> getAlipayPayment() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/alipay_payment_page');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "draw": 1,
        "member_id": userID,
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
      return list.map((e) => Payment.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //get ข้อมูลการเติมเงินตามไอดีด
  static Future<Payment> getAlipayPaymentById({required int id}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/alipay_payment/$id');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return Payment.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //ดูรายการแลกของรางวัล
  static Future<List<Map<String, dynamic>>> getReward() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/reward_page');
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
