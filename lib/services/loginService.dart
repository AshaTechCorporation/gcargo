import 'package:gcargo/constants.dart';
import 'package:gcargo/utils/ApiExeption.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LoginService {
  const LoginService();

  static Future login(String username, String password, String device_no, String notify_token) async {
    final url = Uri.https(publicUrl, '/public/api/login_app');
    final response = await http
        .post(url, body: {'importer_code': username, "password": password, 'device_no': device_no, 'notify_token': notify_token})
        .timeout(const Duration(minutes: 1));
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final dataOut = {'token': data['token'], "userID": data['data']['id'], "point_balance": data['data']['point_balance']};
      return dataOut;
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  //forgot password
  static Future forgotPassword({String? email}) async {
    final url = Uri.https(publicUrl, '/public/api/forgot_password');
    //final url = Uri.https(publicUrl, '/public/api/forgot_password_user');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, headers: headers, body: convert.jsonEncode({'email': email}));

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data['message'];
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  static Future verifyOtpPassword({String? email, String? otp}) async {
    final url = Uri.https(publicUrl, '/public/api/verify_otp_password');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(url, headers: headers, body: convert.jsonEncode({'email': email, 'otp': otp}));

    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      return data['status'];
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }

  static Future resetPassword({String? email, String? new_password, String? confirm_new_password}) async {
    final url = Uri.https(publicUrl, '/public/api/reset_password');
    var headers = {'Content-Type': 'application/json'};
    final response = await http.post(
      url,
      headers: headers,
      body: convert.jsonEncode({'email': email, 'new_password': new_password, 'confirm_new_password': confirm_new_password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = convert.jsonDecode(response.body);
      return data['status'];
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }
}
