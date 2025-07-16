import 'package:gcargo/constants.dart';
import 'package:gcargo/utils/ApiExeption.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

class LoginService {
  const LoginService();

  static Future login(String username, String password, String device_no, String notify_token) async {
    final url = Uri.https(publicUrl, '/api/login_app');
    final response = await http
        .post(url, body: {'importer_code': username, "password": password, 'device_no': device_no, 'notify_token': notify_token})
        .timeout(const Duration(minutes: 1));
    if (response.statusCode == 200) {
      final data = convert.jsonDecode(response.body);
      final dataOut = {'token': data['token'], "userID": data['data']['id']};
      return dataOut;
    } else {
      final data = convert.jsonDecode(response.body);
      throw ApiException(data['message']);
    }
  }
}
