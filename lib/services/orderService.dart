import 'package:gcargo/constants.dart';
import 'package:gcargo/models/bill.dart';
import 'package:gcargo/models/legalimport.dart';
import 'package:gcargo/models/orders/ordersPage.dart';
import 'package:gcargo/models/wallettrans.dart';
import 'package:gcargo/utils/ApiExeption.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

import 'package:shared_preferences/shared_preferences.dart';

class OrderService {
  const OrderService();

  static Future<List<OrdersPage>> geTrackOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/get_orders_by_member/$userID');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => OrdersPage.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //get order by id
  static Future<OrdersPage> getOrderById({required int order_id}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/orders/$order_id');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return OrdersPage.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //ยกเลิกออเดอร์ เปลี่ยนสถานะ
  static Future updateStatusOrder({String? status, String? remark_cancel, List<int>? orders}) async {
    final url = Uri.https(publicUrl, '/public/api/update_status_order');
    var headers = {'Content-Type': 'application/json'};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        "status": status,
        "remark_cancel": remark_cancel, //ระบุเหตุผลกรณียกเลิก
        "orders": orders,
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

  //ชำระเงิน
  static Future paymentOrder({
    String? payment_type,
    String? ref_no,
    String? date,
    double? total_price,
    String? note,
    String? image,
    String? order_type,
    bool? vat,
  }) async {
    final url = Uri.https(publicUrl, '/public/api/payment_order');
    var headers = {'Content-Type': 'application/json'};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        'payment_type': payment_type,
        'member_id': userID.toString(),
        'ref_no': ref_no,
        'date': date,
        'total_price': total_price,
        'note': note,
        'image': image,
        'order_type': order_type,
        'vat': vat == true ? 'Y' : 'N',
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

  //ชำระเงินหลานรายการ
  static Future paymentOrderMultiple({
    String? payment_type,
    double? total_price,
    String? order_type,
    List<Map<String, dynamic>>? item,
    bool? vat,
  }) async {
    final url = Uri.https(publicUrl, '/public/api/payment_order_multi');
    var headers = {'Content-Type': 'application/json'};
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({
        'payment_type': payment_type,
        'member_id': userID.toString(),
        'order_type': order_type,
        'items': item,
        'vat': vat == true ? 'Y' : 'N',
        'total_price': total_price,
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

  ///ดูยอดเงิน wallet ตามรหัสสมาชิก
  static Future<List<WalletTrans>> getWalletTrans() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print(token);
    final userID = prefs.getInt('userID');
    var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final url = Uri.https(publicUrl, '/public/api/get_wallet_trans/$userID');
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;

      // Convert to WalletTrans objects
      List<WalletTrans> walletTransList = list.map((e) => WalletTrans.fromJson(e)).toList();

      // Filter by userID and get only the latest one
      List<WalletTrans> filteredList = walletTransList.where((trans) => trans.member_id == userID).toList();

      // แยกตาม type "I" (เงินเข้า) และ "O" (เงินออก)
      if (filteredList.isNotEmpty) {
        // คำนวณผลรวมของ type "I"
        double sumTypeI = 0.0;
        for (var trans in filteredList.where((t) => t.type == 'I')) {
          sumTypeI += double.tryParse(trans.amount ?? '0') ?? 0.0;
        }

        // คำนวณผลรวมของ type "O"
        double sumTypeO = 0.0;
        for (var trans in filteredList.where((t) => t.type == 'O')) {
          sumTypeO += double.tryParse(trans.amount ?? '0') ?? 0.0;
        }

        // ลบกัน I - O = ยอดคงเหลือ
        double balance = sumTypeI - sumTypeO;

        // สร้าง WalletTrans ใหม่เพื่อส่งยอดคงเหลือกลับ
        // ใช้ข้อมูลจาก transaction ล่าสุดเป็นฐาน
        filteredList.sort((a, b) {
          if (a.created_at == null && b.created_at == null) return 0;
          if (a.created_at == null) return 1;
          if (b.created_at == null) return -1;
          return b.created_at!.compareTo(a.created_at!);
        });

        final latestTrans = filteredList.first;
        final balanceTrans = WalletTrans(
          latestTrans.id,
          latestTrans.code,
          latestTrans.No,
          balance.toStringAsFixed(6),
          latestTrans.created_at,
          latestTrans.detail,
          latestTrans.in_from,
          latestTrans.member_id,
          latestTrans.out_to,
          latestTrans.reference_id,
          latestTrans.status,
          latestTrans.type,
          latestTrans.updated_at,
          latestTrans.member,
        );

        return [balanceTrans];
      }

      // Return empty list if no matching transactions found
      return [];
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  ///ดูยอดเงิน wallet ตามรหัสสมาชิก เส้นเอพีไอใหม่
  static Future<List<WalletTrans>> getWalletTransNew() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userID = prefs.getInt('userID');
    var headers = {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'};
    final url = Uri.https(publicUrl, '/public/api/get_wallet_trans_by_member');
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

  ////แสดงรายการ พัสดุ
  static Future<List<LegalImport>> getDeliveryOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/get_delivery_orders_by_member/$userID');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => LegalImport.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //แสดงรายละเอียด พัสดุ
  static Future getDeliveryOrderById({required int id}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/delivery_orders/$id');
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

  //รายการเปิดบิล
  static Future<List<Bill>> getBills() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/get_bill_by_member/$userID');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final list = data['data'] as List;
      return list.map((e) => Bill.fromJson(e)).toList();
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //บิลตามไอดี
  static Future<Bill> getBillById({required int id}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final userID = prefs.getInt('userID');
    final url = Uri.https(publicUrl, '/public/api/bills/$id');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.get(headers: headers, url);
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return Bill.fromJson(data['data']);
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }
}
