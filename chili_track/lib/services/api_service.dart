import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';

class ApiService {
  // ================= SOIL =================

  static Future<Map<String, dynamic>> getLatestSoil() async {
    final res = await http
        .get(Uri.parse("${ApiConfig.soilUrl}/latest"))
        .timeout(ApiConfig.requestTimeout);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load soil data");
  }

  // ================= TEMPERATURE =================

  static Future<Map<String, dynamic>> getLatestTemperature() async {
    final res = await http
        .get(Uri.parse("${ApiConfig.temperatureUrl}/latest"))
        .timeout(ApiConfig.requestTimeout);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load temperature");
  }

  // ================= CONTROL ON =================

  static Future wateringOn() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("${ApiConfig.controlUrl}/on"),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception("Failed to turn ON");
    }
  }

  // ================= CONTROL OFF =================

  static Future wateringOff() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    final res = await http.post(
      Uri.parse("${ApiConfig.controlUrl}/off"),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception("Failed to turn OFF");
    }
  }

  // ================= STATUS =================

  static Future<Map<String, dynamic>> getStatus() async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString("token");

    final res = await http.get(
      Uri.parse("${ApiConfig.controlUrl}/status"),
      headers: {"Authorization": "Bearer $token"},
    ).timeout(ApiConfig.requestTimeout);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load status");
  }
}
