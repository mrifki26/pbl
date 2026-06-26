import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';

class AuthService {
  static Future<bool> register(String username, String password) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.authUrl}/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      String token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);
      await prefs.setString("username", username.trim());

      return true;
    }

    return false;
  }

  static Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.authUrl}/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    ).timeout(ApiConfig.requestTimeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String token = data['token'];

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString("token", token);
      await prefs.setString("username", username.trim());

      return true;
    }

    return false;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("token");
  }

  static Future<String> getUsername() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("username") ?? "Petani";
  }

  static Future<String> getEmail() async {
    final username = await getUsername();
    final normalized = username.toLowerCase().replaceAll(" ", "");

    return "$normalized@chilitrack.com";
  }

  static Future logout() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("username");
  }
}
