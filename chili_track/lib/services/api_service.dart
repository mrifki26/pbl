import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/config/api_config.dart';

class ApiService {
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    return {
      if (token != null && token.isNotEmpty) "Authorization": "Bearer $token",
    };
  }

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
    final res = await http.post(
      Uri.parse("${ApiConfig.controlUrl}/on"),
      headers: await _authHeaders(),
    ).timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception("Failed to turn ON");
    }
  }

  // ================= CONTROL OFF =================

  static Future wateringOff() async {
    final res = await http.post(
      Uri.parse("${ApiConfig.controlUrl}/off"),
      headers: await _authHeaders(),
    ).timeout(ApiConfig.requestTimeout);

    if (res.statusCode != 200) {
      throw Exception("Failed to turn OFF");
    }
  }

  // ================= STATUS =================

  static Future<Map<String, dynamic>> getStatus() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.controlUrl}/status"),
      headers: await _authHeaders(),
    ).timeout(ApiConfig.requestTimeout);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load status");
  }

  static Future<List<dynamic>> getPumpDevices() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.controlUrl}/devices"),
      headers: await _authHeaders(),
    ).timeout(ApiConfig.requestTimeout);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load pump devices");
  }

  static Future<List<dynamic>> getPumpHistory() async {
    final res = await http.get(
      Uri.parse("${ApiConfig.controlUrl}/history"),
      headers: await _authHeaders(),
    ).timeout(ApiConfig.requestTimeout);

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    throw Exception("Failed to load pump history");
  }
}
