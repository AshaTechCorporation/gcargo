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

      // Sort by created_at descending (latest first) and take only the first one
      if (filteredList.isNotEmpty) {
        filteredList.sort((a, b) {
          if (a.created_at == null && b.created_at == null) return 0;
          if (a.created_at == null) return 1;
          if (b.created_at == null) return -1;
          return b.created_at!.compareTo(a.created_at!);
        });

        // Return only the latest transaction
        return [filteredList.first];
      }

      // Return empty list if no matching transactions found
      return [];
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  ////
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
